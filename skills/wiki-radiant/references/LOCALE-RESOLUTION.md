# Locale resolution

Reference for skills that write persistent content to the vault. Read when a step says "locale resolution: see LOCALE-RESOLUTION.md".

Skills that generate content stored in the vault must write it in the vault's own language, not default to the agent's training language or whatever language the current conversation happens to be in: content written today is read by a different agent, in a different session, possibly in a different language, later. Getting this wrong means a vault silently accumulates mixed-language pages that degrade retrieval and readability over time.

## Resolution

Read `locale:` from the vault's entry in `~/.config/radiant/config.yml`. Use it for all agent-generated content.

If the entry has no locale, use `en`. Local session handoffs outside a registered vault use the conversation language, as specified by hot-handoff.
