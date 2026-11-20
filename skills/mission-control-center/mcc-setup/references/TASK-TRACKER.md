# Task tracker

The task tracker is where pending work lives between sessions: the flight's open items, carried from one shift to the next. Every mcc skill that reads or changes pending work resolves it here.

## Resolve

Read the `Task tracker:` line in the `## Mission control` section of `AGENTS.md`. Without that line, the tracker is `handoff`.

## handoff

The `### Pending` list in `.mcc/HANDOFF.md`, at most five items. List reads the list; Add appends an item; Close removes it. When a new item would make six, drop or merge the least live one and report the displaced action.

## External tracker

Any other tool. `docs/agents/task-tracker.md` holds the exact commands for this repo under three headings:

- `## List`: show the open tasks.
- `## Add`: create a task, with its labels or links.
- `## Close`: complete or drop a task, with a one-line result.

Run those commands as written: they are the whole contract, so switching tools means rewriting only that file. `.mcc/HANDOFF.md` keeps a single Pending line, `- Task tracker: <tool> (docs/agents/task-tracker.md)`.
