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
    if tree[string.match(final, "|(.*)")].move == "" then
      return history
    else
      table.insert(history, 1, tree[string.match(final, "|(.*)")])
      return _gen_path(invert_move(final, tree[string.match(final, "|(.*)")].move, tree[string.match(final, "|(.*)")].life_change), history)
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

--input x position
 --output: move for x parameter "L" or "R"
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
  
  --input: y position
  -- output: move for y parameter "D" or "U"
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
  
-- input maze and coordinate x,y
-- output: list rapresenting moves available for a given coordinate
function move_available(maze,y,x)
   local available = {}
   if maze[y][x] == "m" or maze[y][x]==nil then
     return available
   end
     for z= -1,1,2 do
       if maze[y][x+z] ~= "m" and maze[y][x+z]~=nil and maze[y][x+z]~="p" then
        available[#available+1]=get_move_x(z)
      end
      if maze[y+z][x] ~= "m" and maze[y+z][x]~=nil and maze[y][x+z]~="p" then
        
        available[#available +1 ]=get_move_y(z)
       
      end
   end
   return available
 end
 
 --input: life, maze, coordinates y,x
 -- output: new life update according to logic of program
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

-- input: state encoding, maze
-- output: return move available in a specific format with life|position and move|life change
function move_encode(encode_state, maze)
  local life,x,y=decode(encode_state)
  local move={}
  local available={}
  available= move_available(maze,y,x)
  --print_array(available)
  for i=1,#available do
    delta_x, delta_y= move_vector(available[i])
   local new_life= life_update(life,maze,y+delta_y,x+delta_x)
   move[ encode(new_life, x + delta_x, y + delta_y) ] = {move=available[i], life_change = new_life - life}
  end
  return move
  end

--input: starting position in the maze with vitality, entry point x,y
--output: return state encode with life|x|y
function initial_state(start)
 local encode= encode(start.vitality, start.entry_point.x,start.entry_point.y)
  return encode
end