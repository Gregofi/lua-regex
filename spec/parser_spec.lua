describe("parser tests", function()
    local parser = require("parser")
    local AST = require("ast")

    --it("parses empty input", function()
    --    local ast = parser:parse("")
    --    assert.is_nil(ast)
    --end)

    it("parses single character", function()
        local ast = parser:parse("a")
        assert.are.same(AST.str("a"), ast)
    end)

    it("parses concatenation", function()
        local ast = parser:parse("ab")
        assert.are.same(AST.concat(AST.str("a"), AST.str("b")), ast)
    end)

    it("parses alternation", function()
        local ast = parser:parse("a|b")
        assert.are.same(AST.alt(AST.str("a"), AST.str("b")), ast)
    end)

    it("parses dot", function()
        local ast = parser:parse(".")
        assert.are.same(AST.dot(), ast)
    end)

    it("parses repetition with star", function()
        local ast = parser:parse("a*")
        assert.are.same(AST.star(AST.str("a")), ast)
    end)

    it("parses repetition with plus", function()
        local ast = parser:parse("a+")
        assert.are.same(AST.plus(AST.str("a")), ast)
    end)

    it("parses optional with question mark", function()
        local ast = parser:parse("a?")
        assert.are.same(AST.opt(AST.str("a")), ast)
    end)

    it("parses grouped expression", function()
        local ast = parser:parse("(ab)")
        assert.are.same(AST.group(AST.concat(AST.str("a"), AST.str("b"))), ast)
    end)

    it("parses multiple concats", function()
        local ast = parser:parse("abc")
        assert.are.same(AST.concat(AST.concat(AST.str("a"), AST.str("b")), AST.str("c")), ast)

        local ast2 = parser:parse("abcd*e")
        assert.are.same(AST.to_string(ast2), "abcd*e")

        local ast3 = parser:parse("a|b|c")
        assert.are.same(AST.alt(AST.alt(AST.str("a"), AST.str("b")), AST.str("c")), ast3)

        local ast4 = parser:parse("a|(bc?)")
        assert.are.same(AST.alt(AST.str("a"), AST.group(AST.concat(AST.str("b"), AST.opt(AST.str("c"))))), ast4)
    end)
end)
