require "maze_functions"

-- hash table
--visited = {
--["5|2|5"] = {move="", life_change=0 },
--["4|3|5"] = {move="R", life_change=-1 },
--["3|3|4"] = {move="U", life_change=-1 },
--}

-- maze -> table of tables with integers and chars inside

--get all lines from a file
-- input: file with maze
--output: return all lines of the maze
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
  local maze_modified = maze:get_maze()
   local move={}
    local life_change={}
    for k,d in pairs(history) do
      
      table.insert(move, d.move)
      table.insert(life_change,d.life_change)
    end
  function _write_path(history, x, y, life)
    local move_ = table.remove(move,1)
    local life_change_ = table.remove(life_change,1)
    local delta_x, delta_y = move_vector(move_)
    print(delta_x,delta_y)
    x = x + delta_x
    y = y + delta_y
    life = life + life_change_
    maze_modified[y][x] = "*"
    if #move > 0 then
      return _write_path(history, x, y, life)
    else
      return life
    end
  end
  local x = start.entry_point.x
  local y=start.entry_point.y
  maze_modified[y][x]="*"  
  return maze_modified, _write_path(history, x, y, life)
end

-- input: maze modified with * and life updated
 -- output: writing file with maze modified
function write_maze(maze,life)
  file = io.open("test.lua", "a")
  file:write(life, "\n")
   for i,v in ipairs(maze) do
    for j, w in pairs(v) do
      file:write(w)
    end
    file:write("\n")
  end
  
  end
--print(move_encode('3|2|5', maze:get_maze()))
--print_table(gen_path("3|3|4", visited))
