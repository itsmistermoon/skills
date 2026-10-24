---
name: wiki-query
license: MIT
description: "Answer questions from wiki evidence with page citations, using text or optional semantic search."
disable-model-invocation: true
argument-hint: "[vault-name] <query>"
---

# wiki-query

Start your response with the flavor line `Querying vault...`, translated to the language of the user's current message (Spanish: `Consultando el vault...`), with nothing before it. Use that same language for every prompt, question, menu, and confirmation this skill produces.

Answer a question using the vault's wiki content as the source.

## Available scripts

Scripts live in `scripts/` inside this skill's directory (`<skill-dir>/scripts/`, e.g. `~/.agents/skills/wiki-query/scripts/` or `~/.claude/skills/wiki-query/scripts/` when installed globally, or `./skills/wiki-query/scripts/` in this repo). When running from a vault, resolve `<skill-dir>` to locate co-located scripts.

- **`scripts/search.py`**: Semantic search over `.hot/db/vault.db` (step 2)
- **`scripts/embeddings.py`**: Shared embedding backend, imported by `search.py`; not invoked directly

## Steps

1. **Resolve vault**: per `~/.config/radiant/references/VAULT-RESOLUTION.md` (synced by `/wiki-setup`: if missing, run `/wiki-setup` first). If the first argument matches a registered vault name (e.g., `/wiki-query second-brain <query>`), use that vault; treat the remaining text as the query.

2. **Identify relevant pages**: prefer semantic search if the index is available:
   - If `{vault}/.hot/db/vault.db` exists: locate `search.py` under `<skill-dir>/scripts/` (e.g. `python3 ~/.agents/skills/wiki-query/scripts/search.py`), run `<path-to-search.py> --vault {vault} "{query}" --top-k 8 --json`, and use the returned chunks (path + heading + content) as the primary source set.
   - Without an index, or when semantic results do not cover the question, search filenames and text in `wiki/concepts/`, `wiki/entities/`, `wiki/sources/`, and `wiki/projects/`. Use `rg --files` for filenames and `rg -l -i -F -e '<term>' ...` for distinctive query terms across titles, aliases, descriptions, and body text. Read index.md for navigation, not as the only evidence of what exists. Missing optional directories can be skipped.
   - Read at most 8 candidate pages initially, ranked by exact title/alias match, then relevant body matches. Expand only for a specific unresolved part of the question or a contradiction. Before declaring a miss, complete a textual search for the question's distinctive terms. A failed search tool is an error, not evidence that the vault has no answer. **Done when:** supporting pages are identified or the completed searches found no relevant evidence.

3. **Answer**: read the full page for any result where the chunk alone is insufficient, then synthesize a response with citations to specific pages. If information is missing, point to `/wiki-ingest` for the missing sources, and append one line to `{vault}/wiki/log.md`: `**[YYYY-MM-DD] query-miss** | {query}`. Log misses only: a query that gets a real answer leaves no trace here.

4. **Offer to persist, rarely**: only when the answer produces a new synthesis, offer once to save it through `wiki-imprint`. Skip this for a restatement of one page. If the user accepts or directly asks to save the answer, treat that request as invoking `wiki-imprint` and follow it using this analysis as session context. Preserve its primary-source and circular-synthesis checks. Ask only for a destination or content decision still unresolved by the request.

## Output format

1. Answers supported by pages include citations in the form `Source: wiki/{type}/{slug}.md [confidence: {value}]` for every page used, where `{value}` is read directly from its YAML frontmatter `confidence:` field.
   - No `confidence:` field → append `[confidence: unset]` and flag it as a finding.
   - Malformed YAML → append `[confidence: read-error]` and flag it.
   - `confidence: medium` or `low` → append the value, do not flag: these are valid states.
2. If no relevant pages exist: state "Not in vault" explicitly: do not fall back to training knowledge.

## Constraints

- **Parametric knowledge is disqualified** for any topic this vault may cover. What you know from training is unverified: the vault is the source of truth. Even if you believe you already know the answer, run the steps anyway.
- Run retrieval within this skill. Text search and direct reads in step 2 are supported retrieval methods; answers must remain grounded in the retrieved wiki evidence.

## Rules

- If there are contradictions between pages, flag them
