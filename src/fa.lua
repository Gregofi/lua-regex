local _M = {}
local utils = require("utils")

--- @class NFA
--- @field states NFAState[]
--- @field start integer
--- @field accept integer[]  -- set of accepting states
--- @field alphabet string[]

--- @class NFAState
--- @field transitions table<string, table<integer>>  -- char -> set of next states

--- @class DFA
--- @field states DFAState[]
--- @field start integer
--- @field accept integer[]
--- @field alphabet string[]

--- @class DFAState
--- @field transitions table<string, integer> -- char -> next state

--- Creates a new NFA.
--- @return NFA
function _M.new_nfa()
    return {
        states = { { transitions = {} } },
        start = 1,
        accept = {},
        alphabet = {},
    }
end

--- Converts FA to string that represents the machine in DOT
--- @param nfa NFA|DFA
--- @return string
function _M.to_dot(nfa)
    local lines = {}
    table.insert(lines, "digraph NFA {")
    table.insert(lines, "  rankdir=LR;")
    table.insert(lines, "  node [shape = circle];")

    table.insert(lines, string.format("  start [shape=point];"))
    table.insert(lines, string.format("  start -> %d;", nfa.start))

    for _, val in ipairs(nfa.accept) do
        if nfa.states[val] then
            table.insert(lines, string.format("  %d [shape=doublecircle];", val))
        end
    end

    for id, state in pairs(nfa.states) do
        for matcher_id, targets in pairs(state.transitions) do
            local targets = targets
            if type(targets) == "number" then
                targets = { targets } -- Ensure targets is a table
            end
            for _, to_id in ipairs(targets) do
                table.insert(lines, string.format('  %d -> %d [label="%s"];', id, to_id, matcher_id))
            end
        end
    end

    table.insert(lines, "}")
    return table.concat(lines, "\n")
end

--- Converts NFA to DFA
--- @param nfa NFA
--- @return DFA
---
--- NFA can be in multiple states at once.
--- In converting NFA to DFA, we simulate this
--- with states. Instead of state A, B, C,
--- we will have states like {A, B}, which corresponds
--- to NFA being in state A and B.
--- Note that there can be a lot of states
--- (2^n = number of subsets of size n)
function _M.determinize(nfa)
    assert(nfa.start == 1)
    -- States in the new NFA. It contains set of states ({1, 3, 4} is one
    -- member). It is an indexed set, and each index is the ID of the state.
    local dfa_states = { { nfa.start } }
    -- A map of (Idx,Char) -> Idx, where Idx is the ID of the state
    -- from `state_set`.
    local transitions = {}

    --- Stack of group of states that have not yet been processed.
    --- We start with the starting state
    --- @type table<integer[]>
    local pending = { 1 }

    while #pending ~= 0 do
        local curr_node_idx = table.remove(pending)
        local curr_nodes = dfa_states[curr_node_idx]
        utils.debug(
            "Processing DFA state: "
                .. tostring(curr_node_idx)
                .. " with nodes from NFA: {"
                .. table.concat(curr_nodes, ", ")
                .. "}"
        )

        for _, char in ipairs(nfa.alphabet) do
            local transitions_for_char = {}
            for _, nfa_idx in ipairs(curr_nodes) do
                utils.debug(
                    "    Processing char: '"
                        .. char
                        .. "' for state: "
                        .. tostring(curr_node_idx)
                        .. ", nfa index: "
                        .. nfa_idx
                )
                local nfa_node = nfa.states[nfa_idx]
                local dests = nfa_node.transitions[char] or {}
                for _, dest in ipairs(dests) do
                    if not utils.contains(transitions_for_char, dest) then
                        table.insert(transitions_for_char, dest)
                    end
                end
            end
            utils.debug(
                "  For char '"
                    .. char
                    .. "' found transitions: {"
                    .. table.concat(transitions_for_char or {}, ", ")
                    .. "}"
            )

            transitions[curr_node_idx] = transitions[curr_node_idx] or {}
            -- Gathered transitions might make up a new state.
            if #transitions_for_char > 0 then
                local idx, exists = utils.Set.append(dfa_states, transitions_for_char)
                if not exists then
                    -- If we have a new state, we need to add it to the pending list
                    -- so that we can process it later.
                    table.insert(pending, idx)
                end

                -- We need to add a transition from the current state
                -- to the new state.
                transitions[curr_node_idx][char] = idx
            end
        end
    end

    -- print dfa states
    if utils.debug_enabled then
        print("DFA states:")
        for i, state in ipairs(dfa_states) do
            print(string.format("  State %d: {%s}", i, table.concat(state, ", ")))
        end
    end

    -- We need to convert states from set of sets
    -- into objects.
    local states = {}
    for i, _ in ipairs(dfa_states) do
        states[i] = {
            transitions = transitions[i] or {},
        }
    end

    -- If at least one state in the set state was
    -- accepting in NFA, then the whole state is accepting.
    local accept = {}
    for i, v in ipairs(dfa_states) do
        for _, s in ipairs(v) do
            if utils.contains(nfa.accept, s) and not utils.contains(accept, i) then
                table.insert(accept, i)
            end
        end
    end

    --- @type DFA
    local dfa = {
        states = states,
        start = nfa.start,
        alphabet = nfa.alphabet,
        accept = accept,
    }

    return dfa
end

--- Runs the DFA on the input string.
--- Returns true if the input is accepted by the DFA.
--- @param dfa DFA
--- @param input string
--- @return boolean
function _M.simulate(dfa, input)
    local current_state = dfa.start
    for i = 1, #input do
        local char = input:sub(i, i)
        local next_state = dfa.states[current_state].transitions[char]
        if not next_state then
            return false -- No transition for this character
        end
        current_state = next_state
    end

    -- Check if the current state is accepting
    return utils.contains(dfa.accept, current_state)
end

return _M
