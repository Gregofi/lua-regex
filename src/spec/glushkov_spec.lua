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
                { pos = 1, kind = "str", str = "a" },
                { pos = 2, kind = "str", str = "b" }
            }
        }, neighbours)

        ast = glushkov.number(AST.concat(AST.concat(AST.str("a"), AST.str("b")), AST.str("c")))
        neighbours = glushkov.neighbours(ast)
        assert.are.same({
            {
                { pos = 1, kind = "str", str = "a" },
                { pos = 2, kind = "str", str = "b" },
            },
            {
                { pos = 2, kind = "str", str = "b" },
                { pos = 3, kind = "str", str = "c" }
            }
        }, neighbours)

        ast = glushkov.number(AST.alt(AST.str("a"), AST.str("b")))
        neighbours = glushkov.neighbours(ast)
        assert.are.same({}, neighbours)

        ast = glushkov.number(AST.alt(AST.str("a"), AST.concat(AST.str("b"), AST.str("c"))))
        neighbours = glushkov.neighbours(ast)
        assert.are.same({
            {
                { pos = 2, kind = "str", str = "b" },
                { pos = 3, kind = "str", str = "c" }
            }
        }, neighbours)

        ast = glushkov.number(AST.concat(AST.str("a"), AST.star(AST.str("b"))))
        neighbours = glushkov.neighbours(ast)
        assert.are.same({
            {
                { pos = 2, kind = "str", str = "b" },
                { pos = 2, kind = "str", str = "b" }
            },
            {
                { pos = 1, kind = "str", str = "a" },
                { pos = 2, kind = "str", str = "b" }
            }
        }, neighbours)
    end)
end)

describe("nfa from neighbours", function()
    it("basic combinations", function()
        local nfa = glushkov.build_nfa_from_neighbours({}, {}, {})
        assert.are.same({
            accept = {},
            start = 1,
            states = {
                [1] = { transitions = {} },
            },
        }, nfa)

        local a = { pos = 1, kind = "str", str = "a" }
        local b = { pos = 2, kind = "str", str = "b" }
        local nfa = glushkov.build_nfa_from_neighbours({ { a, b } }, { a }, { b })
        assert.are.same({
            accept = { 3 },
            start = 1,
            states = {
                [1] = { transitions = { a = { 2 } } },
                [2] = { transitions = { b = { 3 } } },
                [3] = { transitions = {} },
            },
        }, nfa)

        local a_0 = { pos = 1, kind = "str", str = "a" }
        local b_1 = { pos = 2, kind = "str", str = "b" }
        local b_2 = { pos = 3, kind = "str", str = "b" }
        local nfa = glushkov.build_nfa_from_neighbours({
            { a_0, a_0 },
            { a_0, b_1 },
            { a_0, b_2 },
            { b_1, b_2 },
        }, { a_0 }, { b_2 } )
        assert.are.same({
            accept = { 4 },
            start = 1,
            states = {
                [1] = { transitions = { a = { 2 } } },
                [2] = { transitions = { a = { 2 }, b = { 3, 4 } } },
                [3] = { transitions = { b = { 4 } } },
                [4] = { transitions = {} },
            },
        }, nfa)
    end)
end)
