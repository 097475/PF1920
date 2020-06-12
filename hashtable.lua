--input: none
--output: new hashtable table
--[PURE]
function create_hashtable()
    local hashtable = {}
    return setmetatable(hashtable, {__index = function(self, key) return rawget(self, string.match(key, "|(.*)")) end, __newindex = function(self, key, value) rawset(self, string.match(key, "|(.*)"), value)  end})
end

--input: hashtable table
--output: copy of input table
--[PURE]
function copy_hashtable(hashtable)
    local new_hashtable = create_hashtable()
    for k, v in pairs(hashtable) do
        rawset(new_hashtable, k, v)
    end
    return new_hashtable
end
