require "maze"
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
  local maze = Maze:new()
  maze:initialize(lines_table)
  return maze
end


-- builds the start table: it contains vitality of the player, entry point and exit points
function build_start_table(lines_table, maze)
  start = {}
  start.vitality = lines[1]
  assert(maze:entry_point_validity(), "The maze file must contain only one entry point.")
  local entry_point = maze:find_points("i")[1]
  start.entry_point = {}
  start.entry_point = entry_point
  start.exit_points = maze:find_points("u")
  return start
end

-- builds maze table and start table and checks for input errors
function init_game_data(filename)
  local lines = lines_from(filename)
  local maze = build_maze(lines)
  assert(maze:is_valid(), "Maze format is not correct: rows have not the same number of columns.")
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
-- print(start)
-- print(maze)
-- print(move_encode('3|2|5', maze))
