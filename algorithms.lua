require "input"
require "queue"
require "tbl"

-- input: x and y coordinates of two points
-- output: manhattan distance
function manhattan(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

function bfs(maze, entry_point_encoded, exit_y, exit_x)
    local visited = {}
    local q = Queue:new()
    local path
    q:enqueue({entry_point_encoded})
    entry_life, entry_x, entry_y = decode(entry_point_encoded)
    table.insert(visited, {entry_y, entry_x})
    while not q:isEmpty() do
        path = q:dequeue()
        local last_cell = path[#path]
        local life, x, y = decode(last_cell)
        if x == exit_x and y == exit_y then return path end
        
        local available_moves = move_encode(last_cell, maze)
        for move, direction_life_difference in pairs(available_moves) do
            move_life, move_x, move_y = decode(move)
            if (not table.contains(visited, {move_y, move_x})) and move_life > 0 then
                table.insert(visited, {move_y, move_x})
                local new_path = table.copy(path)
                table.insert(new_path, move)
                q:enqueue(new_path)
            end
        end
    end
    return false
end

start, maze = init_game_data("mazes/maze_1.txt")
q = bfs(maze,initial_state(start),4,6)

for _, v in ipairs(q) do
    print(v)
end