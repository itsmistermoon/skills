# Changes from claude-plugins-official/telegram 0.0.7

Upstream request: https://github.com/anthropics/claude-plugins-official/issues/836

- **Topics in and out.** Inbound messages carry `message_thread_id`, `topic` (topic name), and `quoted` (text of the message being replied to). `reply` takes `message_thread_id`; text and files stay in that topic. The server instructions tell the session to reply in-topic and sign with `[<topic>]`.
- **Routing by repo.** Every session started with the channel claims its repo key: the basename of the main git repo of its project dir (worktrees count as their repo). One session, the leader, polls the bot and routes each message by topic name: to a live session with that key, else to the home key (`TELEGRAM_HOME_KEY`, default `moonbase`). Other sessions read their spool under `$TELEGRAM_STATE_DIR/spool/<key>/`. When the leader exits, another session takes over within 5 s. The home session also drains General and spools of keys with no live session.
- **Shared topic registry.** `TELEGRAM_TOPICS_FILE` (default `$TELEGRAM_STATE_DIR/topics.tsv`, lines `name<TAB>thread_id`) maps topic ids to names; `notify-telegram.sh` writes it when it creates a topic.
- **Permission replies** (text or buttons) are broadcast to every live session; each ignores request ids it does not own.
