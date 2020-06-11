-- input: life, x, y as numbers e.g. 5, 1, 2
-- output: string representing the state e.g. "5|1|2"
-- [PURE]
function encode(life, x, y)
  return life .. "|" .. x .. "|" .. y 
end

-- input: string representing the state e.g. "5|1|2"
-- output: life, x, y as numbers e.g. 5, 1, 2
-- [PURE]
function decode(str)
  local values = {}
  for i in string.gmatch(str, "%-?%d+") do
    table.insert(values, tonumber(i))
  end
  return table.unpack(values)
end

-- input: character D, U, L or R, e.g. "L"
-- output: delta_x, delta_y representing the change in x and y, e.g. -1, 0
-- [PURE]
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
      print("Error: move doesn't exist!")
    end
    return delta_x, delta_y
  end

-- input: state string final, hash table tree e.g. "5|3|2", {"5|3|2" = {move="R", life_change=-2}, "5|2|2" = {move="D", life_change=1}, "5|2|1" = {move="", life_change=0}}
-- output: table representing the steps taken in the path using DULR and life change at each step e.g. {{move="", life_change=0}, {move="D", life_change=1}, {move="R", life_change=-2} }
-- [PURE]
function gen_path(final, tree)
  
  -- input: encoded state, move used to get to state, life_chance applied after getting to state, e.g. "5|3|2", "R", -2
  -- output: encoded previous state e.g. "5|2|2"
  -- [PURE]
  local function invert_move(state, move, life_change)
    local life, x, y = decode(state)
    local delta_x, delta_y = move_vector(move)
    return encode(life - life_change, x - delta_x, y - delta_y)
  end
  
  
  -- input: state string final, history table to be filled with moves taken from entry to exit starting to fill from exit. e.g. "5|3|2", {} initially
  -- output: table representing the steps taken from entry to exit using DULR and life change at each step e.g. {{move="", life_change=0}, {move="D", life_change=1}, {move="R", life_change=-2} }
  local function _gen_path(final, history)
    if tree[final].move == "" then
      return history
    else
      table.insert(history, 1, tree[final])
      return _gen_path(invert_move(final, tree[final].move, tree[final].life_change), history)
    end
  end
  
  
  if not final then return nil else return _gen_path(final, {}) end
end

--input x variation in next position, e.g. 1
--output: corresponding move, e.g. "R"
--[PURE]
function get_move_x(x)
  local position
  if  x == -1  then
    position = "L"
  elseif x == 1  then
    position = "R"
  else 
    print("Error")
  end
  return position
end
  
--input y variation in next position, e.g. 1
--output: corresponding move, e.g. "D"
--[PURE]
  function get_move_y(y)
    local position
    if y == 1 then
      position = "D"
    elseif y == -1 then
      position = "U"
    else 
      print("Error")
    end
    return position
  end
  
  
-- input maze and coordinate x,y
-- output: list rapresenting moves available for a given coordinate, e.g. {"D","L","R"}
--[PURE]
function get_available_moves(maze,y,x)
  maze = maze:get_maze()
  local available = {}
  for z= -1,1,2 do
    if maze[y][x+z] ~= "m" and maze[y][x+z]~=nil and maze[y][x+z]~="p" then
      available[#available+1] = get_move_x(z)
    end
    if maze[y+z][x] ~= "m" and maze[y+z][x]~=nil and maze[y+z][x]~="p" then
      available[#available+1] = get_move_y(z)
    end
  end
  return available
 end
 
 -- input: current life, value of the maze cell. e.g. current_life = 5, cell = 6
 -- output: new value for live. e.g. 3
 --[PURE]
function update_life(life, cell)
  local rules = {
    i = function(x) return x end,
    u = function(x) return x end,
    [0] = function(x) return x end,
    [1] = function(x) return x + 1 end,
    [2] = function(x) return x + 2 end,
    [3] = function(x) return x + 3 end,
    [4] = function(x) return x + 4 end,
    [5] = function(x) return x - 1 end,
    [6] = function(x) return x - 2 end,
    [7] = function(x) return x - 3 end,
    [8] = function(x) return x - 4 end,
    [9] = function(x) return x * 2 end,
    f = function(x) return (x / 2) < 1 and 0 or x / 2 end,
    p = function(x) return 0 end
  }
  return rules[cell](life)
end

-- input: encoded state, maze
-- output: return moves available with format "life|x|y" = {move, life_change} e.g. "5|3|2" = {"D", "-2"}
--[PURE]
function generate_next_states(encoded_state, maze)
  local life, x, y = decode(encoded_state)
  local available_moves = get_available_moves(maze,y,x)
  
  local function generate_state(available_moves, next_states)
    if #available_moves > 0 then
      local move = table.remove(available_moves)
      local delta_x, delta_y = move_vector(move)
      local new_life= update_life(life, maze:get_maze()[y+delta_y][x+delta_x])
      next_states[ encode(new_life, x + delta_x, y + delta_y) ] = {move = move, life_change = new_life - life}
      return generate_state(available_moves, next_states)
    else return next_states end
  end

  return generate_state(available_moves, {})
end

--input: start table with initial vitality, entry point and exit points
--output: return initial state encoded e.g. "5|3|2" for initial life 5, initial position x = 3, y = 2
--[PURE]
function initial_state(start)
  return encode(start.initial_life, start.entry_point.x,start.entry_point.y)
end