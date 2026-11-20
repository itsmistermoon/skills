---
name: mcc-coast
description: "Away mode: record your instructions, keep work moving, route decisions to issues, and log outcomes (optionally notifying your phone) until you return."
disable-model-invocation: true
argument-hint: "{instructions while away}"
---

Reply in the user's language.

## 1. Setup

Read the `## Mission control` section of the repo's `AGENTS.md`. If it is missing, run the `mcc-setup` skill first, then continue here in the same invocation.

## 2. Enter

1. If `.mcc/COAST.md` already exists, away mode is still on: keep its `since:` and `## Log`, replace `return:` and `instructions:`, and log the new instructions. Otherwise write it:

   ```
   since: <ISO 8601 timestamp with offset>
   return: <expected return, if the user gave one>
   instructions: <the user's words, verbatim; "none" if empty>

   ## Log
   ```

2. If a notify command is configured, send: away mode is on, plus a one-line gist of the instructions.
3. Read the instructions back in chat, sentence by sentence: what you will do under each, and what falls outside them.

Entry is complete when `.mcc/COAST.md` exists, the notification (if configured) went out, and the read-back is in chat.

## 3. While away

Every decision and outcome below gets one **log** line under `## Log` in `.mcc/COAST.md`: timestamp, origin, what happened, URL or path. The log is what `mcc-sitrep` reports on return. When a notify command is configured, send the same line as a notification.

- **Scope.** Act on the instructions and on authority the user already gave. Everything else waits for their return.
- **Decisions.** Open an issue labeled with the configured decision label in the repo the decision belongs to (the home repo when none fits). Title: the question. Body: context, options, your recommendation, links. Log it with the title and full URL, then continue the unblocked work.
- **Outcomes.** Log each result the user would want: a PR ready for review (full URL), a real failure, a long task finished. Work that stays pending for after the return goes to the task tracker, with its Add commands.
- **Reserved.** Merges, irreversible deletions, credentials, and security changes wait for the user's return, whatever the instructions say.
- **Replies from a channel.** With a two-way channel configured, a reply that arrives through it is the user's word on the decision it answers; away mode stays on.

## 4. Return

The user's first message typed in the terminal ends away mode: run the `mcc-sitrep` skill. It uses `since:` as its window start and deletes `.mcc/COAST.md` when done.
