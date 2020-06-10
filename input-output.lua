require "maze_functions"
fun = require 'fun'

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

-- input: filepath, start, maze , history
 -- output: writing file with maze modified with * 
function write_maze(filepath, start, maze, history)
  
  --input: maze, history,x,y,life
  --output: final life
  function write_path(maze, history, x, y, life)
    if fun.tail(history).state then
      local move = fun.head(history)
      local life_change = move.life_change
      local delta_x, delta_y = move_vector(move.move)
      x = x + delta_x
      y = y + delta_y
      life = life + life_change
      maze[y][x] = "*"
      return write_path(maze, fun.tail(history), x, y, life)
    else
      return life
    end
  end
  
  local maze_output = maze(function(x) return x end):get_maze()
  local x = start.entry_point.x
  local y = start.entry_point.y
  maze_output[y][x]="*"  
  local final_life = write_path(maze_output, fun.iter(history), x, y, start.vitality)
  
  local file = io.open(filepath, "w")
  file:write(final_life, "\n")
  for i,v in ipairs(maze_output) do
    for j, w in pairs(v) do
      file:write(w)
    end
    file:write("\n")
  end
  
end
--print(move_encode('3|2|5', maze:get_maze()))
--print_table(gen_path("3|3|4", visited))
