# Optional project update

Read after the local snapshot when a vault or project update was requested, or when the session consulted a vault for this project.

1. Resolve the target vault using `~/.config/radiant/references/VAULT-RESOLUTION.md` and its locale using `LOCALE-RESOLUTION.md` in the same directory. If these files or the vault are unavailable, report the skipped project update and how `/wiki-setup` enables it. Keep the completed local snapshot.
2. Use the project-name argument or the repository folder name to locate `{vault}/wiki/projects/{project-name}.md`. If absent, report that and stop this optional branch.
3. Propose only concrete additions from this session: cited wiki pages for `## Knowledge applied` and recurring failure patterns for `## Recurring issues`. Skip empty categories. Show the exact text and destination; apply when covered by the user's authorization.
4. Write approved additions in the vault's locale, update the page's `updated:` date and changelog, and append `**[YYYY-MM-DD] project-update** | {page}: {changes}` to `wiki/log.md`. Use Markdown links to the wiki pages referenced. Confirm the updated path.
