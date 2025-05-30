local _M = {}

---@class NFA
---@field states NFAState[]
---@field start integer
---@field accept true[]  -- set of accepting states

---@class NFAState
---@field transitions table<string, table<integer>>  -- char -> set of next states

--- Creates a new NFA.
--- @return NFA
function _M.new_nfa()
    return {
        states = { { transitions = {}} },
        start = 1,
        accept = {}
    }
end

return _M
