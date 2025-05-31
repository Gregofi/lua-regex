---@alias AST
---| StrNode
---| DotNode
---| ConcatNode
---| AltNode
---| StarNode
---| PlusNode
---| OptNode
---| GroupNode

---@class StrNode
---@field kind "str"
---@field str string

---@class DotNode
---@field kind "dot"

---@class ConcatNode
---@field kind "concat"
---@field left AST
---@field right AST

---@class AltNode
---@field kind "alt"
---@field left AST
---@field right AST

---@class StarNode
---@field kind "star"
---@field expr AST

---@class PlusNode
---@field kind "plus"
---@field expr AST

---@class OptNode
---@field kind "opt"
---@field expr AST

---@class GroupNode
---@field kind "group"
---@field expr AST

local AST = {}

---@return DotNode
function AST.dot()
    return { kind = "dot" }
end

---@param str string
---@return StrNode
function AST.str(str)
    return { kind = "str", str = str }
end

---@param left AST
---@param right AST
---@return ConcatNode
function AST.concat(left, right)
    return { kind = "concat", left = left, right = right }
end

---@param left AST
---@param right AST
---@return AltNode
function AST.alt(left, right)
    return { kind = "alt", left = left, right = right }
end

---@param expr AST
---@return StarNode
function AST.star(expr)
    return { kind = "star", expr = expr }
end

---@param expr AST
---@return PlusNode
function AST.plus(expr)
    return { kind = "plus", expr = expr }
end

---@param expr AST
---@return OptNode
function AST.opt(expr)
    return { kind = "opt", expr = expr }
end

---@param expr AST
---@return GroupNode
function AST.group(expr)
    return { kind = "group", expr = expr }
end

--- @param node AST
--- @return string
function AST.to_string(node)
    if node.kind == "str" then
        return node.str
    elseif node.kind == "dot" then
        return "."
    elseif node.kind == "concat" then
        return AST.to_string(node.left) .. AST.to_string(node.right)
    elseif node.kind == "alt" then
        return AST.to_string(node.left) .. "|" .. AST.to_string(node.right)
    elseif node.kind == "star" then
        return AST.to_string(node.expr) .. "*"
    elseif node.kind == "plus" then
        return AST.to_string(node.expr) .. "+"
    elseif node.kind == "opt" then
        return AST.to_string(node.expr) .. "?"
    elseif node.kind == "group" then
        return "(" .. AST.to_string(node.expr) .. ")"
    else
        error("Unknown AST node kind: " .. tostring(node.kind))
    end
end

---@param n AST
---@param v table<string, fun(n: AST, v: function): any>
---@return any
function AST.visit(n, v)
    local handler = v[n.kind]
    if handler then
        return handler(n, function(n)
            return AST.visit(n, v)
        end)
    else
        error("No visitor function for kind: " .. tostring(node.kind))
    end
end

--- @param ast AST
--- @return any
function AST.map(n, f)
    return AST.visit(n, {
        str = function(n)
            return f(n)
        end,
        dot = function(n)
            return f(n)
        end,
        concat = function(n, visit)
            return f(AST.concat(visit(n.left), visit(n.right)))
        end,
        alt = function(n, visit)
            return f(AST.alt(visit(n.left), visit(n.right)))
        end,
        star = function(n, visit)
            return f(AST.star(visit(n.expr)))
        end,
        plus = function(n, visit)
            return f(AST.plus(visit(n.expr)))
        end,
        opt = function(n, visit)
            return f(AST.opt(visit(n.expr)))
        end,
        group = function(n, visit)
            return f(AST.group(visit(n.expr)))
        end,
    })
end

function AST.to_dot(ast)
    local lines = {}
    local id_counter = 0

    local function new_id()
        id_counter = id_counter + 1
        return "n" .. id_counter
    end

    local function visit(node)
        local id = new_id()

        if node.kind == "dot" then
            table.insert(lines, string.format('%s [label="•"];', id))
            return id
        elseif node.kind == "str" then
            table.insert(lines, string.format('%s [label="%s"];', id, node.str))
            return id
        elseif node.kind == "concat" then
            table.insert(lines, string.format('%s [label="."];', id))
            local left = visit(node.left)
            local right = visit(node.right)
            table.insert(lines, string.format("%s -> %s;", id, left))
            table.insert(lines, string.format("%s -> %s;", id, right))
            return id
        elseif node.kind == "alt" then
            table.insert(lines, string.format('%s [label="|"];', id))
            local left = visit(node.left)
            local right = visit(node.right)
            table.insert(lines, string.format("%s -> %s;", id, left))
            table.insert(lines, string.format("%s -> %s;", id, right))
            return id
        elseif node.kind == "star" then
            table.insert(lines, string.format('%s [label="*"];', id))
            local inner = visit(node.expr)
            table.insert(lines, string.format("%s -> %s;", id, inner))
            return id
        elseif node.kind == "plus" then
            table.insert(lines, string.format('%s [label="+"];', id))
            local inner = visit(node.expr)
            table.insert(lines, string.format("%s -> %s;", id, inner))
            return id
        elseif node.kind == "opt" then
            table.insert(lines, string.format('%s [label="?"];', id))
            local inner = visit(node.expr)
            table.insert(lines, string.format("%s -> %s;", id, inner))
            return id
        elseif node.kind == "group" then
            table.insert(lines, string.format('%s [label="()"];', id))
            local inner = visit(node.expr)
            table.insert(lines, string.format("%s -> %s;", id, inner))
            return id
        else
            error("Unknown AST node kind: " .. tostring(node.kind))
        end
    end

    table.insert(lines, "digraph AST {")
    table.insert(lines, "  node [shape=circle];")
    visit(ast)
    table.insert(lines, "}")

    return table.concat(lines, "\n")
end

return AST
