local _M = {}
local AST = require("ast")

-- The parser uses recursive descent parsing technique.
-- grammar, it is LL(1):
--    S  -> A | ε
--
--    A  -> C A' | ε
--    A' -> '|' C A' | ε
--
--    C  -> R C'
--    C' -> R C' | ε
--
--    R  -> X R'
--    R' -> '*' R' | '+' R' | '?' R' | ε
--
--    X -> '(' S ')' | '.' | char

--- Parses the string into a Regex AST.
--- Performance is not a key here, since
--- the regexes are often short.
--- @param input string
local function new_parser(input)
    local parser = {
        i = 1,
        len = #input,
        input = input,
    }

    function parser:curr()
        local curr = self.input:sub(self.i, self.i)
        return curr
    end

    function parser:advance()
        self.i = self.i + 1
    end

    function parser:error(msg)
        error("Compile error: " .. msg)
    end

    --- @return AST
    function parser:parse()
        local ast = self:Start()
        return ast
    end

    --- @return AST
    function parser:Start()
        return self:Alt()
    end

    --- @return AST
    function parser:Alt()
        local c = self:Conc()
        return self:Alt_(c)
    end

    --- @param left AST
    --- @return AST
    function parser:Alt_(left)
        if self:curr() == '|' then
            self:advance()
            local right = self:Conc()
            return self:Alt_(AST.alt(left, right))
        end
        return left
    end

    --- @return AST
    function parser:Conc()
        local c = self:Rep()
        return self:Conc_(c)
    end

    --- @param left AST
    --- @return AST
    function parser:Conc_(left)
        -- The rule is C' -> R C' | ε
        -- Therefore, we calculate first(R) and if we match,
        -- we continue parsing C'. Otherwise, we are ε rule and return left.
        local c = self:curr()
        if c == '(' or c == '.' or c:match('%a') then
            -- do not shift here
            local right = self:Rep()
            return self:Conc_(AST.concat(left, right))
        end
        return left
    end

    --- @return AST
    function parser:Rep()
        local a = self:Atom()
        return parser:Rep_(a)
    end

    --- @param left AST
    --- @return AST
    function parser:Rep_(left)
        local c = self:curr()
        if c == '*' then
            self:advance()
            return AST.star(left)
        elseif c == '+' then
            self:advance()
            return AST.plus(left)
        elseif c == '?' then
            self:advance()
            return AST.opt(left)
        end
        return left
    end

    --- @return AST
    function parser:Atom()
        local c = self:curr()
        if c == '(' then
            self:advance()
            local expr = self:Start()
            if self:curr() ~= ')' then
                self:error("Expected ')'")
            end
            self:advance() -- consume ')'
            return AST.group(expr)
        elseif c == '.' then
            self:advance()
            return AST.dot()
        elseif c:match('%a') then
            self:advance()
            return AST.str(c)
        else
            self:error("Unexpected character: " .. (c or "nil"))
        end
    end

    return parser
end

--- Parses the input string into an AST.
--- @param input string
--- @return nil|AST, string|nil
function _M:parse(input)
    local parser = new_parser(input)
    local success, ast_err = pcall(function()
        return parser:parse()
    end)

    if not success then
        return nil, ast_err
    end

    return ast_err
end

return _M
