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
---@field char string

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


return AST
