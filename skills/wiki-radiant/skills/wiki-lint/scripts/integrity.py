#!/usr/bin/env python3
"""Check source artifacts and index coverage in one pass over a vault."""

import argparse
from collections import defaultdict
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote

try:
    import yaml
except ImportError:
    sys.exit("Missing PyYAML. Install scripts/requirements.txt from the wiki-lint skill in your Python environment.")


def links(text: str, vault: Path):
    """Normalize bundle links consistently for every structural consumer."""
    fence = None
    for line in text.splitlines():
        marker = re.match(r"^\s*(`{3,}|~{3,})", line)
        if marker:
            token = marker.group(1)
            if fence is None:
                fence = token
            elif token[0] == fence[0] and len(token) >= len(fence):
                fence = None
            continue
        if fence:
            continue
        for raw in re.findall(r"\]\((/wiki/(?:[^()]|\([^()]*\))+)\)", line):
            target = unquote(raw.split("#", 1)[0])
            yield raw, (vault / target.lstrip("/")).resolve()


def check(vault: Path) -> dict:
    wiki = vault / "wiki"
    if not wiki.is_dir():
        raise ValueError(f"No wiki/ found in {vault}")
    health = {"missing_raw": [], "unindexed_pages": [], "duplicate_sources": [],
              "dead_links": [], "orphan_pages": [], "raw_without_source_page": []}
    findings = []

    def report(severity, message):
        findings.append({"severity": severity, "message": message})

    index = wiki / "index.md"
    texts = {p: p.read_text(encoding="utf-8") for p in sorted(wiki.rglob("*.md"))}
    if index not in texts:
        report("HIGH", "Missing wiki/index.md")
    listings = set()
    incoming = set()
    seen_dead = set()
    for page, content in texts.items():
        for raw, target in links(content, vault):
            if page == index:
                listings.add(target)
            if target != page.resolve():
                incoming.add(target)
            if not target.is_relative_to(wiki.resolve()) or not target.is_file():
                relative = page.relative_to(vault).as_posix()
                if (relative, raw) not in seen_dead:
                    seen_dead.add((relative, raw))
                    health["dead_links"].append({"from": relative, "broken_target": raw})
                    report("HIGH", f"Dead link in {relative}: {raw}")

    raw_sources = defaultdict(list)
    raw_root = (vault / ".raw").resolve()
    for page, text in texts.items():
        if page.name in {"index.md", "log.md", "_index.md"}:
            continue
        relative = page.relative_to(vault).as_posix()
        if page.resolve() not in listings:
            health["unindexed_pages"].append(relative)
            report("MEDIUM", f"Page missing from wiki/index.md: {relative}")
        if page.resolve() not in incoming:
            health["orphan_pages"].append(relative)
            report("MEDIUM", f"Orphan: {relative}")
        if not page.is_relative_to(wiki / "sources"):
            continue

        frontmatter = re.match(r"\A---\s*\n(.*?)\n---(?:\s*\n|\Z)", text, re.S)
        if frontmatter is None:
            continue  # The main linter reports missing frontmatter.
        try:
            data = yaml.safe_load(frontmatter.group(1))
        except yaml.YAMLError:
            report("HIGH", f"Invalid YAML frontmatter: {relative}")
            continue
        raw = data.get("raw") if isinstance(data, dict) else None
        if not isinstance(raw, str) or not raw.strip():
            health["missing_raw"].append(relative)
            report("HIGH", f"Source has no usable raw path: {relative}")
            continue
        target = (vault / raw).resolve()
        if Path(raw).is_absolute() or not target.is_relative_to(raw_root) or target == raw_root:
            health["missing_raw"].append(relative)
            report("HIGH", f"Source raw path must stay inside .raw/: {relative}")
            continue
        raw_sources[target].append(relative)
        if not target.is_file():
            health["missing_raw"].append(relative)
            report("HIGH", f"Missing raw artifact for {relative}: {raw}")

    for artifact in sorted((vault / ".raw").rglob("*")):
        if artifact.is_file() and not any(part.startswith(".") for part in artifact.relative_to(vault / ".raw").parts):
            if artifact.resolve() not in raw_sources:
                relative = artifact.relative_to(vault).as_posix()
                health["raw_without_source_page"].append(relative)
                report("HIGH", f"No source page for: {relative}")

    for target, pages in sorted(raw_sources.items()):
        if len(pages) > 1:
            group = {"raw": target.relative_to(raw_root).as_posix(), "pages": pages}
            group["raw"] = ".raw/" + group["raw"]
            health["duplicate_sources"].append(group)
            report("MEDIUM", f"Duplicate source candidates for {group['raw']}: {', '.join(pages)}")
    return {"health": health, "findings": findings}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("vault", type=Path)
    args = parser.parse_args()
    try:
        result = check(args.vault.resolve())
    except (OSError, UnicodeError, ValueError) as error:
        print(f"Integrity check failed: {error}", file=sys.stderr)
        return 2
    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
