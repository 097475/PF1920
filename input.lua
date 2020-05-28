-- hash table
--visited = {
--  ["5|2|5"] = {"", 0 },
--  ["4|3|5"] = {"R", -1 },
--  ["3|3|4"] = {"U", -1 },
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

-- builds a maze from the table containing lines of the file
function build_maze(lines_table)
  local maze = {}
  for i=1,#lines-1 do
    row = {}
    -- need to skip first row: reserved for vitality
    for cell in lines[i + 1]:gmatch"." do
      if tonumber(cell) ~= nil then cell = tonumber(cell) end
      row[#row + 1] = cell
    end
    maze[i] = row
  end
  return maze
end

-- finds points of a maze with a specific symbol (Ex: entry points with symbol "i")
function find_points(maze, symbol)
  local points = {}
  for row_key, row_table in pairs(maze) do
    for col_key, element in pairs(row_table) do
      if element == symbol then
        local points_index = #points + 1
        points[points_index] = {}
        points[points_index].x = col_key
        points[points_index].y = row_key
      end
    end
  end
  return points
end 

-- checks length of entry points list: it must be 1
function check_entry_point_validity(points)
  if #points == 1 then return true else return false end
end

-- checks if maze is correct must have rows with all same lenght
function check_maze_validity(maze)
  local n_cols = #maze[1]
  for key, row in pairs(maze) do
    if #row ~= n_cols then do return false end end
  end
  return true
end

-- builds the start table: it contains vitality of the player, entry point and exit points
function build_start_table(lines_table, maze)
  start = {}
  start.vitality = lines[1]
  local entry_points = find_points(maze, "i")
  assert(check_entry_point_validity(entry_points), "The maze file must contain only one entry point.")
  start.entry_point = {}
  start.entry_point.x = entry_points[1].x
  start.entry_point.y = entry_points[1].y
  start.exit_points = find_points(maze, "u")
  return start
end

-- builds maze table and start table and checks for input errors
function init_game_data(filename)
  local lines = lines_from(filename)
  local maze = build_maze(lines)
  assert(check_maze_validity(maze), "Maze format is not correct: rows have not the same number of columns.")
  local start = build_start_table(lines, maze)
  return start, maze
end

-- input: two dimensional table
-- output: none
function print_table(tab)
  for i,v in ipairs(tab) do
    for j, w in ipairs(v) do
      io.write(w)
    end
    io.write("\n")
  end
end

-- input: life, x, y as numbers
-- output: string representing the state
function encode(life, x, y)
  return life .. "|" .. x .. "|" .. y 
end

-- input: string representing the state
-- output: life, x, y as numbers
function decode(str)
  local values = {}
  for i in string.gmatch(str, "%d+") do
    table.insert(values, tonumber(i))
  end
  return table.unpack(values)
end

-- input: character D, U, L or R
-- output: delta_x, delta_y representing the change in x and y
function move_vector(move)
  local delta_x, delta_y
    if move == "D" then
      delta_x, delta_y = 0, 1
    elseif move == "U" then
      delta_x, delta_y = 0, -1
    elseif move == "L" then
      delta_x, delta_y = -1, 0
    elseif move == "R" then
      delta_x, delta_y = 1, 0
    else 
      print("Error")
    end
    return delta_x, delta_y
  end

-- input: state string final, hash table tree
-- output: table representing the steps taken in the path using DULR and life change at each step
function gen_path(final, tree)
  -- input: state string final, path string path
  -- output: table representing the steps taken in the path using DULR and life change at each step
  function _gen_path(final, history)
    if tree[final][1] == "" then
      return history
    else
      table.insert(history, 1, tree[final])
      return _gen_path(invert_move(final, tree[final][1], tree[final][2]), history)
    end
  end
  -- input: state string, move used to get to state, life_chance applied after getting to state
  -- output: string representing previous state
  function invert_move(state, move, life_change)
    local life, x, y = decode(state)
    local delta_x, delta_y = move_vector(move)
    return encode(life - life_change, x - delta_x, y - delta_y)
  end
  
  return _gen_path(final, {})
  end

-- TODO: REMOVE SIDE EFFECTS
-- input: table representing the steps taken in the path using DULR and life change at each step, two dimensional table representing maze, initial life
-- output: modified maze, final life
function write_path(history, maze, life)
  -- input: table representing the steps taken in the path using DULR and life change at each step, x coordinate, y coordinate of current position in maze, initial life
  -- output: final life
  function _write_path(history, x, y, life)
    local move = table.remove(history, 1)
    local action = move[1]
    local life_change = move[2]
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

 -- return move for x parameter "L" or "R"
function get_move_x(x)
  local position
    if  x == -1  then
      position="L"
    elseif x == 1  then
      position="R"
    else 
      print("Error")
    end
    return position
  end
  
  -- return move for y parameter "D" or "U"
  function get_move_y(y)
  local position
    if   y==1 then
      position= "D"
    elseif   y==-1 then
      position= "U"
    else 
      print("Error")
    end
    return position
  end
  
  
-- list of move available 
function move_available(maze,y,x)
   local available = {}
   if maze[y][x] == "m" or maze[y][x]==nil then
     return available
   end
     for z= -1,1,2 do
       if maze[y][x+z] ~= "m" and maze[y][x+z]~=nil then
        available[#available+1]=get_move_x(z)
      end
      if maze[y+z][x] ~= "m" and maze[y+z][x]~=nil then
        
        available[#available +1 ]=get_move_y(z)
       
      end
   end
   return available
 end
 
 -- update the life according to logic of program
function life_update(life,maze,y,x)
  local new_life
  local cell = maze[y][x]
  if tonumber(cell) ~= nil then
    if cell == 0 then
      new_life=life
    elseif cell >= 1 and cell<= 4 then
      new_life=life + cell
    elseif cell >= 5 and cell<= 8 then
      new_life=life+4-cell
    else
      new_life=life*2
    end
  else
    if cell == 'f'  then
      new_life=life/2
      if new_life==1 then
       new_life=0
      end
    elseif cell == 'p' then
      new_life = 0
    else
      new_life = life
    end
  end
  return new_life
end

-- return move available in a specific format with life,position and move, life change
function move_encode(encode_state, maze)
  life,x,y=decode(encode_state)
  local move={}
  local available={}
  available= move_available(maze,y,x)
  --print_array(available)
  for i=1,#available do
    delta_x, delta_y= move_vector(available[i])
   local new_life= life_update(life,maze,y+delta_y,x+delta_x)
   move[ encode(new_life, x + delta_x, y + delta_y) ] = {available[i], new_life - life}
  end
  --for key,value in pairs(move) do 
    
  --   for j, w in ipairs(value) do
  --     print(key,w)
  --  end
  --end
  return move
  end

function initial_state(start)
 local encode= encode(start.vitality, start.entry_point.x,start.entry_point.y)
  return encode
  end
-- start, maze = init_game_data("mazes/maze_1.txt")
--a=(move_encode('3|2|5', maze))
