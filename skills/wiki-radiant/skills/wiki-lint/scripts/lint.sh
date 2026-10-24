#!/bin/bash
# lint.sh: health check for a Radiant vault wiki/
# Usage: lint.sh [vault-path]
# Exit: 0 = no HIGH findings, 1 = HIGH findings exist

set -uo pipefail

VAULT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
WIKI="$VAULT/wiki"

if [ ! -d "$WIKI" ]; then
  echo "ERROR: No wiki/ found in $VAULT" >&2
  exit 2
fi

# Run before any report writes: missing dependencies or unreadable pages
# must fail visibly and leave the previous health report intact.
for dep in python3 jq; do
  command -v "$dep" >/dev/null 2>&1 || { echo "ERROR: missing $dep" >&2; exit 2; }
done
INTEGRITY=$(python3 -B "$(dirname "$0")/integrity.py" "$VAULT") || exit 2

FINDINGS=$(mktemp) || { echo "ERROR: mktemp failed: cannot allocate temp file for findings" >&2; exit 2; }
NO_CONF=$(mktemp) || { echo "ERROR: mktemp failed: cannot allocate temp file for missing_confidence" >&2; exit 2; }
INDEX_MISMATCHES=$(mktemp) || { echo "ERROR: mktemp failed: cannot allocate temp file for index_mismatches" >&2; exit 2; }
trap 'rm -f "$FINDINGS" "$NO_CONF" "$INDEX_MISMATCHES"' EXIT

f() { echo "[$1] $2" >> "$FINDINGS"; }

printf '%s\n' "$INTEGRITY" | jq -r '.findings[] | "[\(.severity)] \(.message)"' >> "$FINDINGS"

# ── HIGH: Pages without frontmatter ──────────────────────────────────────────
# index.md and log.md are intentionally frontmatter-less (OKF §6/§7).
find "$WIKI" -name "*.md" \
  | grep -v '_index\|/index\.md\|/log\.md' \
  | while read -r p; do
      head -1 "$p" | grep -q "^---" || f HIGH "No frontmatter: ${p#"$VAULT"/}"
    done

# ── MEDIUM: Missing provenance: concepts + entities ──────────────────────────
# Source pages usan `resource:` (URL) y `raw:`, no `# Citations`
for dir in "$WIKI/concepts" "$WIKI/entities"; do
  [ -d "$dir" ] || continue
  find "$dir" -name "*.md" | grep -v '_index' | while read -r p; do
    rel="${p#"$VAULT"/}"
    grep -q "^# Citations" "$p" || f MEDIUM "No # Citations: $rel"
    grep -q "^confidence:" "$p" || { f MEDIUM "No confidence: $rel"; echo "$rel" >> "$NO_CONF"; }
  done
done

# ── MEDIUM: Sources without confidence ────────────────────────────────────────
[ -d "$WIKI/sources" ] && \
find "$WIKI/sources" -name "*.md" | grep -v '_index' | while read -r p; do
  grep -q "^confidence:" "$p" || { f MEDIUM "No confidence: ${p#"$VAULT"/}"; echo "${p#"$VAULT"/}" >> "$NO_CONF"; }
done

# ── LOW: Sources without tags ─────────────────────────────────────────────────
[ -d "$WIKI/sources" ] && \
find "$WIKI/sources" -name "*.md" | grep -v '_index' | while read -r p; do
  val=$(grep "^tags:" "$p" 2>/dev/null | head -1)
  { [ -z "$val" ] || [ "$val" = "tags: []" ]; } && f LOW "No tags: ${p#"$VAULT"/}"
done

# ── Frontmatter vs templates/{type}.md ────────────────────────────────────────
# Generic diff against the vault's own templates: HIGH for duplicate keys
# (invalid/ambiguous YAML), MEDIUM for keys the page has that its template
# doesn't (or vice versa). Confidence/tags omissions stay in the dedicated
# checks above (they feed vault-report.json); skip them here to avoid double
# reporting the same gap under two messages.
TEMPLATES="$VAULT/templates"
fm_keys() {  # $1: file -> one frontmatter key per line, duplicates preserved
  awk '
    /^---$/ { c++; next }
    c==1 && $0 ~ /^[A-Za-z_][A-Za-zA-Z0-9_]*:/ { k=$0; sub(/:.*/,"",k); print k }
    c==2 { exit }
  ' "$1" 2>/dev/null
}

tmpl_val_nonempty() {  # $1: template file, $2: key -> "1" if template ships a non-blank default, else "0"
  awk -v key="$2" '
    /^---$/ { c++; next }
    c==1 && $0 ~ "^"key":" {
      v=$0; sub("^"key":[ \t]*","",v); gsub(/[ \t]+$/,"",v)
      print (length(v)>0) ? "1" : "0"; found=1; exit
    }
    c==2 { exit }
    END { if (!found) print "0" }
  ' "$1"
}

