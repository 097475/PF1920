require "input-output"
require "maze"
require "maze_functions"
require "queue"
require "tbl"
require "stack"
require "priority_queue"
require "hashtable"
fun = require 'fun'
  
  function calculate_path_value(path, start_life)
    return fun.reduce(function(acc, x) return acc + x.life_change end ,start_life, path)
  end
  
  
  function find_best_path2(paths, life)
    local feasible_paths = fun.filter(function(path) return calculate_path_value(path, life) > 0 end, paths)
    return feasible_paths.state and fun.min_by(function(a, b) if #a < #b or (#a == #b and calculate_path_value(a, life) < calculate_path_value(b, life)) then return a else return b end end, feasible_paths) or nil
  end
  
    function find_best_path(paths, life)
    local feasible_paths = fun.filter(function(path) return calculate_path_value(path, life) > 0 end, paths)
    return not fun.is_null(feasible_paths) and fun.min_by(function(a, b) if #a < #b or (#a == #b and calculate_path_value(a, life) < calculate_path_value(b, life)) then return a else return b end end, feasible_paths) or nil
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
  return nil, find_best_path(paths, life)
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
      return nil, nil
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

function astar(maze, entry_point_encoded, exit_y, exit_x)
  function _astar(maze, queue, open, closed)
    local current = queue:Pop()
    if not current then return nil, nil
    else
      if open[current] then
        local current_values = open[current]
        local current_life, current_x, current_y = decode(current)
        open[current] = nil
        closed[current] = {move = current_values.move, life_change = current_values.life_change}
        if current_x == exit_x and current_y == exit_y then
          return current, closed -- last state, and hashmap with path to rebuild
        else
          local available_moves = move_encode(current, maze)
          for next_state, values in pairs(available_moves) do
            local next_life, next_x, next_y = decode(next_state)
            local next_state_values = { g = current_values.g + 1, h = manhattan(next_x, next_y, exit_x, exit_y), move = values.move, life_change = values.life_change }
            if closed[next_state] == nil and next_life > 0 then
              if open[next_state] == nil then
                open[next_state] = next_state_values
                queue:Add(next_state, next_state_values)
              else
                local alternative_node_values = open[next_state]
                if next_state_values.g < alternative_node_values.g then
                  open[next_state] = next_state_values
                  queue:Add(next_state, next_state_values)
                end
              end
            end
          end
        end
      end
      return _astar(maze, queue, open, closed)
    end
  end

  maze = maze:get_maze()
  local open = create_hashtable()
  local closed = create_hashtable()
  local queue = PriorityQueue.new(function(a, b) return ((a.g + a.h > b.g + b.h) or ((a.g + a.h == b.g + b.h) and a.life_change > b.life_change))  end)
  local init_life, init_x, init_y = decode(entry_point_encoded)
  local root_values = {g = 0, h = manhattan(init_x, init_y, exit_x, exit_y), move="", life_change=0 }
  open[entry_point_encoded] = root_values
  queue:Add(entry_point_encoded, root_values)
  return _astar(maze, queue, open, closed)
end

-- input: maze, entry point encoded, coordinates of exit point
-- output: list of all states
function bfs(maze, entry_point_encoded, exit_y, exit_x)
    maze = maze:get_maze()
    local visited = {}
    --queue containing paths
    local paths_queue = Queue:new()
    --queue containing the last cell for each path
    local last_cells = Queue:new()
    --initialize the first path adding the entry point and its life
    local first_path = create_hashtable()
    first[entry_point_encoded] = {move="", life_change=0}
    paths_queue:enqueue(first)
    last_cells:enqueue(entry_point_encoded)

    entry_life, entry_x, entry_y = decode(entry_point_encoded)
    table.insert(visited, string.match(entry_point_encoded, "|(.*)"))
    while not paths_queue:isEmpty() do

        local path = paths_queue:dequeue()
        local last_cell = last_cells:dequeue()
        local life, x, y = decode(last_cell)
        --current cell is the exit point: return the path
        if x == exit_x and y == exit_y then return last_cell, path end
        
        local available_moves = move_encode(last_cell, maze)
        for move, direction_life_difference in pairs(available_moves) do
            move_life, move_x, move_y = decode(move)
            if (not table.contains(visited, string.match(move, "|(.*)"))) and move_life > 0 then
                table.insert(visited, string.match(move, "|(.*)"))
                --update the path adding the move
                local new_path = copy_hashtable(path)
                new_path[move] = direction_life_difference
                --update queues
                paths_queue:enqueue(new_path)
                last_cells:enqueue(move)
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
      if (not table.contains(visited_dfs, string.match(move, "|(.*)"))) and move_life > 0 and current_path[move] == nil then
          local new_path = copy_hashtable(current_path)
          new_path[move] = direction_life_difference
          --call _rec_dfs for this new path
          local final, history = _rec_dfs(move, new_path, maze_grid)
          --if solution is not nil it means that a valid path has been found: return it
          if final ~= nil and history ~= nil then return final, history end
      end 
    end
    table.insert(visited_dfs, string.match(current_cell_encoded, "|(.*)"))
  end

  --this table is set to global: _rec_dfs will refer to it
  visited_dfs = {}
  local maze = maze_metatable:get_maze()
  exit_x = exit_x
  exit_y = exit_y

  --initialize hashtable with the first cell
  local path = create_hashtable()
  path[entry_point_encoded] = {move = "", life_change = 0}

  return _rec_dfs(entry_point_encoded, path, maze)
end


--DIJKSTRA
function dijkstra(maze_metatable, entry_point_encoded, exit_y, exit_x)
    local entry_life, entry_x, entry_y = decode(entry_point_encoded)
    local maze = maze_metatable:get_maze()
    local walkable_cells = maze_metatable:get_walkable_cells()
    --preparation of tables for building priority queue
    local distances = {}
    local cells = {}
    for i = 1,#walkable_cells do
        cells[i] = {}
        cells[i].x = walkable_cells[i].x
        cells[i].y = walkable_cells[i].y
        --entry point has defined distance, life and direction_life_difference
        if entry_x == walkable_cells[i].x and entry_y == walkable_cells[i].y then
            distances[i] = 0
            cells[i].life = entry_life
            cells[i].direction_life_difference = {move = "", life_change = 0}
        --others are initialized with huge distance
        else 
            distances[i] = 10000
            cells[i].life = nil
            cells[i].direction_life_difference = nil
        end
    end
    local priority_queue = PriorityQueue:CreateFromTables(cells, distances)

    --hashtable storing visited cells
    local visited = create_hashtable()
    
    while priority_queue:Size() > 0 do

        local cell, distance = priority_queue:Pop()
        --if a cell life is nil, that means that maze has no solution
        if cell.life == nil then return nil, nil end
        
        --retrieve index from cells table
        local cell_index = nil
        for k,v in pairs(cells) do
            if v.x == cell.x and v.y == cell.y then cell_index = k break end
        end
        assert(cell_index ~= nil, "This cell does not exist in the cells table.")

        --update cells and distances tables for remving current cell from priority queue and updating distances too
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
                --since the graph is not weighted, the increment of distance from a previous cell is 1
                if distance + 1 < distances[index] then
                  distances[index] = distance + 1
                  cells[index].direction_life_difference = direction_life_difference
                  cells[index].life = move_life
                end
              end   
          end
        end
        priority_queue = PriorityQueue:CreateFromTables(cells, distances)
        visited[encode(cell.life, cell.x, cell.y)] = cell.direction_life_difference

        if cell.x == exit_x and cell.y == exit_y then return encode(cell.life, cell.x, cell.y), visited end
    end
end


-- check when history is null because no path exists
function create_solver2(algorithm)
  solve = function(maze_filepath) 
            local start, maze = init_game_data(maze_filepath)
            local history_tables = {}
            for i,v in ipairs(start.exit_points) do
              local final_state, visited = algorithm(maze,initial_state(start),v.y,v.x)  --should only return the total 
              if algorithm ~= find_all_paths and algorithm ~= bruteforce then
                history = gen_path(final_state, visited)
              else
                history = visited
              end
              table.insert(history_tables, history)
            end
            return find_best_path(history_tables, start.vitality) -- return the path
          end
  return solve
end

-- check when history is null because no path exists
function create_solver(algorithm)
  function run(start, maze) 
    for i,v in ipairs(start.exit_points) do
      local final_state, visited = algorithm(maze,initial_state(start),v.y,v.x)  --should only return the total 
        if algorithm ~= find_all_paths and algorithm ~= bruteforce then
          history = gen_path(final_state, visited)
        else
          history = visited
        end
      coroutine.yield(history)
    end
  end
  
  solve = function(maze_filepath) 
            local history_tables = {}
            local start, maze = init_game_data(maze_filepath)
            return find_best_path(fun.totable(fun.take(function(x) return x end, fun.tabulate(coroutine.wrap(function() run(start, maze) end)))), start.vitality)
          end
          
  return solve
end


--local start, maze = init_game_data("mazes/maze_1.txt")
--local path, history = bfs(maze,initial_state(start),2,10)
--local path, history = dfs(maze,initial_state(start),4,6)

--local best_history = create_solver(bruteforce)("mazes/maze_1.txt")

--local move = table.remove(history)


--local path, _history = dijkstra(maze,initial_state(start),4,6)
--astar(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x )

--write_maze("test2.lua", start, maze, best_history)
--local final, history = rec_dfs(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x)
--print(final)


--print(gen_path("8|4|6", history))
--print("---")

--local best_history = create_solver(bfs)("mazes/maze_1.txt")
--for k, d in pairs(best_history) do
--  print(k, d.move, d.life_change)
  
--end

local t = create_solver(rec_dfs)("mazes/maze_1.txt")
--bruteforce(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x )
--find_all_paths(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x )
