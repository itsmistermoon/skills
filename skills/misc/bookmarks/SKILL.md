---
name: bookmarks
description: "Set up and manage the OKF bookmark collection: save a website with a dated screenshot, or find resources for a need."
disable-model-invocation: true
argument-hint: "{url | search query}"
---

Store titles, descriptions, notes, categories, and tags in English; preserve product names and identifiers.

## Start and first-run setup

1. Resolve the config path: use `BOOKMARKS_CONFIG` when it names a path; otherwise use `~/.config/bookmarks/config.yml`.
2. If the config exists, read it. If it is malformed, explain the problem and ask before correcting only `collection` or `taxonomy`, preserving all other content. If the user declines, stop without changing the config. Then continue to step 6.
3. If the config is missing, ask where to store the collection unless the user already specified a path. Recommend `~/bookmarks/` as the default; an empty answer, `default`, or acceptance means `~/bookmarks/`. Explain that setup creates an empty collection and does not copy anyone's bookmarks.
4. Expand `~` and resolve the chosen collection path. Inspect it before writing; ignore `.DS_Store` when deciding whether a folder is empty. For a new or empty directory, create `items/` and `assets/`, then copy `templates/index.md` and `templates/taxonomy.md` from beside this `SKILL.md`. Seed only those two templates; leave `items/` and `assets/` empty. The starter taxonomy has broad categories and no tags. If the directory already contains a valid bundle, preserve it. If it contains other data or an incomplete bundle, show what is present and ask before adding anything; if the user declines, stop without changing it. After confirmation, add only missing files and directories. Never replace existing content; if a file conflicts with the scaffold, stop and explain the conflict.
5. Once the collection is ready, create a missing config parent directory and write the config. Store `collection` as a JSON-quoted absolute path (valid YAML) and `taxonomy: "taxonomy.md"` relative to the collection. Create the config only if it is still missing; if it appeared during setup, read it instead of replacing it. If it points to a different collection, stop and ask which location to use. If an existing config was malformed and the user approved repair, edit only its broken path value and preserve all other content.
6. Read the config and validate the bundle: `collection` must be a directory containing `index.md`, the configured taxonomy file, `items/`, and `assets/`. The root index must declare OKF v0.2; taxonomy frontmatter must declare `type: Bookmark Taxonomy`. For each existing item, confirm `type: Bookmark`, a unique `resource`, a registered category, at most five registered tags, an index link, and an embedded screenshot file with an explicit-offset `screenshot_captured_at`. If any path or marker is missing or invalid, show the exact problem and ask before repair; preserve existing files and stop if the user declines. After setup writes or repairs the config, read it back. **Setup is ready when** the config resolves to this complete scaffold and existing bundle content passes these checks.
7. Treat the entire argument as a URL only when it is one valid `http` or `https` URL. Otherwise use it as a search query. If no argument was given, ask what to save or find. When setup completes, continue with the original request in this same invocation.

## Ingest a URL

1. Normalize the URL for duplicate checks: lowercase the host; remove default ports, fragments, and common tracking parameters (`utm_*`, `fbclid`, `gclid`); preserve other query parameters. Search all bookmark concepts for a matching `resource`; if found, report the existing item and stop.
2. Read the page with `firecrawl-local scrape <url> --markdown` (on a miss, follow the `web-search` skill's escalation) to identify its canonical URL, title, purpose, audience, and main topics or technologies. Store the canonical URL when available; otherwise store the input URL. Check both normalized URLs against existing `resource` values; if either matches, report the existing item and stop. If the page cannot be inspected or its identity is unclear, ask the user for context and stop before writing.
3. Capture the first viewport with headless Playwright on the installed Chrome, then convert it to WebP:

   ```sh
   npx -y playwright screenshot --channel chrome --viewport-size "1440,1100" --wait-for-timeout 2000 <url> /tmp/{slug}.png
   cwebp -quiet -q 80 /tmp/{slug}.png -o assets/{slug}-{YYYY-MM-DD}.webp
   ```

   Use the local capture date in the filename. Aim for a clear image under 400 KiB; if needed, capture again at `1280,900`. Record the actual viewport in `screenshot_viewport`; record `screenshot_captured_at` as an ISO 8601 timestamp with the local UTC offset. Look at the image: if it shows an error, a blank page or a bot challenge instead of the actual page, delete it, explain the issue and stop without adding an incomplete bookmark.
4. Reconcile the existing categories and tags against `taxonomy.md`. Use one registered broad category and zero to five registered tags. Reuse values that fit. Add a category only when none describes a recurring class of resources. Add a tag only when no existing tag fits and the topic can recur. Keep names in English, lowercase, unaccented, and hyphenated. Omit generic, synonymous, repetitive, or category-duplicating tags. Update the taxonomy in the same operation when adding a value.
5. Create `items/{slug}.md` with OKF YAML frontmatter. Derive a readable lowercase slug from the title; if that filename already exists for a different resource, add a short host suffix. Never overwrite an existing item. Use this field order:

   ```yaml
   ---
   type: Bookmark
   title: "Display name"
   description: "One-sentence summary."
   resource: https://example.com/
   category: ui-design
   tags:
     - react
   verdict: later
   date_added: "YYYY-MM-DD"
   screenshot: ../assets/example-YYYY-MM-DD.webp
   screenshot_captured_at: "YYYY-MM-DDTHH:MM:SS-03:00"
   screenshot_viewport: 1440x1100
   screenshot_format: webp
   ---
   ```

   Use `tags: []` when no tag fits. Use today's local date for `date_added`. Use `later` when the user gave no verdict; preserve `adopt` or `discard` when specified. Put useful extra context in a `## Note` body section. Embed the image with a standard Markdown link to the same relative path and an accessible description.
6. Add the new concept to `index.md` under its category, including its description. Keep category order from `taxonomy.md`; put new categories at the end. Save the note, image, index, and any registry change together.
7. Re-read the concept and changed files against steps 3–6: every field of the step 5 template present and in order, `date_added` today, classification registered, viewport and timestamp matching the capture, and one index link.
8. Report the title, category, tags, capture date, and changed paths.

**Complete when:** the bookmark concept is indexed exactly once, has valid OKF frontmatter, uses registered classification values, and embeds its dated screenshot of the live resource.

## Search the collection

1. Turn the request into the need, resource type, technologies, and explicit constraints.
2. Search `index.md` and bookmark concepts across titles, `resource` URLs, categories, tags, descriptions, and notes. Try distinctive terms and their Spanish and English synonyms.
3. Read candidate concepts and rank them by fit, practical usefulness, and stated constraints. Return up to five results; include more only when each adds distinct value.
4. For each result, show its title, URL, category, tags, verdict, and a specific reason supported by the concept. If no entries match after searching the relevant fields and synonyms, say the collection has no match.

**Complete when:** each result is supported by a saved concept and matches the user's need, or the relevant fields and synonyms have been searched with no match found.
