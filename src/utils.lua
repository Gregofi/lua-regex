local _M = {}

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

return _M
