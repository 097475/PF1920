require "input-output"
require "maze"
require "maze_functions"
require "queue"
require "tbl"
require "stack"
require "priority_queue"

-- input: x and y coordinates of two points
-- output: manhattan distance
function manhattan(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
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
    directions_queue:enqueue({{move="_", life_change=0}})
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


-- DFS 
function dfs(maze, entry_point_encoded, exit_y,exit_x)
    maze = maze:get_maze()
    local visited = {}
    local paths_stack = Stack:Create()
    local directions_stack = Stack:Create()
    local path
    local directions_path
    paths_stack:push({entry_point_encoded})
    directions_stack:push({{move="_", life_change=0}})
    entry_life, entry_x, entry_y = decode(entry_point_encoded)
    table.insert(visited, {entry_y, entry_x})
    while paths_stack:getn() ~= 0 do
        path = paths_stack:pop()
        directions_path = directions_stack:pop()
        local last_cell = path[#path]
        local life, x, y = decode(last_cell)
        
        if x == exit_x and y == exit_y then
          return path, directions_path end
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
            cells[i].direction_life_difference = {"",0}
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
            reversed_path = {}
            reversed_history = {}
            local current_cell = visited[#visited]
            local previous = current_cell[3]
            while previous ~= nil do
                table.insert(reversed_path, current_cell[1])
                table.insert(reversed_history, current_cell[2])
                for _,k in pairs(visited) do
                    if previous == k[1] then
                        current_cell = k
                        previous = k[3]
                    end
                end
            end
            table.insert(reversed_path, visited[1][1])
            table.insert(reversed_history, visited[1][2])
            local sorted_path = {}
            local sorted_history = {}
            for i = #reversed_path,1,-1 do
                table.insert(sorted_path, reversed_path[i])
                table.insert(sorted_history, reversed_history[i])
            end
            return sorted_path, sorted_history
        end
    end
end


function create_solver(algorithm)
  solve = function(maze_filepath) 
            local start, maze = init_game_data(maze_filepath)
            local history_tables = {}
            for i,v in ipairs(start.exit_points) do
              local path, history = algorithm(maze,initial_state(start),v.y,v.x)  --should only return the total hash table and final state
              -- history = gen_path(final_state, visited)
              table.insert(history_tables, history)
            end
            -- <-- here, select the best history in history_tables, for now we select the first-->
            return history_tables[1] -- return the path
          end
  return solve
end

--local start, maze = init_game_data("mazes/maze_1.txt")
--local path, history = bfs(maze:get_maze(),initial_state(start),2,10)
--local path, history = dfs(maze:get_maze(),initial_state(start),4,6)
--local path, _history = dijkstra(maze,initial_state(start),4,6)

--for _, d in pairs(path) do
--  print(d)
--end

--for _, d in pairs(_history) do
--  print(d.move, d.life_change)
--end

--print("---")

--local best_history = create_solver(dfs)("mazes/maze_1.txt")
--for _, d in pairs(best_history) do
--  print(d.move, d.life_change)
--end
