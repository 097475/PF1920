--input: table, value 
-- output: compare a value with the elements of a table and returns true if the element is present in the table otherwise false 
--[PURE]
function table.contains(tbl, e)
    for _, v in pairs(tbl) do
      
        if isEqual(v,e)  then
            return true
        end
    end

    return false
end

--input: table
--output: returns a copy of the table inserted as a parameter
--[PURE]
function table.copy(tbl)
    local t = {}

    for _, v in pairs(tbl) do
        table.insert(t, v)
    end

    return t
end

--input: table
--output: returns a reverse of the table inserted as a parameter
--[PURE]
function table.reverse(tbl)
  local t = {}
  for i = #tbl, 1, -1 do
      table.insert(t, tbl[i])
  end
  return t
end

--[[
This function takes 2 values as input and returns true if they are equal
and false if not. a and b can numbers, strings, booleans, tables and nil.
--]]

function isEqual(a,b)

   local function isEqualTable(t1,t2)

      if t1 == t2 then
         return true
      end

      for k,v in pairs(t1) do

         if type(t1[k]) ~= type(t2[k]) then
            return false
         end

         if type(t1[k]) == "table" then
            if not isEqualTable(t1[k], t2[k]) then
               return false
            end
         else
            if t1[k] ~= t2[k] then
               return false
            end
         end
      end

      for k,v in pairs(t2) do

         if type(t2[k]) ~= type(t1[k]) then
            return false
         end

         if type(t2[k]) == "table" then
            if not isEqualTable(t2[k], t1[k]) then
               return false
            end
         else
            if t2[k] ~= t1[k] then
               return false
            end
         end
      end

      return true
   end

   if type(a) ~= type(b) then
      return false
   end

   if type(a) == "table" then
      return isEqualTable(a,b)
   else
      return (a == b)
   end

end