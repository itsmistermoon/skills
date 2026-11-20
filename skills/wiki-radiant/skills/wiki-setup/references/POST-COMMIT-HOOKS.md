# Post-commit hooks

Reference for `wiki-setup` (step 5a to install, maintenance menu options 6/7; maintenance menu option 9 to uninstall). Plain git hooks, not agent lifecycle hooks: identical across agents. Both backgrounded or fail-open: never block a commit.

## Shared mechanics

- If `git config core.hooksPath` is set (husky-style), install there instead of `.git/hooks/`, or warn and skip.
- Append a marked block to `{vault}/.git/hooks/post-commit` (create with shebang if missing; never touch content outside the skill's own `>>> ... <<<` block), make executable.
- Uninstall (deregister path): remove only the marked block: diff against the pre-install file must be empty.
- Hooks run outside any agent session, so skill-relative script resolution doesn't apply; both hooks stage their scripts once into `~/.config/radiant/bin/` at a fixed absolute path.

## Prune hook

Ask: "Refresh vault-report.json automatically after each commit? (optional)"

If yes: verify Python 3.10+, jq, and PyYAML are available to the hook. Install `../wiki-lint/scripts/requirements.txt` in that Python environment if needed and authorized. Copy `lint.sh`, `validate-schema.sh`, `integrity.py`, and `requirements.txt` from `../wiki-lint/scripts/` to `~/.config/radiant/bin/`, preserving script permissions and skipping identical files. If any source is missing, report the incomplete installation and skip. Install:

```bash
# >>> radiant prune >>>
if [ -f ~/.config/radiant/bin/lint.sh ]; then
  (
    bash ~/.config/radiant/bin/lint.sh >/dev/null 2>&1 || true
    R="meta/vault-report.json"
    if [ -f "$R" ] && command -v jq >/dev/null 2>&1; then
      n=$(jq '[.health[] | length] | add' "$R" 2>/dev/null || echo "?")
      echo "$(date '+%F %T') wiki-lint: report refreshed, findings=$n" >> .git/wiki-lint.log
    fi
  ) &
fi
# <<< radiant prune <<<
```

Backgrounded; logs a summary line to `.git/wiki-lint.log` each run.

## Reindex hook

Ask: "Re-index vault embeddings automatically after each commit? (recommended if semantic search is enabled)"

If yes:
1. If the old index or config still exists, follow [Index relocation](#index-relocation). If neither location has a database, run step 5 first. Continue only once `.wiki/db/vault.db` exists.
2. Copy `scripts/reindex-post-commit.sh`, `scripts/index.py`, `scripts/embeddings.py` to `~/.config/radiant/bin/` (and `bin/hooks/` for the first) if missing or different.
3. Install:

```bash
# >>> radiant reindex >>>
bash ~/.config/radiant/bin/hooks/reindex-post-commit.sh
# <<< radiant reindex <<<
```

The hook self-gates (exits if `vault.db` or `index.py` are missing, or the commit didn't touch `wiki/`), runs backgrounded, logs to `.git/radiant-reindex.log`.

## Index relocation

Use this one-time procedure when upgrading vaults from `.hot/db/` to `.wiki/db/`.

1. Identify every affected vault, including those using the shared reindex hook. Check for destination conflicts for `vault.db` and `config.json` before moving either file. If both copies of either file exist, stop and ask the user which pair to keep.
2. Get authorization for the move and for refreshing installed copies. Pause commits and close processes using either index until the move and refresh are complete.
3. In each affected vault, verify the [Git exclusion for the index](EMBEDDING-SETUP.md#git-exclusion-for-the-index). If SQLite journal, WAL, or SHM files remain in the old directory after closing the index, stop and resolve them before moving the database. Create `.wiki/db/` and move `vault.db` and its existing `config.json` there together, without overwriting. If a previous move left one file at each location, move the remaining file. Verify that the database and any existing config are now at the new location.
4. Update the installed Wiki Radiant skills through their installer. For vaults with the reindex hook enabled, refresh its shared runtime copies using step 2 above after all affected vaults are ready. Keep existing hook blocks that already call the shared script. With the updated copies in place, resume commits. If wiki changes were missed, offer to reindex the affected vaults.
