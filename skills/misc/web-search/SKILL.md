---
name: web-search
description: Web work router across Exa, Firecrawl Local and TinyFish. Use before any web search, URL read, site crawl or map, or website interaction.
---

# Web search

Three tools cover web work. Each job goes to the cheapest tool that does it well; escalate only on a real **miss** (empty, truncated, blocked or off-target result), never on a guess.

| Job | Tool | Call |
|---|---|---|
| **Find**: no URL yet; facts, sources, docs, news | Exa MCP | `web_search_exa`; filters (domain, date, category) → `web_search_advanced_exa` |
| **Read**: one known URL, PDF or Office file → markdown | Firecrawl Local MCP | `firecrawl_scrape` |
| **Map**: list every URL of a site | Firecrawl Local MCP | `firecrawl_map` |
| **Crawl**: many pages of one site → markdown | Firecrawl Local MCP | `firecrawl_crawl`, poll with `firecrawl_check_crawl_status` |
| **Act**: click, fill forms, paginate, extract from a dynamic site | TinyFish CLI | `tinyfish agent run --url <url> "<goal>"`; raw CDP → `tinyfish browser` |
| **Logged-in**: a site that needs moon's session | `browse` MCP | moon's real Chrome; changes on moon's accounts need moon's "dale" |
| **Research**: multi-step, list-building, enrichment across sites | Exa MCP | `agent_run` |

## Escalation

1. Read misses on `firecrawl_scrape` → `web_fetch_exa` → `tinyfish fetch content get --format markdown <url>` → Act.
2. Find off-target on Exa → `tinyfish search query "<q>"`.

## Firecrawl Local

- Runs on this machine with `FIRECRAWL_CLOUD=off`: free, no quota, URLs stay local.
- Only `firecrawl_scrape`, `firecrawl_map`, `firecrawl_crawl` and `firecrawl_check_crawl_status` run locally. Its other tools (search, agent, interact, monitor, Alexandria, research, people) are Firecrawl Cloud and fail here: route those jobs by the table.
- From a shell: `firecrawl-local scrape <url> --markdown`, `firecrawl-local crawl <url> --limit 50 --out <dir>`, `firecrawl-local map <url>`.

## TinyFish CLI

- Auth: `TINYFISH_API_KEY` or `tinyfish auth login`; moon runs the login in their own terminal.
- `tinyfish search query "<q>" [--location <hint>] [--language <hint>]`
- `tinyfish fetch content get <urls...> [--format markdown|html|json] [--links]`
- `tinyfish agent run --url <url> "<goal>" [--sync|--async]`; ask for JSON in the goal to get structured data. Track with `tinyfish agent run get <run_id>`; many URLs → `tinyfish agent batch run --input runs.csv`.
- `tinyfish browser session create --url <url> [--proxy-country <code>]` returns a CDP session for Playwright.
- Details: `tinyfish <command> --help`.
