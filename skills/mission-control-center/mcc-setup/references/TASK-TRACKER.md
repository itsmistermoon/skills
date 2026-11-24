# Task tracker

The task tracker is where pending work lives between sessions: the flight's open items, carried from one shift to the next. Every mcc skill that reads or changes pending work resolves it here.

## Triage

Every task Added carries one triage label. `ready-for-agent`: fully specified, an agent can finish it unattended. `ready-for-human`: it needs the user, for a decision, an approval, an outward-facing action, or work only they can do. The label says who can take the task, not when: a task blocked by another task or a date keeps its label and is taken once unblocked.

## Resolve

Read the `Task tracker:` line in the `## Mission control` section of `AGENTS.md`. Without that line, the tracker is `handover`.

## handover

The `### Pending` list in the base repo's `.mcc/HANDOVER.md`. List reads only items for repos in scope; Add appends an item, prefixed with its triage label in brackets (`[ready-for-agent]`) and the repo path; Close removes it. Legacy items without a repo path belong to the base repo. This tracker cannot route an item to an out-of-scope repo's channel: report it as uncaptured instead.

Limit: at most five tasks. When a new task would make six, drop or merge the least live task and report the displaced action.

## External tracker

Any other tool. `docs/agents/task-tracker.md` holds the exact commands for this repo under three headings:

- `## List`: show the open tasks, and the ready ones per triage label, filtered to the repos in the resolved scope.
- `## Add`: create a task in the relevant repo or channel with its triage label, plus any other labels or links.
- `## Close`: complete or drop a task, with a one-line result.

Run those commands as written: they are the whole contract, so switching tools means rewriting only that file. `.mcc/HANDOVER.md` keeps a single Pending line, `- Task tracker: <tool> (docs/agents/task-tracker.md)`.
