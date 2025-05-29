local _M = {}
local AST = require("ast")
local utils = require("utils")

--- Returns true if the given regex can generate empty string.
--- @param ast AST
--- @return boolean
function _M.epsilon(ast)
    return AST.visit(ast, {
        str = function(n) return false end,
        dot = function(n) return false end,
        concat = function(n, visit) return visit(n.left) and visit(n.right) end,
        alt = function(n, visit) return visit(n.left) or visit(n.right) end,
        star = function(n, visit) return true end,
        plus = function(n, visit) return false end,
        opt = function(n, visit) return true end,
        group = function(n, visit) return visit(n.expr) end
    })
end

--- Returns all literal (or dot) that the generated string
--- can begin with.
--- @param ast AST
--- @return AST[]
function _M.starts(ast)
    return AST.visit(ast, {
        str = function(n) return { n } end,
        dot = function(n) return { n } end,
        concat = function(n, visit)
            local left_starts = visit(n.left)
            if _M.epsilon(n.left) then
                return utils.append_lst(left_starts, visit(n.right))
            else
                return left_starts
            end
        end,
        alt = function(n, visit) return utils.append_lst(visit(n.left), visit(n.right)) end,
        star = function(n, visit) return visit(n.expr) end,
        plus = function(n, visit) return visit(n.expr) end,
        opt = function(n, visit) return visit(n.expr) end,
        group = function(n, visit) return visit(n.expr) end
    })
end


--- @param ast AST
--- @return AST[]
function _M.ends(ast)
    return AST.visit(ast, {
        str = function(n) return { n } end,
        dot = function(n) return { n } end,
        concat = function(n, visit)
            local right_ends = visit(n.right)
            if _M.epsilon(n.right) then
                return utils.append_lst(visit(n.left), right_ends)
            else
                return right_ends
            end
        end,
        alt = function(n, visit) return utils.append_lst(visit(n.left), visit(n.right)) end,
        star = function(n, visit) return visit(n.expr) end,
        plus = function(n, visit) return visit(n.expr) end,
        opt = function(n, visit) return visit(n.expr) end,
        group = function(n, visit) return visit(n.expr) end
    })
end

--- Adds a position to each string and dot in the AST.
--- @param ast AST
--- @return AST
function _M.number(ast)
    local i = 1
    return AST.map(ast, function(n)
        if n.kind == "str" or n.kind == "dot" then
            n.pos = i
            i = i + 1
        end
        return n
    end)
end

--- @param ast AST
--- @return table[]
function _M.neighbours(ast)
     return AST.visit(ast, {
        str = function(n) return {} end,
        dot = function(n) return {} end,
        concat = function(n, visit)
            -- First, recurse deeper and sort the neighbours there
            local left_neighbours = visit(n.left)
            local right_neighbours = visit(n.right)
            local neigh = utils.append_lst(left_neighbours, right_neighbours)

            -- Suppose AB, then ends(A) are neighbours of starts(B)
            local left_ends = _M.ends(n.left)
            local right_starts = _M.starts(n.right)

            for _, end_node in ipairs(left_ends) do
                for _, start_node in ipairs(right_starts) do
                    neigh[#neigh + 1] = { from = end_node, to = start_node }
                end
            end

            return neigh
        end,
        alt = function(n, visit)
            return utils.append_lst(visit(n.left), visit(n.right))
        end,
        star = function(n, visit)
            local expr_neighbours = visit(n.expr)
            -- If we have A*, then ends(A) are neighbours of starts(A)
            -- For example (a_1 b_2 a_3)*, then
            -- a_3 a_1 is a neighbouring pair.
            local ends = _M.ends(n.expr)
            local starts = _M.starts(n.expr)

            for _, end_node in ipairs(ends) do
                for _, start_node in ipairs(starts) do
                    expr_neighbours[#expr_neighbours + 1] = { from = end_node, to = start_node }
                end
            end

            return expr_neighbours
        end,
        plus = function(n, visit)
            local expr_neighbours = visit(n.expr)
            -- If we have A+, then ends(A) are neighbours of starts(A)
            -- For example (a_1 b_2 a_3)+, then
            -- a_3 a_1 is a neighbouring pair.
            local ends = _M.ends(n.expr)
            local starts = _M.starts(n.expr)

            for _, end_node in ipairs(ends) do
                for _, start_node in ipairs(starts) do
                    expr_neighbours[#expr_neighbours + 1] = { from = end_node, to = start_node }
                end
            end

            return expr_neighbours
        end,
        opt = function(n, visit) return visit(n.expr) end,
        group = function(n, visit) return visit(n.expr) end,
    })
end

--- @param ast AST
function _M.glushkov(ast)
    -- Assign numbers to all nodes that correspond to
    -- actual characters (not to *, +, ?, |, and () nodes).
    ast = _M.number(ast)
    -- Contains all symbols that the strings
    -- generated by the regex can contain.
    local starts = _M.starts(ast)
    -- Contains all symbols that the strings
    -- generated by the regex can end with.
    local ends = _M.ends(ast)
    -- Contains all states of the resulting NFA.
    -- Those are all the AST nodes that correspond
    -- to something that matches actual character
    -- (not all symbols! for example *, +, ?, |, and ()
    -- are not states, but . is).
    local neighbours = _M.neighbours(ast)
end

return _M
