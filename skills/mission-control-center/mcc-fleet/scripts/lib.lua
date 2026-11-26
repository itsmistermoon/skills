-- Shared by the scripts. Rex runs them with `rex do`,
-- so they need nothing but rex.
local lib = {}

lib.windows = package.config:sub(1, 1) == "\\"
lib.sep = lib.windows and "\\" or "/"
lib.dir = debug.getinfo(1, "S").source:gsub("^@", ""):match("^(.*[/\\])")

-- Rex tells every agent to name its session when its first task arrives.
-- The session and its tabs belong to the user, and tab labels are how agents
-- find each other, so every launch prompt and message says this.
lib.rule = "Don't rename the Rex session or your tab."

-- Agent sandboxes usually let programs write to /tmp.
lib.root = (lib.windows and os.getenv("TEMP") or "/tmp") .. lib.sep .. "rex-fleet"

function lib.path(...)
  return table.concat({ lib.root, ... }, lib.sep)
end

-- Lua can't make folders, so ask the OS.
function lib.mkdir(path)
  local argv = lib.windows and { "cmd", "/c", "if", "not", "exist", path, "mkdir", path } or { "mkdir", "-p", path }
  assert(assert(rex.exec(argv)).ok, "can't make " .. path)
end

function lib.read(path)
  local f = assert(io.open(path))
  local text = f:read("*a")
  f:close()
  return text
end

function lib.write(path, text)
  local f = assert(io.open(path, "w"))
  assert(f:write(text))
  assert(f:close())
end

function lib.call(method, args)
  return assert(rex.call(method, args))
end

-- Git runs on the machine running this script, like the task files.
function lib.worktree(cwd)
  local opts = { timeout = 2, env = { GIT_DIR = false, GIT_WORK_TREE = false, GIT_COMMON_DIR = false } }
  local r = rex.exec({ "git", "-C", cwd, "rev-parse", "--absolute-git-dir", "--path-format=absolute", "--git-common-dir", "--show-toplevel" }, opts)
  if not r or not r.ok then return end
  local gitdir, common, root = r.stdout:gsub("\r\n", "\n"):match("^([^\n]+)\n([^\n]+)\n([^\n]+)\n$")
  if not root or gitdir == common then return end
  local branch = rex.exec({ "git", "-C", cwd, "symbolic-ref", "--quiet", "--short", "HEAD" }, opts)
  return {
    path = root,
    branch = branch and branch.ok and branch.stdout:gsub("[\r\n]+$", "")
      or (branch and branch.code == 1 and "detached HEAD" or "unknown"),
  }
end

-- The agent running this script.
function lib.me()
  local session, block = os.getenv("REX_SESSION"), os.getenv("REX_BLOCK")
  -- Agent shells (Claude Code, Codex) keep REX_BLOCK but drop REX_SESSION: ask Rex for the session that holds the block.
  if session == "" then session = nil end
  if not session and block then
    local r = rex.exec({ "rex", "whoami", "--json" })
    session = r and r.ok and r.stdout:match('"session_id"%s*:%s*"([^"]+)"')
  end
  return assert(session, "run this inside a Rex terminal"), block
end

-- A script must attach to a session before it can act on it.
function lib.attach(session)
  lib.call("session.attach", { session_id = session })
end