if [ -d "$TEMPLATES" ]; then
  find "$WIKI" -name "*.md" \
    | grep -v '_index\|/index\.md\|/log\.md' \
    | while read -r p; do
        rel="${p#"$VAULT"/}"
        keys=$(fm_keys "$p")
        [ -z "$keys" ] && continue  # no frontmatter: already flagged above

        dups=$(echo "$keys" | sort | uniq -d)
        if [ -n "$dups" ]; then
          echo "$dups" | while read -r dk; do
            [ -n "$dk" ] && f HIGH "Duplicate frontmatter key '${dk}' in ${rel}"
          done
        fi

        type=$(grep -m1 "^type:" "$p" | sed 's/^type:[[:space:]]*//' | tr -d '[:space:]')
        tmpl="$TEMPLATES/${type}.md"
        if [ -n "$type" ] && [ -f "$tmpl" ]; then
          tmpl_keys=$(fm_keys "$tmpl" | sort -u)
          page_keys=$(echo "$keys" | sort -u)
          extra=$(comm -23 <(echo "$page_keys") <(echo "$tmpl_keys") | grep -vx 'confidence\|tags')
          missing=$(comm -13 <(echo "$page_keys") <(echo "$tmpl_keys") | grep -vx 'confidence\|tags')
          [ -n "$extra" ] && echo "$extra" | while read -r ek; do
            [ -n "$ek" ] && f MEDIUM "Frontmatter key '${ek}' in ${rel} not in templates/${type}.md"
          done
          [ -n "$missing" ] && echo "$missing" | while read -r mk; do
            [ -z "$mk" ] && continue
            if [ "$(tmpl_val_nonempty "$tmpl" "$mk")" = "1" ]; then
              f MEDIUM "Frontmatter missing key '${mk}' (per templates/${type}.md) in ${rel}"
            else
              f LOW "Frontmatter missing key '${mk}' (optional: blank default in templates/${type}.md) in ${rel}"
            fi
          done
        fi
      done
fi

# ── LOW: Directories with no matching templates/{type}.md ────────────────────
# Structural drift is a user decision, not an auto-fix: informational only.
if [ -d "$TEMPLATES" ]; then
  EXPECTED_DIRS=$(find "$TEMPLATES" -maxdepth 1 -name "*.md" -exec basename {} .md \; \
    | awk '{ if ($0 ~ /y$/) { sub(/y$/,"ies"); print } else print $0 "s" }')
  find "$WIKI" -mindepth 1 -maxdepth 1 -type d ! -name ".*" | while read -r d; do
    dname=$(basename "$d")
    echo "$EXPECTED_DIRS" | grep -qx "$dname" \
      || f LOW "Carpeta fuera de estructura: wiki/${dname}/ (sin templates/*.md correspondiente: decisión del usuario)"
  done
fi

# ── LOW: index.md section vs page type ───────────────────────────────────────
# Console-only (not persisted to vault-report.json): same pattern as the
# directory-structure check above. A page is mismatch only if it appears in
# a section that doesn't match its frontmatter `type:` AND is absent from
# its correct section (heuristic A: tolerates intentional cross-references,
# flags pages that live only in the wrong place).
if [ -f "$WIKI/index.md" ]; then
  python3 - "$WIKI" "$INDEX_MISMATCHES" <<'PYEOF'
import re, sys
from pathlib import Path

# sys.argv[1] is $WIKI = $VAULT/wiki; rglob starts from there, so
# relative_to(WIKI) yields "concepts/...", "sources/...": prefix
# with "wiki/" to match the [title](/wiki/...) shape in index.md.
wiki = Path(sys.argv[1])
out = Path(sys.argv[2])
text = (wiki / "index.md").read_text()
section_to_type = {
    "concepts": "concept", "conceptos": "concept", "entities": "entity",
    "entidades": "entity", "fuentes": "source", "sources": "source",
    "proyectos": "project", "projects": "project",
}

current = None
listings = {}
for line in text.splitlines():
    m = re.match(r"^##\s+(\w+)", line)
    if m:
        # Any `##` heading (recognized or not) ends the previous section.
        # otherwise unknown headings would let their following links be
        # misattributed to the prior section.
        current = section_to_type.get(m.group(1).lower())
        listings.setdefault(current, set())
    elif current:
        m = re.match(r"^\s*-\s*\[[^\]]*\]\((/?wiki/(?:[^)]|\([^)]*\))+)\)", line)
        if m:
            target = re.sub(r"\.md$", "", m.group(1).lstrip("/"))
            listings[current].add(target)

