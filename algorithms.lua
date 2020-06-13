require "input-output"
require "maze"
require "maze_functions"
require "lib/queue"
require "table_functions"
require "lib/priority_queue"
require "hashtable"
fun = require 'lib/fun'

--input: path table and initial life e.g. {{move="D", life_change=-1},{move="R", life_change=2}}, 5
--output: final value of life at the end of path
--[PURE]
function calculate_path_life(path, start_life)
  return fun.reduce(function(acc, x) return acc + x.life_change end ,start_life, path)
end
  
--input: table of path tables and initial life e.g. {{{move="D", life_change=-1},{move="R", life_change=2}}, {{move="R", life_change=1},{move="U", life_change=-2}}}, 5
--output: a path table which represents the solution of the maze or nil if there isn't one
--[PURE]
function find_best_path(paths, start_life)
  local feasible_paths = fun.filter(function(path) return calculate_path_life(path, start_life) > 0 end, paths)
  return not fun.is_null(feasible_paths) and fun.min_by(function(a, b) if #a < #b or (#a == #b and calculate_path_life(a, start_life) < calculate_path_life(b, start_life)) then return a else return b end end, feasible_paths) or nil
end
  
-- Bruteforce algorithm
-- input: maze, the encoded initial state, x and y of the exit that we want to reach
-- output: a path table which represents the solution of the maze or nil if there isn't one
-- [PURE]
function bruteforce(maze, entry_point_encoded, exit_x, exit_y)
  
  local paths = {}
  local current_path = create_hashtable()
  current_path[entry_point_encoded] = true
  
  --input: encoded initial state, empty table that will contain the sequences of moves for a given path
  --output: none, paths table modified by side effect
  local function expand_node(node, move_sequence)
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
          expand_node(next_state, move_sequence)
        end
      end
    current_path[node] = nil
    move_sequence[#move_sequence] = nil
    end
  end
  

  expand_node(entry_point_encoded, {})
  
  local life, _, _ = decode(entry_point_encoded)
  return find_best_path(paths, life)
end


-- Algorithm that finds all possible shortest paths from entry to exit
-- input: maze, the encoded initial state, x and y of the exit that we want to reach
-- output: a path table which represents the solution of the maze or nil if there isn't one
-- [PURE]
function find_all_shortest_paths(maze, entry_point_encoded, exit_x, exit_y)
  local visited = create_hashtable()
  local paths = {}
  
  -- input: the encoded target state, empty table
  -- output: none, paths table modified by side effect
  local function depth_first_search(node, current_path)

    if #visited[node].parents == 0 then
      paths[#paths+1] = table.reverse(current_path)
    end
    
    for i, parent in ipairs(visited[node].parents) do
      current_path[#current_path+1] = {move = parent.move, life_change = parent.life_change}
      depth_first_search(parent.state, current_path)
    end
    
    current_path[#current_path] = nil
    
  end
  
  local queue = Queue:new()
  local open = create_hashtable()
  queue:enqueue(entry_point_encoded)
  open[entry_point_encoded] = {level=0, parents = {}}
  
  -- input: none, taken from function context
  -- output: none, visited hashtable modified by side effect
  local function breadth_first_search()
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
      return breadth_first_search()
    end
  

  local target = breadth_first_search()
  if target then depth_first_search(target, {}) end
  
  local life, _, _ = decode(entry_point_encoded)
  return find_best_path(paths, life)
end

-- A* algorithm
-- input: maze, the encoded initial state, x and y of the exit that we want to reach
-- output: a path table which represents the solution of the maze or nil if there isn't one
-- [PURE]
function astar(maze, entry_point_encoded, exit_x, exit_y)
  
  -- input: x and y coordinates of two points
  -- output: manhattan distance
  --[PURE]
  local function manhattan(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
  end
  
  local open = create_hashtable()
  local closed = create_hashtable()
  local queue = PriorityQueue.new(function(a, b) return ((a.g + a.h > b.g + b.h) or ((a.g + a.h == b.g + b.h) and a.current_life > b.current_life))  end)
  local init_life, init_x, init_y = decode(entry_point_encoded)
  local root_values = {g = 0, h = manhattan(init_x, init_y, exit_x, exit_y), move="", life_change=0, current_life = init_life }
  open[entry_point_encoded] = root_values
  queue:Add(entry_point_encoded, root_values)
  
  --input: none, taken from function context
  --output: final encoded state and hashtable of visited (closed) nodes
  local function _astar()
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
            local next_state_values = { g = current_values.g + 1, h = manhattan(next_x, next_y, exit_x, exit_y), move = values.move, life_change = values.life_change, current_life = next_life}
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
      return _astar()
    end
  end

  return gen_path(_astar())
end

-- Breadth-First-Search algorithm
-- input: maze, the encoded initial state, x and y of the exit that we want to reach
-- output: a path table which represents the solution of the maze or nil if there isn't one
-- [PURE]
function bfs(maze, entry_point_encoded, exit_x, exit_y)
  
  local visited = create_hashtable()
  local queue = Queue:new()
  queue:enqueue(entry_point_encoded)
  visited[entry_point_encoded] = {move="", life_change=0} 
  
  -- input: none, taken from function context
  -- output: final encoded state and hashtable of visited nodes
  local function _bfs()
    local last_cell = queue:dequeue()
    if not last_cell then return nil, nil end
    local life, x, y = decode(last_cell)
    if x == exit_x and y == exit_y then return last_cell, visited end
        
    local available_moves = generate_next_states(last_cell, maze)
    for move, values in pairs(available_moves) do
        move_life, move_x, move_y = decode(move)
        if not visited[move] and move_life > 0 then
            visited[move] = values
            queue:enqueue(move)
        end
    end
    return _bfs()
  end
    
  return gen_path(_bfs())
end


-- Depth-First-Search algorithm
-- input: maze, the encoded initial state, x and y of the exit that we want to reach
-- output: a path table which represents the solution of the maze or nil if there isn't one
-- [PURE]
function dfs(maze, entry_point_encoded, exit_x, exit_y)
  
  local visited = create_hashtable()
  
  --input: encoded initial state, hashtable containing the encoded initial state with move and life_change values
  --output: encoded final state, hashtable of nodes in the path from entry to exit
  --[PURE]
  local function _rec_dfs(node, current_path)
    local life, x, y = decode(node)
    if x == exit_x and y == exit_y then
      return node, current_path end
    
    local available_moves = generate_next_states(node, maze)
    for move, values in pairs(available_moves) do
      move_life, move_x, move_y = decode(move)
      if not visited[move] and move_life > 0 and current_path[move] == nil then
          local new_path = copy_hashtable (current_path)
          new_path[move] = values
          local final, history = _rec_dfs(move, new_path)
          if final and history then return final, history end
      end 
    end
    visited[node] = true
  end

  local current_path = create_hashtable()
  current_path[entry_point_encoded] = {move = "", life_change = 0}
  return gen_path(_rec_dfs(entry_point_encoded, current_path))
end


-- Dijkstra's algorithm
-- input: maze, the encoded initial state, x and y of the exit that we want to reach
-- output: a path table which represents the solution of the maze or nil if there isn't one
-- [PURE]
function dijkstra(maze, entry_point_encoded, exit_x, exit_y)
  local entry_life, entry_x, entry_y = decode(entry_point_encoded)
  local walkable_cells = maze:get_walkable_cells()
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
          distances[i] = math.huge
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

      if cell.x == exit_x and cell.y == exit_y then return gen_path(encode(cell.life, cell.x, cell.y), visited) end
  end
end



--input: function to use to solve the maze
--output: function String -> History that given a file path returns the sequence of moves to solve the maze
--[PURE]
function create_solver(algorithm)
  
  local function run(start, maze) 
    for i,v in ipairs(start.exit_points) do
      local history = algorithm(maze,initial_state(start), v.x, v.y)
      coroutine.yield(history)
    end
  end
  
  local solve = function(maze_filepath) 
                  local history_tables = {}
                  local start, maze = init_game_data(maze_filepath)
                  return find_best_path(fun.totable(fun.take(function(x) return x end, fun.tabulate(coroutine.wrap(function() run(start, maze) end)))), start.initial_life)
                end
          
  return solve
end
