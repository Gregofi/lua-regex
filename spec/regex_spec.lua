local parser = require("parser")
local glushkov = require("conversions.glushkov")
local fa = require("fa")
local AST = require("ast")

describe("from regex to automata", function()
    it("simple regex of plain characters", function()
        local ins = "abcd"
        local regex = parser:parse(ins)
        assert.is_not_nil(regex)
        local nfa = glushkov.glushkov(regex)
        local dfa = fa.determinize(nfa)

        assert.is_true(fa.simulate(dfa, "abcd"))
        assert.is_false(fa.simulate(dfa, "abd"))
        assert.is_false(fa.simulate(dfa, ""))
        assert.is_false(fa.simulate(dfa, "abcde"))
    end)

    it("repeats", function()
        local ins = "a*bc*"
        local regex = parser:parse(ins)
        assert.is_not_nil(regex)
        local nfa = glushkov.glushkov(regex)
        local dfa = fa.determinize(nfa)

        assert.is_true(fa.simulate(dfa, "abc"))
        assert.is_true(fa.simulate(dfa, "bc"))
        assert.is_true(fa.simulate(dfa, "ab"))
        assert.is_true(fa.simulate(dfa, "b"))
        assert.is_true(fa.simulate(dfa, "aab"))
        assert.is_true(fa.simulate(dfa, "aabc"))
        assert.is_true(fa.simulate(dfa, "bccc"))
        assert.is_true(fa.simulate(dfa, "aaaabccc"))
        assert.is_false(fa.simulate(dfa, "aaabbccc"))
        assert.is_false(fa.simulate(dfa, "aaaabcbc"))
        assert.is_false(fa.simulate(dfa, ""))
    end)

    it("repeats +", function()
        local ins = "a+"
        local regex = parser:parse(ins)
        assert.is_not_nil(regex)
        local nfa = glushkov.glushkov(regex)
        local dfa = fa.determinize(nfa)

        assert.is_true(fa.simulate(dfa, "aa"))
        assert.is_true(fa.simulate(dfa, "aaa"))
        assert.is_true(fa.simulate(dfa, "a"))
        assert.is_false(fa.simulate(dfa, ""))
    end)

    it("alternation", function()
        local ins = "a|b"
        local regex = parser:parse(ins)
        assert.is_not_nil(regex)
        local nfa = glushkov.glushkov(regex)
        local dfa = fa.determinize(nfa)

        assert.is_true(fa.simulate(dfa, "a"))
        assert.is_true(fa.simulate(dfa, "b"))
        assert.is_false(fa.simulate(dfa, "ab"))
        assert.is_false(fa.simulate(dfa, "ba"))
        assert.is_false(fa.simulate(dfa, ""))
    end)

    it("optional", function()
        local ins = "a?"
        local regex = parser:parse(ins)
        assert.is_not_nil(regex)
        local nfa = glushkov.glushkov(regex)
        local dfa = fa.determinize(nfa)

        assert.is_true(fa.simulate(dfa, ""))
        assert.is_true(fa.simulate(dfa, "a"))
        assert.is_false(fa.simulate(dfa, "aa"))
    end)

    it("complex regex 1", function()
        local ins = "a(bc|d)*e"
        local regex = parser:parse(ins)
        assert.is_not_nil(regex)
        local nfa = glushkov.glushkov(regex)
        local dfa = fa.determinize(nfa)

        assert.is_true(fa.simulate(dfa, "ae"))
        assert.is_true(fa.simulate(dfa, "abce"))
        assert.is_true(fa.simulate(dfa, "abcbcbce"))
        assert.is_true(fa.simulate(dfa, "abcbcbcbcbcbce"))
        assert.is_true(fa.simulate(dfa, "adbcbcdddbce"))
        assert.is_false(fa.simulate(dfa, "abdce"))
        assert.is_false(fa.simulate(dfa, "abcbe"))
        assert.is_false(fa.simulate(dfa, ""))
    end)
end)
