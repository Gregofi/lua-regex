describe("append_lst", function()
    local utils = require("utils")

    it("appends two empty lists", function()
        local result = utils.append_lst({}, {})
        assert.are.same({}, result)
    end)

    it("appends an empty list to a non-empty list", function()
        local result = utils.append_lst({1, 2, 3}, {})
        assert.are.same({1, 2, 3}, result)
    end)

    it("appends a non-empty list to an empty list", function()
        local result = utils.append_lst({}, {4, 5, 6})
        assert.are.same({4, 5, 6}, result)
    end)

    it("appends two non-empty lists", function()
        local result = utils.append_lst({1, 2}, {3, 4})
        assert.are.same({1, 2, 3, 4}, result)
    end)

    it("appends lists with different types", function()
        local result = utils.append_lst({1, "two"}, {3.0, true})
        assert.are.same({1, "two", 3.0, true}, result)
    end)
end)
