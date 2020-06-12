require "maze_functions"
fun = require "lib/fun"

--input: file with maze
--output: return all lines of the maze
function lines_from(file)
  assert(io.open(file, "rb"))
  local lines = {}
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

-- input: filepath, start table, maze functor, history
-- output: writing file with maze modified with * except for "i" and "u"
function write_maze(filepath, start, maze, history)
  
  --input: maze, history, current x, current y, current life
  --output: final life, maze_output is modified by side effect
  local function write_path(maze_output, history, x, y, life)
    local move = history:head()
    local tail = history:tail()
    if tail:is_null() then return life
    else
      local life_change = move.life_change
      local delta_x, delta_y = move_vector(move.move)
      x = x + delta_x
      y = y + delta_y
      life = life + life_change
      maze_output[y][x] = "*"
      return write_path(maze_output, tail, x, y, life)
    end
  end
  
  local maze_output = maze(function(x) return x end):get_maze()
  local x = start.entry_point.x
  local y = start.entry_point.y

  local final_life = history and write_path(maze_output, fun.iter(history), x, y, start.initial_life  ) or start.initial_life
  
  local file = io.open(filepath, "w")
  file:write(final_life, "\n")
  for i,v in ipairs(maze_output) do
    for j, w in pairs(v) do
      file:write(w)
    end
    file:write("\n")
  end
  
end