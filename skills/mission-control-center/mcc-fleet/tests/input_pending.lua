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
os.exit(bad)
