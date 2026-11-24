-- Launch a subagent in a background Rex tab and tell it how to report back.
--
--   rex do <skill>/scripts/spawn.lua name=NAME cwd=DIR task=FILE command="AGENT [ARGS...]" [depth=N] [notify=file]
--
-- command starts the agent CLI; its words are split on spaces. A {prompt}
-- word is replaced with the agent's first prompt; without one, the prompt
-- follows the executable. depth is how many levels of subagents it may start below
-- itself (default 0). notify=file: the subagent only writes result.md and the
-- parent watches for it, so no message is typed into the parent's terminal.
local lib = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):match("^(.*[/\\])") .. "lib.lua")
local a = rex.args
assert(a.name and a.cwd and a.task and a.command, 'usage: spawn.lua name=NAME cwd=DIR task=FILE command="AGENT [ARGS...]" [depth=N]')
local depth = a.depth or 0
local task = lib.read(a.task)
local session, me = lib.me()
lib.attach(session)

-- A subagent's depth is kept in a file named after its terminal, since
-- that's all spawn.lua knows about whoever runs it. Agents the user starts
-- have none, so they have no limit.
local function depth_file(block) return lib.path("depth", (block:gsub("^block:", ""))) end
local mine = io.open(depth_file(me))
if mine then
  local allowed = tonumber(mine:read("*l"))
  mine:close()
  assert(allowed > 0, "your parent didn't allow you to start subagents; do the task yourself or report blocked")
  depth = math.min(depth, allowed - 1)
end

-- Resolve cwd the way a program in this terminal would, so . and ~ work.
local dir = lib.call("block.method", { session_id = session, block_id = me, method = "list_dir", args = { path = tostring(a.cwd), limit = 1 } })
assert(dir.status == "ok", tostring(a.cwd) .. " isn't a folder")
local worktree = lib.worktree(dir.path)
if a.prepare then
  local r = assert(rex.exec({ tostring(a.prepare), dir.path, tostring(a.base or "") }))
  assert(r.ok, "backend prepare failed: " .. tostring(r.stderr or ""))
end

