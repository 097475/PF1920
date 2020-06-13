
function create_hashtable()
    local hashtable = {}
    return setmetatable(hashtable, {__index = function(tab, key) return rawget(tab, string.match(key, "|(.*)")) end, __newindex = function(tab, key, value) rawset(tab, string.match(key, "|(.*)"), value)  end})
end

function copy_hashtable(hashtable)
    local new_hashtable = create_hashtable()
    for k, v in pairs(hashtable) do
        local new_key = "0|" .. k
        new_hashtable[new_key] = v
    end

    return new_hashtable
end
