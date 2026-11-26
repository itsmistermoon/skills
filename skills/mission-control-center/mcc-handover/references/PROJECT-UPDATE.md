# Optional project update

The calling handover resolves scope and destination ownership before writes. Follow this branch after its local snapshot.

1. Resolve the target vault using `~/.config/radiant/references/VAULT-RESOLUTION.md` and its locale using `LOCALE-RESOLUTION.md` in the same directory. If these files or the vault are unavailable, report the skipped project update and how `/wiki-setup` enables it. **Done when:** the vault and locale are resolved or the skipped branch is reported.
2. Use the project-name argument or the repository folder name to locate `{vault}/wiki/projects/{project-name}.md`. If absent, report that and stop this optional branch. **Done when:** the project page exists or its absence is reported.
3. Propose only concrete additions from this session: cited wiki pages for `## Knowledge applied` and recurring failure patterns for `## Recurring issues`. Skip empty categories. Show the exact text and destination; apply when covered by the user's authorization. **Done when:** each candidate has an exact destination and text, and is approved, deferred, or omitted as empty.
4. Write approved additions in the vault's locale, update the page's `updated:` date and changelog, and append `**[YYYY-MM-DD] project-update** | {page}: {changes}` to `wiki/log.md`. Use Markdown links to the wiki pages referenced. Confirm the updated path. **Done when:** each approved addition, date, changelog entry, and log entry is saved and the updated path is confirmed.