findings = []
for p in sorted(wiki.rglob("*.md")):
    if p.name in ("_index.md", "index.md", "log.md"):
        continue
    try:
        content = p.read_text()
    except (OSError, UnicodeDecodeError):
        continue
    fm = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not fm: continue
    tm = re.search(r"^type:\s*(\w+)", fm.group(1), re.MULTILINE)
    if not tm: continue
    page_type = tm.group(1)
    rel = re.sub(r"\.md$", "", "wiki/" + str(p.relative_to(wiki)))
    for section_type, paths in listings.items():
        if section_type == page_type: continue
        if rel in paths and rel not in listings.get(page_type, set()):
            findings.append(f"Section/type mismatch: {rel} listed under '{section_type}' (type is '{page_type}')")

out.write_text("\n".join(findings) + ("\n" if findings else ""))
PYEOF
  while IFS= read -r line; do
    [ -n "$line" ] && f LOW "$line"
  done < "$INDEX_MISMATCHES"
fi

# ── MEDIUM: Malformed or non-sequential # Citations ───────────────────────────
# Each non-blank line under a `# Citations` heading must read
# "[N] [title](/wiki/...)" with N sequential starting at 1.
find "$WIKI" -name "*.md" \
  | grep -v '/index\.md\|/log\.md' \
  | while read -r p; do
      grep -q '^# Citations' "$p" || continue
      rel="${p#"$VAULT"/}"
      awk -v rel="$rel" '
        /^# Citations/ { incite=1; n=0; next }
        incite && /^#/ { incite=0 }
        incite && /^---$/ { incite=0 }
        incite && NF {
          n++
          pat = "^\\[" n "\\] \\[[^]]+\\]\\(/wiki/.*\\.md\\)[ \t]*$"
          if ($0 !~ pat) {
            printf "%s\t%s\n", rel, $0
          }
        }
      ' "$p"
    done | while IFS=$'\t' read -r rel line; do
      [ -n "$rel" ] && f MEDIUM "Malformed # Citations entry in ${rel}: expected sequential [N] [title](/wiki/...), got: ${line}"
    done

# ── Schema validation (delegated) ────────────────────────────────────────────
VALIDATE_SCRIPT="$(dirname "$0")/validate-schema.sh"
if [ -x "$VALIDATE_SCRIPT" ]; then
  "$VALIDATE_SCRIPT" "$VAULT" "$FINDINGS"
else
  echo "WARNING: validate-schema.sh not found next to lint.sh ($VALIDATE_SCRIPT): schema drift checks skipped. Reinstall the wiki-lint skill to restore it." >&2
fi

# ── Output ────────────────────────────────────────────────────────────────────
if [ ! -f "$FINDINGS" ]; then
  echo "ERROR: findings file disappeared mid-run ($FINDINGS): cannot report results" >&2
  exit 2
fi
HIGH=$(grep -c '^\[HIGH\]'   "$FINDINGS" 2>/dev/null || true)
MED=$(grep  -c '^\[MEDIUM\]' "$FINDINGS" 2>/dev/null || true)
LOW=$(grep  -c '^\[LOW\]'    "$FINDINGS" 2>/dev/null || true)
case "$HIGH$MED$LOW" in
  *[!0-9]*|"") echo "ERROR: could not compute finding counts (HIGH='$HIGH' MEDIUM='$MED' LOW='$LOW'): treating as failure, not silent success" >&2; exit 2 ;;
esac

for sev in HIGH MEDIUM LOW; do
  lines=$(grep "^\[${sev}\]" "$FINDINGS" 2>/dev/null || true)
  [ -n "$lines" ] && echo "" && echo "── ${sev} ────────────────" && echo "$lines"
done

echo ""
echo "── Summary ──────────────────────────────────────────────────────────────"
echo "HIGH: $HIGH  MEDIUM: $MED  LOW: $LOW"

# ── vault-report.json ─────────────────────────────────────────────────────────
# Canonical schema defined in skills/wiki-lint/references/VAULT-REPORT-SCHEMA.md
# Written atomically (temp file in the same dir + rename) so a kill/crash
# mid-write never leaves a truncated/corrupt vault-report.json behind.
# meta/ holds operational state outside the wiki/ knowledge bundle.
mkdir -p "$VAULT/meta"
REPORT_TMP=$(mktemp "$VAULT/meta/.vault-report.json.XXXXXX") || { echo "ERROR: mktemp failed: cannot write vault-report.json" >&2; exit 2; }
if ! printf '%s' "$INTEGRITY" | jq --arg generated "$(date +%Y-%m-%d)" --rawfile confidence "$NO_CONF" \
  '{generated: $generated, health: (.health + {missing_confidence: ($confidence | split("\n") | map(select(length > 0)) | unique)})}' > "$REPORT_TMP"; then
  echo "ERROR: failed to serialize vault-report.json" >&2
  rm -f "$REPORT_TMP"
  exit 2
fi
mv "$REPORT_TMP" "$VAULT/meta/vault-report.json" || { echo "ERROR: failed to publish vault-report.json" >&2; rm -f "$REPORT_TMP"; exit 2; }
echo "Report written: meta/vault-report.json"

[ "$HIGH" -gt 0 ] && exit 1 || exit 0
