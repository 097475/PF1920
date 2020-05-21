-- input: maze and encoded state
-- output: table of possible moves
function get_available_moves(maze, state)
    local life, x, y = decode(state)
    local moves = {"D", "U", "L", "R"}
    for k, move in pairs(moves) do 
        local delta_x, delta_y = move_vector(move)
    end
end

get_available_moves("[5|5|5]")