function create_hashtable()
    local hashtable = {}
    return setmetatable(hashtable, {__index = function(tab, key) return rawget(tab, string.match(key, "|(.*)")) end, __newindex = function(tab, key, value) rawset(tab, string.match(key, "|(.*)"), value)  end})
end