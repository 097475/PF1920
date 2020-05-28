require "input"
require "queue"
require "tbl"
require "stack"

-- input: x and y coordinates of two points
-- output: manhattan distance
function manhattan(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

-- input: maze, entry point encoded, coordinates of exit point
-- output: list of all states
function bfs(maze, entry_point_encoded, exit_y, exit_x)
    local visited = {}
    local paths_queue = Queue:new()
    local directions_queue = Queue:new()
    local path
    local directions_path
    paths_queue:enqueue({entry_point_encoded})
    directions_queue:enqueue({{"",0}})
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
    local visited = {}
    local paths_stack = Stack:Create()
    local directions_stack = Stack:Create()
    local path
    local directions_path
    paths_stack:push({entry_point_encoded})
    directions_stack:push({{"",0}})
    entry_life, entry_x, entry_y = decode(entry_point_encoded)
    table.insert(visited, {entry_y, entry_x})
    while paths_stack:getn() ~= 0 do
        path = paths_stack:pop()
        directions_path = directions_stack:pop()
        local last_cell = path[#path]
        local life, x, y = decode(last_cell)
        
        if x == exit_x and y == exit_y then
          print("ciaooO")
          return path, directions_path end
        local available_moves = move_encode(last_cell, maze)
        
        for move, direction_life_difference in pairs(available_moves) do
            local move_life, move_x, move_y = decode(move)
            print(move_x,move_y)
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
    --  for key,value in pairs(available_moves) do 
    
    --for j, w in ipairs(value) do
      -- print(key,w)
   --end
  --end

 -- entry_life, entry_x, entry_y = decode(entry_point_encoded)

start, maze = init_game_data("mazes/maze_1.txt")
print_table(maze)
path, history = bfs(maze,initial_state(start),4,6)
--path,history=dfs(maze,initial_state(start),4,6)
print(path)
for _, d in pairs(path) do
    print(d)
end

for _, d in ipairs(history) do
  print(d[1] .. ", " .. d[2])
end