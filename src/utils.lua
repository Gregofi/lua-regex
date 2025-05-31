local _M = { Set = {} }

function _M.fold_left(f, l, init)
    for _, value in ipairs(l) do
        init = f(value, init)
    end
    return init
end

function _M.fold_right(f, l, init)
    for i = #l, 1, -1 do
        init = f(l[i], init)
    end
    return init
end

function _M.append_lst(left, right)
    local l = #left
    for idx, val in ipairs(right) do
        left[l + idx] = val
    end
    return left
end

--- @param left number[]
--- @param right number[]
function _M.array_eq(left, right)
    if #left ~= #right then
        return false
    end
    for i, _ in ipairs(left) do
        if left[i] ~= right[i] then
            return false
        end
    end
    return true
end

function _M.contains(arr, x)
    for _, v in ipairs(arr) do
        if v == x then
            return true
        end
    end
    return false
end

--- Checks if given set of numbers is contained in `set`,
--- which is a set of sets of numbers.
--- @param set number[][]
--- @param tuple number[]
--- @return number|nil
function _M.Set.has(set, tuple)
    for i, v in ipairs(set) do
        if _M.array_eq(v, tuple) then
            return i
        end
    end
    return nil
end

--- Inserts tuple into set of tuples, or does nothing
--- if the tuple is already in the set.
--- Returns the index in the set and
--- true if it already existed
function _M.Set.append(set, tuple)
    table.sort(tuple)
    local i = _M.Set.has(set, tuple)
    if not i then
        table.insert(set, tuple)
        return #set, false
    end
    return i, true
end

--- Inserts value into array if it is not already present.
function _M.insert_uniq(array, value)
    if not _M.contains(array, value) then
        table.insert(array, value)
    end
end

function _M.print_array(arr)
    local str = "{"
    for i, v in ipairs(arr) do
        str = str .. tostring(v)
        if i < #arr then
            str = str .. ", "
        end
    end
    str = str .. "}"
    return str
end

function _M.debug(msg)
    if _M.debug_enabled then
        print(msg)
    end
end

return _M
