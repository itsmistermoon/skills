package.path = package.path
rex = { exec = function() return {ok=false} end }
local lib = dofile(arg[0]:match("^(.*/)") .. "../scripts/lib.lua")
local E = "\27"
local cases = {
  {"claude vacío", "x\n"..E.."[0m❯\194\160"..E.."[0m\n────────\n  Sonnet 5.5", false},
  {"claude texto", "x\n"..E.."[0m❯\194\160"..E.."[0mduda\n────\n  Sonnet", true},
  {"claude primera línea vacía, texto abajo", "x\n"..E.."[0m❯\194\160"..E.."[0m\n  duda de moon\n────\n  Sonnet", true},
  {"claude dos vacías y texto", "❯ \n\n  duda\n────", true},
  {"codex placeholder", E.."[1m›"..E.."[0m "..E.."[2mAsk Codex to do anything"..E.."[0m\n\n  GPT-6.1-Sol low · 5h", false},
  {"codex texto", "› hola\n\n  GPT", true},
  {"sin prompt", "nada aquí", false},
}
local bad = 0
for _, c in ipairs(cases) do local got = lib.input_has_text(c[2]); print((got == c[3]) and "ok " or "MAL", c[1], got); if got ~= c[3] then bad = bad + 1 end end
local function check(label, condition)
  print(condition and "ok" or "MAL", label)
  if not condition then bad = bad + 1 end
end
check("captura fallida ocupa la entrada", lib.input_pending("session", "block"))
rex.exec = function() return nil end
check("captura ausente ocupa la entrada", lib.input_pending("session", "block"))
local captures, pasted = 0, 0
rex = {
  args = {worker=true, ["in"]=1, session="session", block="block", message="recordatorio", wait=0},
  call = function(method) if method == "block.event" then pasted = pasted + 1 end; return {} end,
  exec = function(argv)
    if argv[2] == "capture" then captures = captures + 1; return {ok=false} end
    return {ok=true}
  end,
  after = function(_, callback) callback() end,
}
local ok = pcall(dofile, arg[0]:match("^(.*/)") .. "../scripts/alarm.lua")
check("alarma protege entrada desconocida", not ok and pasted == 0 and captures > 0)
os.exit(bad)
