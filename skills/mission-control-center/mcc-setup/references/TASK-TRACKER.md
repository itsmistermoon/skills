# Task tracker

Every mcc skill that reads or changes pending work resolves the task tracker here.

## Triage

Every task Added carries one triage label. `ready-for-agent`: fully specified, an agent can finish it unattended. `ready-for-human`: it needs the user, for a decision, an approval, an outward-facing action, or work only they can do. The label says who can take the task, not when: a task blocked by another task or a date keeps its label and is taken once unblocked.

## Resolve

Read the `Task tracker:` line in the `## Mission control` section of `AGENTS.md`. Without that line, the tracker is `handover`.

## handover

The `### Pending` list in the base repo's `.mcc/HANDOVER.md`. List reads items for repos in scope and previously routed external items; Add appends an item, prefixed with its triage label in brackets (`[ready-for-agent]`) and destination repo path, including for an out-of-scope repo. This makes external work visible to the base repo's owner. Close removes it. Legacy items without a repo path belong to the base repo.

Limit: at most five tasks. When a new task would make six, drop or merge the least live task and report the displaced action.

## External tracker

Any other tool. `docs/agents/task-tracker.md` holds commands under three headings. List and Add accept a `<channel>` parameter, mapped from the destination repo path to its channel by the document's instructions:

- `## List`: show the open tasks, and the ready ones per triage label, for `<channel>`. Run once for each repo in the resolved scope.
- `## Add`: create a task in `<channel>` with its triage label, plus any other labels or links. Run for each destination repo, including outside scope.
- `## Close`: complete or drop a task, with a one-line result.

Substitute the destination channel in those commands: they are the whole contract, so switching tools means rewriting only that file. `.mcc/HANDOVER.md` keeps a single Pending line, `- Task tracker: <tool> (docs/agents/task-tracker.md)`.
