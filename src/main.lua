package.path = package.path .. ";./src/?.lua"

local parser = require("parser")
local glushkov = require("conversions.glushkov")
local fa = require("fa")
local utils = require("utils")
local ast = require("ast")

utils.debug_enabled = false

local args = { ... }

if #args < 2 then
    io.stderr:write([[
Usage:
  regex dot ast|nfa|dfa 'regex'
  regex run 'regex' 'input'
]])
    os.exit(1)
end

local command = args[1]

if command == "dot" then
    local stage = args[2]
    local regex_str = args[3]
    if not regex_str then
        io.stderr:write("Missing regex for 'dot'\n")
        os.exit(1)
    end

    local regex = parser:parse(regex_str)
    local dot = nil

    if stage == "ast" then
        dot = ast.to_dot(regex)
    else
        local nfa = glushkov.glushkov(regex)
        if stage == "nfa" then
            dot = fa.to_dot(nfa)
        elseif stage == "dfa" then
            local dfa = fa.determinize(nfa)
            dot = fa.to_dot(dfa)
        else
            io.stderr:write("Unknown stage: " .. stage .. "\n")
            os.exit(1)
        end
    end

    print(dot)
elseif command == "run" then
    local regex_str = args[2]
    local input = args[3]
    if not regex_str or not input then
        io.stderr:write("Usage: regex run 'regex' 'input'\n")
        os.exit(1)
    end

    local regex = parser:parse(regex_str)
    local nfa = glushkov.glushkov(regex)
    local dfa = fa.determinize(nfa)

    local ok = fa.simulate(dfa, input)
    if ok then
        os.exit(0)
    else
        os.exit(1)
    end
else
    io.stderr:write("Unknown command: " .. command .. "\n")
    os.exit(1)
end