-- Every block in a session, with its tab and pane labels.
function lib.blocks(session)
  lib.attach(session)
  local out = {}
  for _, window in ipairs(lib.call("session.view", { session_id = session }).windows) do
    local blocks = {}
    for _, layer in ipairs(window.layers) do
      for _, block in ipairs(layer.blocks) do blocks[#blocks + 1] = block end
    end
    for _, block in ipairs(blocks) do
      out[#out + 1] = { id = block.block_id, tab = window.label or "", pane = block.label or "", split = #blocks > 1 }
    end
  end
  return out
end

-- An agent goes by its pane's label in a split tab, and by its tab's label
-- otherwise. Rex labels an unnamed pane "shell".
function lib.name(block)
  if block.split and block.pane ~= "shell" then return block.pane end
  return block.tab
end

-- Paste one line into a terminal, then press Enter. A paste event lets the
-- program tell the text from the Enter that submits it.
function lib.paste_line(session, block, text)
  lib.call("block.event", { session_id = session, block_id = block, event = { type = "paste", payload = { text = text } } })
  for _, action in ipairs({ "press", "release" }) do
    lib.call("block.event", { session_id = session, block_id = block, event = { type = "key", payload = {
      key = "enter", mods = "", consumed_mods = "", text = "\r", unshifted_codepoint = 13, composing = false, action = action,
    } } })
  end
end

-- True when the terminal's input holds text someone is typing. The input
-- starts at the last line with a prompt mark (❯ Claude Code and shells,
-- › Codex) and runs to Claude's box border (─) or, for Codex, the first blank
-- line: a person may leave the prompt line empty and type below it.
-- No prompt mark on screen means nothing to protect.
local function visible(raw)
  -- VT keeps styling: a placeholder (Codex "Ask Codex to do anything") is dim text, not input.
  return (raw:gsub("\27%[2m.-\27%[[02]*m", ""):gsub("\27%[[%d;?]*[%a@]", ""):gsub("\194\160", " "))
end

function lib.input_has_text(screen)
  local lines = {}
  for raw in screen:gmatch("[^\r\n]*") do lines[#lines + 1] = visible(raw) end
  local at, mark
  for i, line in ipairs(lines) do
    if line:match("^%s*❯") then at, mark = i, "❯" elseif line:match("^%s*›") then at, mark = i, "›" end
  end
  if not at then return false end
  if lines[at]:match("^%s*" .. mark .. "(.*)$"):match("%S") then return true end
  for i = at + 1, #lines do
    local line = lines[i]
    if line:match("^%s*─") then return false end
    if mark == "›" and not line:match("%S") then return false end
    if line:match("%S") then return true end
  end
  return false
end

function lib.input_pending(session, block)
  local r = rex.exec({ "rex", "capture", "-s", session, "-b", block, "--format=vt" })
  if not (r and r.ok) then return true end
  return lib.input_has_text(r.stdout)
end

-- Mensajes y alarmas comparten la misma espera y comprobación de entrada.
function lib.send_guarded(session, block, text, tries)
  tries = tonumber(tries or 20)
  local function quiet()
    if lib.input_pending(session, block) then return false end
    rex.exec({ "sleep", "2" })
    return not lib.input_pending(session, block)
  end
  while not quiet() do
    if tries <= 0 then
      local path = os.tmpname() .. "-send.txt"
      lib.write(path, text .. "\n")
      error("entrada ocupada en " .. tostring(block) .. "; mensaje guardado en " .. path .. ". Reintenta más tarde.")
    end
    tries = tries - 1
    rex.exec({ "sleep", "3" })
  end
  lib.paste_line(session, block, text)
  rex.exec({ "sleep", "1" })
  if lib.input_pending(session, block) then
    error("la entrada de " .. tostring(block) .. " no quedó vacía tras enviar; revisa con rex capture")
  end
  print("enviado al panel " .. tostring(block))
end

-- Single quotes keep every character literal in POSIX shells.
function lib.quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- The command that sends a message to a terminal, for pasting into prompts.
function lib.send_command(session, block, message)
  return "rex do " .. lib.quote(lib.dir .. "send.lua") .. " session=" .. lib.quote(session)
    .. " block=" .. lib.quote(block) .. " message=" .. lib.quote(message)
end

function lib.header(from_session, from_block)
  local from
  for _, block in ipairs(lib.blocks(from_session)) do
    if block.id == from_block then from = lib.name(block) end
  end
  local reply = lib.send_command(from_session, from_block, "<reply>")
  return "[from " .. from .. ", who can't see this screen. " .. lib.rule .. " Reply by running: " .. reply .. "] "
end

return lib
