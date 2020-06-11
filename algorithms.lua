require "input-output"
require "maze"
require "maze_functions"
require "lib/queue"
require "tbl"
require "lib/priority_queue"
require "hashtable"
fun = require 'lib/fun'
  
  function calculate_path_value(path, start_life)
    return fun.reduce(function(acc, x) return acc + x.life_change end ,start_life, path)
  end
  
    function find_best_path(paths, life)
    local feasible_paths = fun.filter(function(path) return calculate_path_value(path, life) > 0 end, paths)
    return not fun.is_null(feasible_paths) and fun.min_by(function(a, b) if #a < #b or (#a == #b and calculate_path_value(a, life) < calculate_path_value(b, life)) then return a else return b end end, feasible_paths) or nil
  end
  

function bruteforce(maze, entry_point_encoded, exit_y, exit_x)
  
  local paths = {}
  
  function expand_node(node, current_path, move_sequence)
    local life, current_x, current_y = decode(node)
    
    if current_x == exit_x and current_y == exit_y then
      paths[#paths+1] = table.copy(move_sequence)
      current_path[node] = nil
      move_sequence[#move_sequence] = nil
    else
      local available_moves = generate_next_states(node, maze)
      for next_state, values in pairs(available_moves) do    
        if current_path[next_state] == nil then
          current_path[next_state] = true
          move_sequence[#move_sequence + 1] = values
          expand_node(next_state, current_path, move_sequence)
        end
      end
    current_path[node] = nil
    move_sequence[#move_sequence] = nil
    end
  end
  
  local current_path = create_hashtable()
  current_path[entry_point_encoded] = true
  expand_node(entry_point_encoded, current_path, {})
  
  local life, _, _ = decode(entry_point_encoded)
  return find_best_path(paths, life)
end


function find_all_paths(maze, entry_point_encoded, exit_y, exit_x)
  local visited = create_hashtable()
  local paths = {}
  function depth_first_search(node, visited, current_path)

    if #visited[node].parents == 0 then
      paths[#paths+1] = table.reverse(current_path)
    end
    
    for i, parent in ipairs(visited[node].parents) do
      current_path[#current_path+1] = {move = parent.move, life_change = parent.life_change}
      depth_first_search(parent.state, visited, current_path)
    end
    
    current_path[#current_path] = nil
    
  end
  
  function breadth_first_search(queue, open)
      local current = queue:dequeue()
      if not current then return nil end
      
      local current_life, current_x, current_y = decode(current)
      local current_level = open[current].level
      
      if current_x == exit_x and current_y == exit_y then
        visited[current] = open[current]
        return current
      end
      
      local available_moves = generate_next_states(current, maze)
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
      return breadth_first_search(queue, open ,visited)
    end
  
  local queue = Queue:new()
  local open = create_hashtable()
  queue:enqueue(entry_point_encoded)
  open[entry_point_encoded] = {level=0, parents = {}}
    
  local target = breadth_first_search(queue, open)
    

  if target then depth_first_search(target, visited, {}) end
  local life, _, _ = decode(entry_point_encoded)
  return find_best_path(paths, life)
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
          local available_moves = generate_next_states(current, maze)
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

  local open = create_hashtable()
  local closed = create_hashtable()
  local queue = PriorityQueue.new(function(a, b) return ((a.g + a.h > b.g + b.h) or ((a.g + a.h == b.g + b.h) and a.life_change > b.life_change))  end)
  local init_life, init_x, init_y = decode(entry_point_encoded)
  local root_values = {g = 0, h = manhattan(init_x, init_y, exit_x, exit_y), move="", life_change=0 }
  open[entry_point_encoded] = root_values
  queue:Add(entry_point_encoded, root_values)
  return gen_path(_astar(maze, queue, open, closed))
end

-- input: maze, entry point encoded, coordinates of exit point
-- output: list of all states
function bfs(maze, entry_point_encoded, exit_y, exit_x)
  function _bfs(paths_queue, last_cells, visited)
    local path = paths_queue:dequeue()
    if not path then return nil, nil end
    local last_cell = last_cells:dequeue()
    local life, x, y = decode(last_cell)
    if x == exit_x and y == exit_y then return last_cell, path end
        
    local available_moves = generate_next_states(last_cell, maze)
    for move, direction_life_difference in pairs(available_moves) do
        move_life, move_x, move_y = decode(move)
        if not visited[move] and move_life > 0 then
            visited[move] = true
            local new_path = copy_hashtable(path)
            new_path[move] = direction_life_difference
            paths_queue:enqueue(new_path)
            last_cells:enqueue(move)
        end
    end
    return _bfs(paths_queue, last_cells, visited)
  end

  local visited = create_hashtable()
  local paths_queue = Queue:new()
  local last_cells = Queue:new()
  local first = create_hashtable()
  first[entry_point_encoded] = {move="", life_change=0}
  paths_queue:enqueue(first)
  last_cells:enqueue(entry_point_encoded)
  entry_life, entry_x, entry_y = decode(entry_point_encoded)
  visited[entry_point_encoded] = true 
    
  return gen_path(_bfs(paths_queue, last_cells, visited))
    
end


--recursive dfs
function rec_dfs(maze, entry_point_encoded, exit_y, exit_x)
  
  local visited = create_hashtable()
  
  local function _rec_dfs(current_cell_encoded, current_path, maze_grid)
    local life, x, y = decode(current_cell_encoded)
    if x == exit_x and y == exit_y then
      return current_cell_encoded, current_path end
    
    local available_moves = generate_next_states(current_cell_encoded, maze_grid)
    for move, direction_life_difference in pairs(available_moves) do
      move_life, move_x, move_y = decode(move)
      if not visited[move] and move_life > 0 and current_path[move] == nil then
          local new_path = copy_hashtable(current_path)
          new_path[move] = direction_life_difference
          local final, history = _rec_dfs(move, new_path, maze_grid)
          if final and history then return final, history end
      end 
    end
    visited[current_cell_encoded] = true
  end

  local path = create_hashtable()
  path[entry_point_encoded] = {move = "", life_change = 0}
  return gen_path(_rec_dfs(entry_point_encoded, path, maze))
end


--DIJKSTRA
function dijkstra(maze, entry_point_encoded, exit_y, exit_x)
    local entry_life, entry_x, entry_y = decode(entry_point_encoded)
    local walkable_cells = maze:get_walkable_cells()
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
        --if a cell life is nil, that means that maze has no solution
        if cell.life == nil then return nil, nil end
        
        --retrieve index from cells table
        local cell_index = nil
        for k,v in pairs(cells) do
            if v.x == cell.x and v.y == cell.y then cell_index = k break end
        end
        assert(cell_index ~= nil, "This cell does not exist in the cells table.")

        table.remove(distances, cell_index)
        table.remove(cells, cell_index)
        

        local available_moves = generate_next_states(encode(cell.life, cell.x, cell.y), maze)

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
            return gen_path(encode(cell.life, cell.x, cell.y), reversed_history)
        end
    end
end


-- check when history is null because no path exists
function create_solver(algorithm)
  function run(start, maze) 
    for i,v in ipairs(start.exit_points) do
      local history = algorithm(maze,initial_state(start),v.y,v.x)  --should only return the total 
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

--local t = create_solver(astar)("mazes/maze_1.txt")
--print(t)
--bruteforce(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x )
--find_all_paths(maze, initial_state(start), start.exit_points[1].y, start.exit_points[1].x )