local roots = {}
for path in tostring(a.writable or ""):gmatch("[^,]+") do
  local probe = assert(rex.exec({ "test", "-e", path .. "/.git" }))
  assert(not probe.ok, "writable=" .. path .. " contains .git")
  roots[#roots + 1] = path
end
if worktree then
  local function git_path(flag)
    local r = assert(rex.exec({ "git", "-C", dir.path, "rev-parse", "--path-format=absolute", flag }))
    assert(r.ok, "cannot resolve git metadata")
    return r.stdout:gsub("%s+$", "")
  end
  local gitdir, common = git_path("--git-dir"), git_path("--git-common-dir")
  for _, path in ipairs({ gitdir, common .. "/objects", common .. "/refs/heads", common .. "/logs/refs/heads" }) do roots[#roots + 1] = path end
end

-- Every parent shares the folder, so a random suffix keeps two subagents
-- with the same name apart.
math.randomseed(os.time() + os.clock() * 1e6)
local suffix = ""
for _ = 1, 4 do suffix = suffix .. string.char(math.random(97, 122)) end
local task_id = a.name .. "-" .. os.date("%Y%m%d-%H%M%S") .. "-" .. suffix
local task_dir = lib.path("tasks", task_id)
local prompt, result = lib.path("tasks", task_id, "prompt.md"), lib.path("tasks", task_id, "result.md")
local close_file = lib.path("tasks", task_id, "close.md")
lib.mkdir(task_dir)
lib.mkdir(lib.path("depth"))
local tracker_instructions = ""
if a.tracker then
  local r = assert(rex.exec({ tostring(a.tracker), "init", task_dir, a.name, dir.path, a.task, result }))
  assert(r.ok, "backend tracker init failed: " .. tostring(r.stderr or ""))
  tracker_instructions = r.stdout or ""
end

local launch_prompt = "You are a subagent. " .. lib.rule .. " Read " .. prompt .. " and follow it."
local argv, placed = {}, false
for word in tostring(a.command):gmatch("%S+") do
  if word == "{prompt}" then word, placed = launch_prompt, true end
  argv[#argv + 1] = word
end
-- Without {prompt}, the prompt goes right after the program, never
-- last, so a flag that takes several values (claude's --add-dir) can't
-- swallow it.
if not placed then table.insert(argv, 2, launch_prompt) end
if argv[1]:match("codex$") and #roots > 0 then
  local quoted = {}
  for _, path in ipairs(roots) do quoted[#quoted + 1] = '"' .. path:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"' end
  table.insert(argv, 2, "sandbox_workspace_write.writable_roots=[" .. table.concat(quoted, ",") .. "]")
  table.insert(argv, 2, "-c")
end
-- Rex trims leading whitespace; a zero-width space preserves the indent.
local indent_marker = "\226\128\139"
local function level(label)
  local indent = (label or ""):gsub("^" .. indent_marker, ""):match("^( *)↳")
  return indent and #indent / 4 + 1 or 0
end
local windows = lib.call("session.view", { session_id = session }).windows
local parent
for i, w in ipairs(windows) do
  for _, layer in ipairs(w.layers) do
    for _, b in ipairs(layer.blocks) do
      if b.block_id == me then parent = i end
    end
  end
end
local parent_level = parent and level(windows[parent].label) or 0
local label = indent_marker .. ("    "):rep(parent_level) .. "↳ " .. a.name .. (worktree and " (w)" or "")

-- The notice spells out the parent's next steps, because a parent that
-- compacted while the subagent worked may have lost the skill's instructions.
local report = lib.read(lib.dir .. "report.md"):gsub("{(%w+)}", {
  result = result,
  checkout = dir.path,
  worktree = worktree and ("Linked worktree: " .. worktree.path .. "\nBranch at launch: " .. worktree.branch) or "",
  notify = a.notify == "file"
    and "The parent watches for delivery; do not message it."
    or "Notify the parent by running this command (put your status in place of STATUS):\n   "
      .. lib.send_command(session, me, task_id .. " STATUS. Read " .. result
        .. ". If it's completed and checks out, run the close command in " .. close_file
        .. ". Then wait for any other subagents you started.")
      .. "\n   If it fails with a sandbox or permission error, ask for permission to run it outside the sandbox.",
  nesting = depth > 0
    and ("You may start subagents of your own with the mcc-fleet skill, up to " .. depth .. " level(s) below you. Report only after they have reported to you.")
    or "Do this task yourself. You can't start subagents.",
})
-- A subagent can read immediately when new_window starts its command.
lib.write(prompt, task .. "\n\n" .. report .. "\n\n" .. tracker_instructions)

local created = lib.call("session.new_window", {
  session_id = session,
  window_label = label,
  focus = false,
  layout = rex.layout.block{
    flavor = "com.superlogical.terminal.shell",
    options = { command = argv, cwd = dir.path, exit = { on_completion = false } },
  },
})
local window, block = created.window_id, created.block_ids[1]
lib.write(depth_file(block), depth .. "\n")
lib.write(close_file, "rex window close -s " .. session .. " " .. window .. "\n")

-- Rex adds new tabs at the end. Move this one after the parent and the
-- subagents already under it (the deeper tabs that follow it). This runs last
-- and may fail, for example if that tab just closed: the tab then stays at
-- the end, and the subagent still has everything it needs.
local next_tab = (parent or #windows) + 1
while windows[next_tab] and level(windows[next_tab].label) > parent_level do
  next_tab = next_tab + 1
end
if windows[next_tab] then
  rex.call("session.move_window", { session_id = session, window_id = window, before_window_id = windows[next_tab].window_id })
end

print("task: " .. task_id)
print("folder: " .. task_dir)
print("tab: " .. window)
print("result: " .. result)
if worktree then
  print("branch: " .. worktree.branch)
  print("worktree: " .. worktree.path)
end
print("message it: " .. lib.send_command(session, block, "MESSAGE"))
print("watch: " .. lib.quote(lib.dir .. "watch.sh") .. " " .. lib.quote(session) .. " " .. lib.quote(block) .. " " .. lib.quote(result) .. " 900" .. (a.tracker and (" " .. lib.quote(a.tracker) .. " " .. lib.quote(task_dir)) or ""))
