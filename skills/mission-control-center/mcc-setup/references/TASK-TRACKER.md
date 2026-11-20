# Task tracker

The task tracker is where pending work lives between sessions: the flight's open items, carried from one shift to the next. Every mcc skill that reads or changes pending work resolves it here.

## Resolve

Read the `Task tracker:` line in the `## Mission control` section of `AGENTS.md`. Without that line, the tracker is `handover`.

## handover

The `### Pending` list in `.mcc/HANDOVER.md`. List reads the list; Add appends an item; Close removes it.

Limits: at most five tasks, plus at most two imprint candidates (items titled `Imprint:`). Candidates never take a task's place: when a new task would make six, drop or merge the least live task and report the displaced action; when a new candidate would make three, drop the oldest candidate and report it.

## External tracker

Any other tool. `docs/agents/task-tracker.md` holds the exact commands for this repo under three headings:

- `## List`: show the open tasks.
- `## Add`: create a task, with its labels or links.
- `## Close`: complete or drop a task, with a one-line result.

Run those commands as written: they are the whole contract, so switching tools means rewriting only that file. `.mcc/HANDOVER.md` keeps a single Pending line, `- Task tracker: <tool> (docs/agents/task-tracker.md)`.
