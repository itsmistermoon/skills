# METHODOLOGY.md: Agentic development workflow

Shared working methodology for all projects under `/proyectos`.
Every agent working in a repo under `/proyectos` must follow this workflow.

**Installing the skills:** `npx skills add mattpocock/skills`

---

## 0. Decision table: which skill to use when

Consult this table whenever you are unsure what to invoke next.

| Situation | Skill to use |
|---|---|
| A decision is needed that is **not** about a codebase (plan, idea, personal decision) | `/grill-me` (§2.1) |
| A decision is needed about a codebase, and the scope fits in one session | `/grill-with-docs` (§2.1) |
| The work is too large for one session (risk of losing context between sessions) | `/wayfinder` (§2.2) |
| The key question is "what does it look like?" or "how does it behave?" before committing to a spec | `/prototype` (§2.3) |
| Something external must be researched without interrupting the active session | `/research` (§3.3) |
| A shared context already exists (grilling closed or Wayfinder map resolved) and the spec is missing | `/to-spec` (§2.4) |
| There is a spec and it must be split into executable work | `/to-tickets` (§2.5) |
| A specific ticket needs to be executed | `/implement` (§2.6) |
| Implementation is finished and the result must be verified | `/code-review` (§2.7) |
| An issue from someone else arrived (it was not grilled by this workflow) and it is unclear whether it can be worked yet | `/triage` (§3.1) |
| The codebase must be aligned with decisions already made (CONTEXT.md, ADRs) or architectural debt must be resolved | `/improve-codebase-architecture` (§3.2) |
| This workflow is being installed in a repo, new or existing | `/setup-matt-pocock-skills` (§4) |
| Tickets are on the "frontier" (blockers resolved; requires a real tracker: see §2.5) and continuous autonomous execution is appropriate | Ralph loop (§2.8) |

---

## 1. Why this workflow

It replaces direct "plan mode" with explicit stages that each have a verifiable artifact of their own: it separates architecture decisions from facts explored in the code, lets large work be split across sessions or agents without losing context, keeps refactoring out of implementation, and makes review measure against an objective standard (spec + coding standards) instead of the agent's impression.

---

## 2. The main flow

Grilling (→ Wayfinder if large) → Spec → Tickets → Implement → Code Review. Details for each stage are below; to know what to invoke at any moment, use the table in §0.

### 2.1 Grilling

`/grill-me` for non-codebase decisions; `/grill-with-docs` for codebase decisions (it also generates `CONTEXT.md`/ADRs via `/domain-modeling`). Both run a `/grilling` session: the session protocol (one question at a time, Fact/Decision, confirmation gate) lives in that skill.

### 2.2 Wayfinder (large plans)

For work too large for a single grilling session: `/wayfinder` maps the work as tickets in the issue tracker and resolves them one at a time. When the map is closed, that information becomes a spec via `/to-spec`. Especially recommended for frontend work (see §2.3).

### 2.3 Prototyping (support for grilling/wayfinder)

`/prototype`: a cheap artifact to answer *"what does it look like?"* or *"how does it behave?"* before committing to a spec. The model can invoke it on its own. Essential for almost anything that touches the frontend.

### 2.4 Spec

The closed grilling (or the resolved Wayfinder map, see §2.2) becomes a spec via `/to-spec`, without a new interview: it only synthesizes what was already discussed. Continue with §2.5.

### 2.5 Tickets

The spec is broken down into tickets via `/to-tickets`. When the tracker supports native blocking links ("real tracker": see §4), tickets with no pending blockers sit on the "frontier": the point where it makes sense to switch to the Ralph loop (see §2.8).

### 2.6 Implement

Per ticket, in its own session, via `/implement`: which in turn uses `/tdd` (red→green; refactoring is handled in code review) and ends by invoking `/code-review`.

### 2.7 Code Review

`/code-review` reviews the diff since a fixed point (commit, branch, tag, or merge-base) along two axes in parallel: Standards and Spec, reporting them separately without merging findings.

### 2.8 Ralph loop (autonomous / AFK)

A single prompt that repeats until the available work is exhausted. Use it when tickets are on the "frontier" (see §2.5) and per-ticket supervision is not needed: on each pass it takes the next frontier ticket, implements it (`/implement`), runs tests and type checks, commits, and repeats until no tickets remain available.

Recommended progression: HITL (pair programming with the agent) first; AFK (autonomous) afterwards, once the workflow has been validated without constant supervision.

---

## 3. Outside the main flow

Skills that are not part of the linear Grilling → Implement sequence, but belong to the same stack and are invoked depending on the situation (see the table in §0).

### 3.1 Triage (external issue backlog)

For issues or PRs created by others (not products of this grilling workflow). Moves them through their category/state roles until they are ready for an agent or a human.

**Use when** an external issue comes in: it must be triaged before being assigned to implementation.

### 3.2 Improve codebase architecture

Uses the shared vocabulary of `/codebase-design` and `CONTEXT.md`/ADRs to propose refactors.

**Use when** architectural debt has accumulated or the codebase has drifted from its documented language.

### 3.3 Research

Investigates in the background without interrupting the active session. Can be invoked from a Research-type Wayfinder ticket.

---

## 4. How to adopt this in a project (new or existing)

1. If the repo already has an `AGENTS.md`/`CLAUDE.md` with a documented workflow, read it first: do not assume the repo is empty. Decide explicitly whether this methodology replaces it, merges with it, or coexists with it, and record that decision in the file itself.
2. Copy this file (`METHODOLOGY.md`) to the root of the repo from which this adoption is invoked.
3. Verify that `~/.claude/skills/` contains `grill-me`, `grill-with-docs`, `wayfinder`, `to-spec`, `to-tickets`, `implement`, `code-review`, `tdd`, `research`, `prototype`, `triage`, `improve-codebase-architecture`, `setup-matt-pocock-skills`.
4. Run `/setup-matt-pocock-skills`: it explores the repo and asks before writing anything (it does not assume the repo is empty or overwrite an already-configured tracker). It configures per repo: issue tracker (GitHub, GitLab, local markdown, or custom), triage labels, domain docs.
5. Add to the project's `AGENTS.md`/`CLAUDE.md`:
   ```
   ## Working methodology
   Follow METHODOLOGY.md at the root of this repo. If it does not exist in this environment, tell the user and use the repo's native workflow instead.
   ```
   If the repo already has coding standards or its own conventions, reference them there so that `/implement` and `/code-review` respect them.
6. If the repo has no real tracker connected (as defined by step 4), use the local-file variant (`tickets.md`) for `/to-tickets`.
