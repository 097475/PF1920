require "input-output"
require "maze"
require "maze_functions"
require "queue"
require "tbl"
require "stack"
require "priority_queue"
require "hashtable"

  function calculate_path_value(path, start_life)
    for i, values in ipairs(path) do
      start_life = start_life + values.life_change
    end
    return start_life
  end
  
  
  function find_best_path(shortest_paths, life)
    local best_index = 0
    local best_value = math.huge
    for i, path in ipairs(shortest_paths) do
      local value =  calculate_path_value(shortest_paths[i], life)
      if value < best_value and value > 0 then
        best_index = i
        best_value = value
      end
    end
    return shortest_paths[best_index]
  end
  
  

function bruteforce(maze, entry_point_encoded, exit_y, exit_x)
  
  local paths = {}
  
  function expand_node(node, path, current_path)
    local life, current_x, current_y = decode(node)
    
    if current_x == exit_x and current_y == exit_y then
      paths[#paths+1] = table.copy(current_path)
      path[node] = nil
      current_path[#current_path] = nil
    else
      local available_moves = move_encode(node, maze)
      for next_state, values in pairs(available_moves) do    
        if path[next_state] == nil then
          path[next_state] = true
          current_path[#current_path + 1] = values
          expand_node(next_state, path, current_path)
        end
      end
    path[node] = nil
    current_path[#current_path] = nil
    end
  end
  
  
  maze = maze:get_maze()
  local path = create_hashtable()
  path[entry_point_encoded] = true
  expand_node(entry_point_encoded, path, {})
  
  local life, _, _ = decode(entry_point_encoded)
  return nodeTo, find_best_path(paths, life)
end


function find_all_paths(maze, entry_point_encoded, exit_y, exit_x)
  
  function depth_first_search(node, visited, paths, current_path)

    
    if #visited[node].parents == 0 then
      paths[#paths+1] = table.reverse(current_path)
    end
    
    for i, parent in ipairs(visited[node].parents) do
      current_path[#current_path+1] = {move = parent.move, life_change = parent.life_change}
      depth_first_search(parent.state, visited, paths, current_path)
    end
    
    current_path[#current_path] = nil
    
  end
  
    maze = maze:get_maze()
    local queue = Queue:new()
    local open = create_hashtable()
    local visited = create_hashtable()
    queue:enqueue(entry_point_encoded)
    open[entry_point_encoded] = {level=0, parents = {}}
    
    local nodeTo = nil
    while not queue:isEmpty() do
      local current = queue:dequeue()
      local current_life, current_x, current_y = decode(current)
      local current_level = open[current].level
      
      if current_x == exit_x and current_y == exit_y then
        nodeTo = current
        visited[current] = open[current]
        break
      end
      
      local available_moves = move_encode(current, maze)
      for next_state, values in pairs(available_moves) do
        if visited[next_state] == nil then
          if open[next_state] == nil then
            local next_node = {level=-1, parents = {}}
            queue:enqueue(next_state)
            open[next_state] = next_node
          end
            local next_node = open[next_state]
            if current_level ~= next_node.level then
              next_node.parents[#next_node.parents + 1] = {state=current, move = values.move, life_change = values.life_change} 
              next_node.level = current_level + 1
            end
        end
      end
      
      visited[current] = open[current]
      open[current] = nil
      
    end
    
    if nodeTo == nil then
      return {}
    end
    
    local paths = {}
    depth_first_search(nodeTo, visited, paths, {})
    
    local life, _, _ = decode(entry_point_encoded)
    return nodeTo, find_best_path(paths, life)
end






-- input: x and y coordinates of two points
-- output: manhattan distance
function manhattan(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end
--string.match(current, "|(.*)")
function astar(maze, entry_point_encoded, exit_y, exit_x)
  maze = maze:get_maze()
  local open = {}
  local closed = {}
  local queue = PriorityQueue.new(function(a, b) return ((a.g + a.h > b.g + b.h) or ((a.g + a.h == b.g + b.h) and a.life_change > b.life_change))  end)
  local init_life, init_x, init_y = decode(entry_point_encoded)
  local root_values = {g = 0, h = manhattan(init_x, init_y, exit_x, exit_y), move="", life_change=0 }
  open[string.match(entry_point_encoded, "|(.*)")] = root_values
  queue:Add(entry_point_encoded, root_values)
  while queue:Size() > 0 do
    local current = queue:Pop()
    --print(current)
    if open[string.match(current, "|(.*)")] then
      local current_values = open[string.match(current, "|(.*)")]
      local current_life, current_x, current_y = decode(current)
      open[string.match(current, "|(.*)")] = nil
      closed[string.match(current, "|(.*)")] = {move = current_values.move, life_change = current_values.life_change}
      if current_x == exit_x and current_y == exit_y then
        return current, closed -- last state, and hashmap with path to rebuild
      else
        local available_moves = move_encode(current, maze)
        for next_state, values in pairs(available_moves) do
          local next_life, next_x, next_y = decode(next_state)
          local next_state_values = { g = current_values.g + 1, h = manhattan(next_x, next_y, exit_x, exit_y), move = values.move, life_change = values.life_change }
          if closed[string.match(next_state, "|(.*)")] == nil and next_life > 0 then
            if open[string.match(next_state, "|(.*)")] == nil then
              open[string.match(next_state, "|(.*)")] = next_state_values
              queue:Add(next_state, next_state_values)
            else
              local alternative_node_values = open[string.match(next_state, "|(.*)")]
              if next_state_values.g < alternative_node_values.g then
                open[string.match(next_state, "|(.*)")] = next_state_values
                queue:Add(next_state, next_state_values)
              end
            end
          end
        end
      end
    end
  end
end
-- input: maze, entry point encoded, coordinates of exit point
-- output: list of all states
function bfs(maze, entry_point_encoded, exit_y, exit_x)
    maze = maze:get_maze()
    local visited = {}
    local paths_queue = Queue:new()
    local directions_queue = Queue:new()
    local path
    local directions_path
    paths_queue:enqueue({entry_point_encoded})
    directions_queue:enqueue({{move="", life_change=0}})
    entry_life, entry_x, entry_y = decode(entry_point_encoded)
    table.insert(visited, {entry_y, entry_x})
    while not paths_queue:isEmpty() do
        path = paths_queue:dequeue()
        directions_path = directions_queue:dequeue()
        local last_cell = path[#path]
        local life, x, y = decode(last_cell)
        if x == exit_x and y == exit_y then return path, directions_path end
        
        local available_moves = move_encode(last_cell, maze)
        for move, direction_life_difference in pairs(available_moves) do
            move_life, move_x, move_y = decode(move)
            if (not table.contains(visited, {move_y, move_x})) and move_life > 0 then
                table.insert(visited, {move_y, move_x})
                local new_path = table.copy(path)
                local new_direction = table.copy(directions_path)
                table.insert(new_path, move)
                table.insert(new_direction, direction_life_difference)
                paths_queue:enqueue(new_path)
                directions_queue:enqueue(new_direction)
            end
        end
    end
    return false
end

-- input: maze, entry point encoded, coordinates of exit point
-- output: list of all states
-- DFS 
function dfs(maze, entry_point_encoded, exit_y,exit_x)
    maze = maze:get_maze()
    local visited = {}
    local paths_stack = Stack:Create()
    local directions_stack = Stack:Create()
    local path
    local directions_path
    paths_stack:push({entry_point_encoded})
    directions_stack:push({{move="", life_change=0}})
    entry_life, entry_x, entry_y = decode(entry_point_encoded)
    table.insert(visited, {entry_y, entry_x})
    while paths_stack:getn() ~= 0 do
        path = paths_stack:pop()
        directions_path = directions_stack:pop()
        local last_cell = path[#path]
        local life, x, y = decode(last_cell)
        
        if x == exit_x and y == exit_y then
          local history=create_hashtable()
          for i=1,#directions_path do
            local cell=path[i]
            local direction= directions_path[i]
            history[cell] = direction
            end
          return last_cell, history end
        local available_moves = move_encode(last_cell, maze)
        
        for move, direction_life_difference in pairs(available_moves) do
            local move_life, move_x, move_y = decode(move)
            if  table.contains(visited, {move_y, move_x}) == false and move_life > 0 then
                table.insert(visited, {move_y, move_x})
                local new_path = table.copy(path)
                local new_direction = table.copy(directions_path)
                table.insert(new_path, move)
                table.insert(new_direction, direction_life_difference)
                paths_stack:push(new_path)
                directions_stack:push(new_direction)
            end
        end
    end
    return false
end

--recursive dfs
function rec_dfs(maze_metatable, entry_point_encoded, exit_y, exit_x)
  local function _rec_dfs(current_cell_encoded, current_path, maze_grid)
    local life, x, y = decode(current_cell_encoded)
    if x == exit_x and y == exit_y then
      return current_cell_encoded, current_path end
    
    local available_moves = move_encode(current_cell_encoded, maze_grid)
    for move, direction_life_difference in pairs(available_moves) do
      move_life, move_x, move_y = decode(move)
      if (not table.contains(visited, string.match(move, "|(.*)"))) and move_life > 0 and current_path[move] == nil then
          local new_path = copy_hashtable(current_path)
          new_path[move] = direction_life_difference
          local final, history = _rec_dfs(move, new_path, maze_grid)
          if final ~= nil and history ~= nil then return final, history end
      end 
    end
    table.insert(visited, string.match(current_cell_encoded, "|(.*)"))
  end

  visited = {}
  local maze = maze_metatable:get_maze()
  exit_x = exit_x
  exit_y = exit_y

  --table.insert(visited, string.match(entry_point_encoded, "|(.*)"))
  local path = create_hashtable()
  path[entry_point_encoded] = {move = "", life_change = 0}
  return _rec_dfs(entry_point_encoded, path, maze)
end


--DIJKSTRA
function dijkstra(maze_metatable, entry_point_encoded, exit_y, exit_x)
    local entry_life, entry_x, entry_y = decode(entry_point_encoded)
    local maze = maze_metatable:get_maze()
    local walkable_cells = maze_metatable:get_walkable_cells()
    local distances = {}
    local cells = {}
    for i = 1,#walkable_cells do
        cells[i] = {}
        cells[i].x = walkable_cells[i].x
        cells[i].y = walkable_cells[i].y
        cells[i].previous = nil
        if entry_x == walkable_cells[i].x and entry_y == walkable_cells[i].y then
            distances[i] = 0
            cells[i].life = entry_life
            cells[i].direction_life_difference = {move = "", life_change = 0}
        else 
            distances[i] = 10000
            cells[i].life = nil
            cells[i].direction_life_difference = nil
        end
    end
    local priority_queue = PriorityQueue:CreateFromTables(cells, distances)
    local visited = {}
    
    while priority_queue:Size() > 0 do

        local cell, distance = priority_queue:Pop()
        assert(cell.life ~= nil, "There was an error in picking a cell from the priority queue.")
        
        --retrieve index from cells table
        local cell_index = nil
        for k,v in pairs(cells) do
            if v.x == cell.x and v.y == cell.y then cell_index = k break end
        end
        assert(cell_index ~= nil, "This cell does not exist in the cells table.")

        table.remove(distances, cell_index)
        table.remove(cells, cell_index)
        

        local available_moves = move_encode(encode(cell.life, cell.x, cell.y), maze)

        for move, direction_life_difference in pairs(available_moves) do
            local move_life, move_x, move_y = decode(move)
            if move_life > 0 then
              --retrieve index from cells table
                local index = nil
                for k,v in pairs(cells) do
                    if v.x == move_x and v.y == move_y then index = k break end
                end
                if index ~= nil then
                    if distance + 1 < distances[index] then
                        distances[index] = distance + 1
                        cells[index].direction_life_difference = direction_life_difference
                        cells[index].life = move_life
                        cells[index].previous = encode(cell.life, cell.x, cell.y)
                    end
                end
                
            end
        end
        priority_queue = PriorityQueue:CreateFromTables(cells, distances)
        table.insert(visited, {encode(cell.life, cell.x, cell.y), cell.direction_life_difference, cell.previous})
        if cell.x == exit_x and cell.y == exit_y then
            local reversed_history = create_hashtable()
            local current_cell = visited[#visited]
            local previous = current_cell[3]
            while previous ~= nil do
                reversed_history[current_cell[1]] = current_cell[2]
                for _,k in pairs(visited) do
                    if previous == k[1] then
                        current_cell = k
                        previous = k[3]
                    end
                end
            end
            reversed_history[visited[1][1]] = visited[1][2]
            return encode(cell.life, cell.x, cell.y), reversed_history
        end
    end
end


-- check when history is null because no path exists
function create_solver(algorithm)
  solve = function(maze_filepath) 
            local start, maze = init_game_data(maze_filepath)
            local history_tables = {}
            for i,v in ipairs(start.exit_points) do
              local final_state, visited = algorithm(maze,initial_state(start),v.y,v.x)  --should only return the total hash table and final state
              if(algorithm == astar or algorithm == dijkstra or algorithm == dfs or algorithm == rec_dfs) then
                history = gen_path(final_state, visited)
                --for k,v in pairs(history) do
                  --print(k, v.move, v.life_change)
                --end
              else
                history = visited
              end
              -- history = gen_path(final_state, visited)
              table.insert(history_tables, history)
            end
            -- <-- here, select the best history in history_tables, for now we select the first-->
            return history_tables[1] -- return the path
          end
  return solve
end

--local start, maze = init_game_data("mazes/multiple_paths.txt")
--local path, history = bfs(maze,initial_state(start),2,10)
--local path, history = dfs(maze,initial_state(start),4,6)
--local path, _history = dijkstra(maze,initial_state(start),4,6)
--astar(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x )
--for _, d in pairs(path) do
--  print(d)
--end

--local final, history = rec_dfs(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x)
--print(final)
--for k,d in pairs(history) do
--  print(k, d.move, d.life_change)
--end

--print(gen_path("8|4|6", history))
--print("---")

--local best_history = create_solver(astar)("mazes/maze_1.txt")
--for k, d in pairs(best_history) do
--  print(k, d.move, d.life_change)
  
--end

--create_solver(bruteforce)("mazes/maze_1.txt")
--bruteforce(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x )
--find_all_paths(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x )
