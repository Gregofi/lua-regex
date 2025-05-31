local fa = require("fa")
local utils = require("utils")
utils.debug_enabled = false

describe("determinize", function()
    it("simple automaton", function()
        --- @type NFA
        local nfa = {
            states = {
                { transitions = { a = { 2, 3 } } },
                { transitions = { b = { 3 } } },
                { transitions = {} },
            },
            start = 1,
            accept = { 3 },
            alphabet = { "a", "b" },
        }

        local dfa = fa.determinize(nfa)
        assert.are.same({
            states = {
                { transitions = { a = 2 } }, -- {1}
                { transitions = { b = 3 } }, -- {2, 3}
                { transitions = {} }, -- {3}
            },
            start = 1,
            accept = { 2, 3 },
            alphabet = { "a", "b" },
        }, dfa)
    end)

    it("complex automaton", function()
        --- @type NFA
        local nfa = {
            states = {
                { transitions = { a = { 2, 3 }, b = { 1 } } },
                { transitions = { a = { 4 } } },
                { transitions = { a = { 1 }, b = { 2, 4 } } },
                { transitions = { b = { 2, 3 } } },
            },
            start = 1,
            accept = { 3, 4 },
            alphabet = { "a", "b" },
        }

        local dfa = fa.determinize(nfa)
        assert.are.same({
            {
                transitions = {
                    a = 2,
                    b = 1,
                },
            },
            {
                transitions = {
                    a = 3,
                    b = 4,
                },
            },
            {
                transitions = {
                    a = 2,
                    b = 6,
                },
            },
            {
                transitions = {
                    a = 5,
                    b = 2,
                },
            },
            {
                transitions = {
                    b = 2,
                },
            },
            {
                transitions = {
                    a = 7,
                    b = 8,
                },
            },
            {
                transitions = {
                    a = 7,
                    b = 7,
                },
            },
            {
                transitions = {
                    a = 9,
                    b = 6,
                },
            },
            {
                transitions = {
                    a = 3,
                    b = 9,
                },
            },
        }, dfa.states)

        assert.are.same({
            start = 1,
            accept = { 2, 3, 4, 5, 6, 7, 8, 9 },
            alphabet = { "a", "b" },
        }, {
            start = dfa.start,
            accept = dfa.accept,
            alphabet = dfa.alphabet,
        })
    end)
end)

describe("simulate dfa", function()
    it("accepts simple string", function()
        local dfa = {
            states = {
                { transitions = { a = 2 } },
                { transitions = { b = 3 } },
                { transitions = {} },
            },
            start = 1,
            accept = { 3 },
            alphabet = { "a", "b" },
        }

        assert.is_true(fa.simulate(dfa, "ab"))
        assert.is_false(fa.simulate(dfa, "aa"))

        local dfa = {
            states = {
                { transitions = { a = 2, b = 1 } },
                { transitions = { a = 4 } },
                { transitions = { a = 1, b = 4 } },
                { transitions = { b = 3 } },
            },
            start = 1,
            accept = { 3, 4 },
            alphabet = { "a", "b" },
        }

        assert.is_true(fa.simulate(dfa, "aa"))
        assert.is_false(fa.simulate(dfa, "aaa"))
        assert.is_true(fa.simulate(dfa, "aab"))
        assert.is_false(fa.simulate(dfa, "aaba"))
        assert.is_true(fa.simulate(dfa, "aabaaa"))
    end)
end)
