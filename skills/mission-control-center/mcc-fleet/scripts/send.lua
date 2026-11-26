-- Paste a one-line message into another agent's Rex terminal and submit it.
--
--   rex do <skill>/scripts/send.lua session=SESSION block=BLOCK message='MESSAGE'
--
-- BLOCK is the block ID of the other agent's terminal. team.lua prints this
-- command, filled in, for each agent in your session.
-- The message arrives as
--   [from <your name>, who can't see this screen. <rule> Reply by running: <command>] MESSAGE
-- so the other agent knows who wrote and how to answer, even if it has never
-- (When the other terminal's prompt holds typed text, send.lua waits up to
-- wait=N tries of 3 s, default 20, then fails and saves the message.)
-- heard of this skill. Without "can't see this screen", agents tend to answer
-- in their own pane, where nobody reads it.
local lib = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):match("^(.*[/\\])") .. "lib.lua")
local session, block = rex.args.session, rex.args.block
local message = tostring(assert(rex.args.message, "usage: send.lua session=SESSION block=BLOCK message='MESSAGE'"))
-- A newline would submit half the message.
assert(not message:find("[\r\n]"), "the message must be one line; put longer text in a file and send its path")

local header = lib.header(lib.me())
lib.attach(session)
-- Never paste over someone typing: wait for the prompt to empty, then give up
-- with the message saved, so the sender retries later.
local tries = tonumber(rex.args.wait or "20")
while lib.input_pending(session, block) do
  if tries <= 0 then
    local path = os.tmpname() .. "-send.txt"
    local f = assert(io.open(path, "w")); f:write(header .. message, "\n"); f:close()
    error("send.lua: entrada ocupada en " .. tostring(block) .. "; mensaje guardado en " .. path .. ". Reintenta más tarde.")
  end
  tries = tries - 1
  rex.exec({ "sleep", "3" })
end
lib.paste_line(session, block, header .. message)
-- Confirm delivery so the sender knows the message arrived.
print("send.lua: entregado en " .. tostring(block))
