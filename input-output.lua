-- hash table
--visited = {
--["5|2|5"] = {move="", life_change=0 },
--["4|3|5"] = {move="R", life_change=-1 },
--["3|3|4"] = {move="U", life_change=-1 },
--}

-- maze -> table of tables with integers and chars inside

-- get all lines from a file
function lines_from(file)
  assert(io.open(file, "rb"))
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

-- input: two dimensional table
-- output: none
function print_table(tab)
  for i,v in ipairs(tab) do
    for j, w in pairs(v) do
      io.write(w)
    end
    io.write("\n")
  end
end


-- TODO: REMOVE SIDE EFFECTS
-- input: table representing the steps taken in the path using DULR and life change at each step, two dimensional table representing maze, initial life
-- output: modified maze, final life
function write_path(history, maze, life)
  -- input: table representing the steps taken in the path using DULR and life change at each step, x coordinate, y coordinate of current position in maze, initial life
  -- output: final life
  function _write_path(history, x, y, life)
    local move = table.remove(history, 1)
    local action = move.move
    local life_change = move.life_change
    local delta_x, delta_y = move_vector(action)
    x = x + delta_x
    y = y + delta_y
    life = life + life_change
    maze[y][x] = "*"
    if #history > 0 then
      return _write_path(history, x, y, life)
    else
      return life
    end
  end
  
  local x,y = find_initial(maze)
  maze[y][x] = "*"  
  return maze, _write_path(history, x, y, life)
end

--print(move_encode('3|2|5', maze:get_maze()))
--print_table(gen_path("3|3|4", visited))
