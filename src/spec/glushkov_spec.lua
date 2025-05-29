local glushkov = require("conversions/glushkov")
local AST = require("ast")

describe("epsilon", function()
    it("basic nodes", function()
        local ast = AST.str("a")
        assert.is_false(glushkov.epsilon(ast))

        ast = AST.dot()
        assert.is_false(glushkov.epsilon(ast))

        ast = AST.concat(AST.str("a"), AST.str("b"))
        assert.is_false(glushkov.epsilon(ast))

        ast = AST.alt(AST.str("a"), AST.str("b"))
        assert.is_false(glushkov.epsilon(ast))

        ast = AST.star(AST.str("a"))
        assert.is_true(glushkov.epsilon(ast))

        ast = AST.plus(AST.str("a"))
        assert.is_false(glushkov.epsilon(ast))

        ast = AST.opt(AST.str("a"))
        assert.is_true(glushkov.epsilon(ast))

        ast = AST.group(AST.str("a"))
        assert.is_false(glushkov.epsilon(ast))
    end)

    it("nested structures", function()
        local ast = AST.concat(AST.str("a"), AST.star(AST.str("b")))
        assert.is_false(glushkov.epsilon(ast))

        ast = AST.alt(AST.str("a"), AST.opt(AST.str("b")))
        assert.is_true(glushkov.epsilon(ast))

        ast = AST.group(AST.concat(AST.str("a"), AST.star(AST.str("b"))))
        assert.is_false(glushkov.epsilon(ast))
    end)
end)

describe("starts", function()
    it("basic nodes", function()
        local ast = AST.str("a")
        assert.are.same({ ast }, glushkov.starts(ast))

        ast = AST.dot()
        assert.are.same({ ast }, glushkov.starts(ast))

        ast = AST.concat(AST.str("a"), AST.str("b"))
        assert.are.same({ AST.str("a") }, glushkov.starts(ast))

        ast = AST.alt(AST.str("a"), AST.str("b"))
        assert.are.same({ AST.str("a"), AST.str("b") }, glushkov.starts(ast))

        ast = AST.star(AST.str("a"))
        assert.are.same({ AST.str("a") }, glushkov.starts(ast))

        ast = AST.plus(AST.str("a"))
        assert.are.same({ AST.str("a") }, glushkov.starts(ast))

        ast = AST.opt(AST.str("a"))
        assert.are.same({ AST.str("a") }, glushkov.starts(ast))

        ast = AST.group(AST.str("a"))
        assert.are.same({ AST.str("a") }, glushkov.starts(ast))
    end)

    it("nested structures", function()
        ast = AST.alt(AST.str("a"), AST.opt(AST.str("b")))
        assert.are.same({ AST.str("a"), AST.str("b") }, glushkov.starts(ast))

        local ast = AST.concat(AST.str("a"), AST.star(AST.str("b")))
        assert.are.same({ AST.str("a") }, glushkov.starts(ast))

        ast = AST.concat(AST.star(AST.str("a")), AST.str("b"))
        assert.are.same({ AST.str("a"), AST.str("b") }, glushkov.starts(ast))
    end)
end)

describe("ends", function()
    it("basic nodes", function()
        local ast = AST.str("a")
        assert.are.same({ ast }, glushkov.ends(ast))

        ast = AST.dot()
        assert.are.same({ ast }, glushkov.ends(ast))

        ast = AST.concat(AST.str("a"), AST.str("b"))
        assert.are.same({ AST.str("b") }, glushkov.ends(ast))

        ast = AST.alt(AST.str("a"), AST.str("b"))
        assert.are.same({ AST.str("a"), AST.str("b") }, glushkov.ends(ast))

        ast = AST.star(AST.str("a"))
        assert.are.same({ AST.str("a") }, glushkov.ends(ast))

        ast = AST.plus(AST.str("a"))
        assert.are.same({ AST.str("a") }, glushkov.ends(ast))

        ast = AST.opt(AST.str("a"))
        assert.are.same({ AST.str("a") }, glushkov.ends(ast))

        ast = AST.group(AST.str("a"))
        assert.are.same({ AST.str("a") }, glushkov.ends(ast))
    end)

    it("nested structures", function()
        local ast = AST.concat(AST.str("a"), AST.star(AST.str("b")))
        assert.are.same({ AST.str("a"), AST.str("b") }, glushkov.ends(ast))

        ast = AST.alt(AST.str("a"), AST.str("b"))
        assert.are.same({ AST.str("a"), AST.str("b") }, glushkov.ends(ast))
    end)
end)

describe("neighbours", function()
    it("basic combinations", function()
        local ast = glushkov.number(AST.str("a"))
        local neighbours = glushkov.neighbours(ast)
        assert.are.same({
        }, neighbours)

        ast = glushkov.number(AST.concat(AST.str("a"), AST.str("b")))
        neighbours = glushkov.neighbours(ast)
        assert.are.same({
            {
                from = { pos = 1, kind = "str", str = "a" },
                to = { pos = 2, kind = "str", str = "b" }
            }
        }, neighbours)
    end)
end)
