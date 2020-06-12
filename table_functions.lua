--input: an indexed table e.g. {"a", "b", "c"}
--output: a copy of the input table e.g. {"a", "b", "c"}
--[PURE]
function table.copy(tbl)
  local t = {}
  for _, v in ipairs(tbl) do
      table.insert(t, v)
  end
  return t
end

--input: an indexed table e.g. {"a", "b", "c"}
--output: a reversed copy of the input table e.g. {"c", "b", "a"}
--[PURE]
function table.reverse(tbl)
  local t = {}
  for i = #tbl, 1, -1 do
      table.insert(t, tbl[i])
  end
  return t
end
