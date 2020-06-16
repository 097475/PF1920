-- used to allow printing while the GUI is running
io.stdout:setvbuf("no")
-- used to enable lua 5.3 syntax for unpacking tables
table.unpack = unpack
-- import of input module
require "input-output"
-- import of algorithms module
require "algorithms"
-- import of monad module
require "monad"
-- import of Slab library
local Slab = require 'lib/Slab'

-- tilesets: size of a single tile
local width = 32
local height = 32

-- tilesets: just insert the tileset path
local TILES = "graphics/maze_tileset.png"
-- tilesets: just put the corresponding tile number
local NOWALL = 1
local WALL = 2
local PIT = 7
local ENTRANCE = 5
local EXIT = 6

-- tilesets: rows and columns of the tileset
local maze_rows = 2
local maze_cols = 3

-- tilesets: just insert the tileset path
local ARROWS = "graphics/arrow_tileset.png"
-- tilesets: just put the corresponding tile number
local ORIGIN_NORTH = 1
local ORIGIN_SOUTH = 2
local ORIGIN_WEST = 3
local ORIGIN_EAST = 4
local LINE_VERTICAL = 5
local LINE_HORIZONTAL = 6
local LINE_NORTH_EAST = 7
local LINE_SOUTH_WEST = 9
local LINE_NORTH_WEST = 10
local LINE_SOUTH_EAST = 11
local ARROW_NORTH = 12
local ARROW_EAST = 13
local ARROW_SOUTH = 14
local ARROW_WEST = 15
-- tilesets: rows and columns of the tileset
local arrow_rows = 2
local arrow_cols = 7

-- global variables
local start
local index
local life
local current_move
local history 
local maze
local open_no_solution_dialog
local open_dialog
local save_dialog
local filepath
local maze_tiles
local maze_quads
local arrow_tiles
local arrow_quads
local algorithm_label

-- input: x coordinate, y coordinate and orientation from  "SOUTH", "EAST",  "SOUTHEAST",  "SOUTHWEST", "NORTHEAST", "NORTHWEST"
-- output: none, draws a line at x,y with the specified orientation, using the arrow_tileset
function draw_line(x, y, orientation)
  Slab.SetCursorPos(x-1, y + 24)  
  if orientation == "SOUTH" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[LINE_VERTICAL].x, SubY = arrow_quads[LINE_VERTICAL].y, SubW = arrow_quads[LINE_VERTICAL].w, SubH = arrow_quads[LINE_VERTICAL].h})
  elseif orientation == "EAST" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[LINE_HORIZONTAL].x, SubY = arrow_quads[LINE_HORIZONTAL].y, SubW = arrow_quads[LINE_HORIZONTAL].w, SubH = arrow_quads[LINE_HORIZONTAL].h})
  elseif orientation == "SOUTHEAST" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[LINE_SOUTH_EAST].x, SubY = arrow_quads[LINE_SOUTH_EAST].y, SubW = arrow_quads[LINE_SOUTH_EAST].w, SubH = arrow_quads[LINE_SOUTH_EAST].h})
  elseif orientation == "SOUTHWEST" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[LINE_SOUTH_WEST].x, SubY = arrow_quads[LINE_SOUTH_WEST].y, SubW = arrow_quads[LINE_SOUTH_WEST].w, SubH = arrow_quads[LINE_SOUTH_WEST].h})
  elseif orientation == "NORTHEAST" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[LINE_NORTH_EAST].x, SubY = arrow_quads[LINE_NORTH_EAST].y, SubW = arrow_quads[LINE_NORTH_EAST].w, SubH = arrow_quads[LINE_NORTH_EAST].h})
  elseif orientation == "NORTHWEST" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[LINE_NORTH_WEST].x, SubY = arrow_quads[LINE_NORTH_WEST].y, SubW = arrow_quads[LINE_NORTH_WEST].w, SubH = arrow_quads[LINE_NORTH_WEST].h})
  end 
end

-- input: x coordinate, y coordinate and orientation from "EAST", "NORTH", "SOUTH", "WEST"
-- output: none, draws the path origin with the specified orientation, using the arrow_tileset
function draw_origin(x, y, orientation)
  Slab.SetCursorPos(x-1, y + 24)  
  if orientation == "SOUTH" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[ORIGIN_SOUTH].x, SubY = arrow_quads[ORIGIN_SOUTH].y, SubW = arrow_quads[ORIGIN_SOUTH].w, SubH = arrow_quads[ORIGIN_SOUTH].h})
  elseif orientation == "NORTH" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[ORIGIN_NORTH].x, SubY = arrow_quads[ORIGIN_NORTH].y, SubW = arrow_quads[ORIGIN_NORTH].w, SubH = arrow_quads[ORIGIN_NORTH].h})
  elseif orientation == "EAST" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[ORIGIN_EAST].x, SubY = arrow_quads[ORIGIN_EAST].y, SubW = arrow_quads[ORIGIN_EAST].w, SubH = arrow_quads[ORIGIN_EAST].h})
  elseif orientation == "WEST" then
    Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[ORIGIN_WEST].x, SubY = arrow_quads[ORIGIN_WEST].y, SubW = arrow_quads[ORIGIN_WEST].w, SubH = arrow_quads[ORIGIN_WEST].h})
  end  
end

-- input: x coordinate, y coordinate and orientation from "EAST", "NORTH", "SOUTH", "WEST"
-- output: none, draws the last step in the drawn path (the arrow) with the specified orientation, from the arrow_tileset
function draw_destination(x, y, orientation)
  Slab.SetCursorPos(x-1, y + 24)  
  if orientation == "SOUTH" then
  Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[ARROW_SOUTH].x, SubY = arrow_quads[ARROW_SOUTH].y, SubW = arrow_quads[ARROW_SOUTH].w, SubH = arrow_quads[ARROW_SOUTH].h})
  elseif orientation == "NORTH" then
  Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[ARROW_NORTH].x, SubY = arrow_quads[ARROW_NORTH].y, SubW = arrow_quads[ARROW_NORTH].w, SubH = arrow_quads[ARROW_NORTH].h})
  elseif orientation == "EAST" then
  Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[ARROW_EAST].x, SubY = arrow_quads[ARROW_EAST].y, SubW = arrow_quads[ARROW_EAST].w, SubH = arrow_quads[ARROW_EAST].h})
  elseif orientation == "WEST" then
  Slab.Image('Path', { Image = arrow_tiles , SubX = arrow_quads[ARROW_WEST].x, SubY = arrow_quads[ARROW_WEST].y, SubW = arrow_quads[ARROW_WEST].w, SubH = arrow_quads[ARROW_WEST].h})
  end
end

--input: history table with moves to be drawn, index of the last move to draw e.g. ({{move="D", life_change=1}, {move="R", life_change=-2}, {move="R", life_change=3}}, 2) will draw the first two moves in the table
--output: none, draws the path represented by history up to current_move
function draw_moves(history, current_move)
  local i = 0
  local current_x, current_y = start.entry_point.x, start.entry_point.y
  while i < current_move do
    i = i + 1
    if i == 1 then
      local move = history[i].move
      local delta_x, delta_y = move_vector(move)
      if delta_x == 1 then
        draw_origin((current_x - 1)*width, current_y*height, "EAST")
      elseif delta_x == -1 then
        draw_origin((current_x - 1)*width, current_y*height, "WEST")
      elseif delta_y == 1 then
        draw_origin((current_x - 1)*width, current_y*height, "SOUTH")
      elseif delta_y == -1 then
        draw_origin((current_x - 1)*width, current_y*height, "NORTH")
      end
      current_x, current_y = current_x + delta_x, current_y + delta_y
      prev_delta_x, prev_delta_y = delta_x, delta_y
    elseif i <= current_move then
      local move = history[i].move
      local delta_x, delta_y = move_vector(move)
      if prev_delta_x ~= 0 and delta_x ~= 0 then
        draw_line((current_x - 1)*width, current_y*height, "EAST")
      elseif prev_delta_y ~= 0 and delta_y ~= 0 then
        draw_line((current_x - 1)*width, current_y*height, "SOUTH")
      elseif (prev_delta_y == 1 and delta_x == -1) or (prev_delta_x == 1 and delta_y == -1) then
        draw_line((current_x - 1)*width, current_y*height, "SOUTHWEST")
      elseif (prev_delta_y == 1 and delta_x == 1) or (prev_delta_x == -1 and delta_y == -1) then
        draw_line((current_x - 1)*width, current_y*height, "SOUTHEAST")
      elseif (prev_delta_y == -1 and delta_x == -1) or (prev_delta_x == 1 and delta_y == 1) then
        draw_line((current_x - 1)*width, current_y*height, "NORTHWEST")
      elseif (prev_delta_y == -1 and delta_x == 1) or (prev_delta_x == -1 and delta_y == 1) then
        draw_line((current_x - 1)*width, current_y*height, "NORTHEAST")
      end
      current_x, current_y = current_x + delta_x, current_y + delta_y
      prev_delta_x, prev_delta_y = delta_x, delta_y
    end
    if i == current_move then
      local move = history[i].move
      local delta_x, delta_y = move_vector(move)
      if delta_x == 1 then
        draw_destination((current_x - 1)*width, current_y*height, "EAST")
      elseif delta_x == -1 then
        draw_destination((current_x - 1)*width, current_y*height, "WEST")
      elseif delta_y == 1 then
        draw_destination((current_x - 1)*width, current_y*height, "SOUTH")
      elseif delta_y == -1 then
        draw_destination((current_x - 1)*width, current_y*height, "NORTH")
      end
    end
  end
end

--input: maze table
--output: transformed copy of input table where each element is replaced by its corresponding tile number
--[PURE]
function generate_tilemap(maze)
  --input: single element of the maze matrix e.g. "p", 1, "u", 9, etc.
  --output: corresponding tile number e.g. 7, 1, 6, 1, etc.
  --[PURE]
  function mapper (element)
    if element == "p" then
      return PIT
    elseif element == "u" then
      return EXIT
    elseif element == "i" then
      return ENTRANCE
    elseif element ~= "m" then
      return NOWALL
    else
      return WALL
    end
  end
  return maze(mapper)
end


--input: none
--output: none, resets life to initial life, index is reset to 0 to restart the life calculation from start
function reset_vitality() 
  life = start.initial_life
  index = 0
end

--input: none
--output: none, resets life and also resets the history and the current move
function total_reset()
  reset_vitality()
  history = nil
  current_move = 0
end



--input: none
--output: none, loads indexes and values when a new maze is selected
function game_load()
  start, maze = init_game_data(filepath)
  tilemap = generate_tilemap(maze):get_maze()
  total_reset()
end

--input: function String -> History that given a file path returns the sequence of moves to solve the maze
--output: none, runs the solving algorithm, opens a dialog if no solution is found
function run_algorithm(selected_algorithm)
    total_reset()
    local monad = Maybe(filepath):bind(function(path) return Maybe(create_solver(selected_algorithm)(path)) end):bind(function(value) history = value return Maybe(true) end )
    if monad.is_null then open_no_solution_dialog = true end
end

--input: args (not used)
--output:none, love specific function: called only once at start of the program
--loads indexes and values that are global for the program, loads up graphics, sets window size
function love.load(args)
  filepath = nil
  maze_tiles = love.graphics.newImage(TILES)
  arrow_tiles = love.graphics.newImage(ARROWS)
  maze_quads = {}
  for i=0, maze_rows do
    for j=0, maze_cols do
      table.insert(maze_quads, {x = j * width, y = i * height, w = width, h = height})
    end
  end
  arrow_quads = {}
  for i=0, arrow_rows do
    for j=0, arrow_cols do
      table.insert(arrow_quads, {x = j * width, y = i * height, w = width, h = height})
    end
  end
  love.window.setTitle("Maze solver")
  love.window.setMode(1000, 500, {resizable=true, vsync = 0})
  love.graphics.setBackgroundColor(0.4, 0.88, 1.0)
  Slab.Initialize(args)
end

--input: none
--output: none, updates the life value to the current step of the path
function game_update() 
  while index < current_move and history do
    index = index + 1
    life = life + history[index].life_change
  end
end

--input: none
--output: none, function that draws the actual window contents: the maze and the path, labels, life
function game_draw() 
  if algorithm_label then Slab.Text("Solver : " .. algorithm_label.. "\t") Slab.SameLine() end
  Slab.Text("Life: " .. life)
  if history then
      Slab.SameLine()
      Slab.Text("\tSteps: " .. current_move)
  end
  Slab.Separator()
  Slab.Text("Keys: [SPACE] -> Execute one step \t [ENTER] -> Execute full path \t [BACKSPACE] -> Backtrack one step \t [DELETE] -> Backtrack all steps")
  Slab.Separator()
  for i,row in ipairs(tilemap) do
    for j,tile in ipairs(row) do
      Slab.Image('Tiles', { Image = maze_tiles , SubX = maze_quads[tile].x, SubY = maze_quads[tile].y, SubW = maze_quads[tile].w, SubH = maze_quads[tile].h})
      Slab.SameLine()
      x,y = Slab.GetCursorPos()
      Slab.SetCursorPos(x-4, y)
      if type(maze:get_maze()[i][j]) == "number" or maze:get_maze()[i][j] == "f" then
          x,y = Slab.GetCursorPos()
          Slab.SetCursorPos(x-31, y)
          Slab.Text(maze:get_maze()[i][j], {Color = {0,0,0}})
          Slab.SameLine()
          Slab.SetCursorPos(x, y)
      end
    end
    x,y = Slab.GetCursorPos()
    Slab.SetCursorPos(0, y + 32)
  end
  if history then
    draw_moves(history, current_move)
  end
end

--input: none
--output: none, creates the menu bar and manages the various dialogs
function create_menu()
  if Slab.BeginMainMenuBar() then
    if Slab.BeginMenu("File") then
        if Slab.MenuItem("Open") then
          open_dialog = true
        end
        if Slab.MenuItem("Save") then
          save_dialog = true
        end
        Slab.Separator()
        if Slab.MenuItem("Quit") then
            love.event.quit()
        end
        Slab.EndMenu()
    end
    if Slab.BeginMenu("Solve") then
      if Slab.MenuItem("Depth-First Search")  and maze then
        algorithm_label = "Depth-First Search"
        run_algorithm(dfs)
      end
      if Slab.MenuItem("Breadth-First Search") and maze then
        algorithm_label = "Breadth-First Search"
        run_algorithm(bfs)
      end  
      if Slab.MenuItem("Find-All-Paths") and maze then
        algorithm_label = "Find-All-Shortest-Paths"
        run_algorithm(find_all_shortest_paths)
      end  
      if Slab.MenuItem("Bruteforce") and maze then
        algorithm_label = "Bruteforce"
        run_algorithm(bruteforce)
      end
      if Slab.MenuItem("A* Search") and maze then
        algorithm_label = "A* Search"
        run_algorithm(astar)
      end
      if Slab.MenuItem("Dijkstra's Algorithm") and maze then
        algorithm_label = "Dijkstra's Algorithm"
        run_algorithm(dijkstra)
      end
      Slab.EndMenu()
    end
    Slab.EndMenu()
  end
  
  if open_dialog then
    local result = Slab.FileDialog({AllowMultiSelect = false, Type = 'openfile'})
    if result.Button ~= "" then
      open_dialog = false
      if result.Button == "OK" then
				filepath = result.Files[1]
        algorithm_label = nil
        game_load()
			end
    end
  end
  
  if save_dialog then
    if maze then
      local result = Slab.FileDialog({AllowMultiSelect = false, Type = 'savefile'})
      if result.Button ~= "" then
        save_dialog = false
        if result.Button == "OK" then
          filepath = result.Files[1]
          Write(write_maze(start, maze, history)):bind(function(data) write_to_file(filepath, data) return Write(true) end)
        end
      end
    else 
      save_dialog = false
    end
  end
  
  if open_no_solution_dialog then
    local result = Slab.MessageBox("Warning", "The maze has no solution!")
    if result == "OK" then
      open_no_solution_dialog = false
    end
  end
end


--input: time passed since last function call
-- output: none, love specific function: called in loop before love.draw
-- the function sets up windows and images to be drawn by the Slab library, and also updates vitality and reads key presses
function love.update(dt)
  Slab.Update(dt)
  create_menu()
	Slab.BeginWindow('MainWindow', {Title = nil, AutoSizeWindow = false, W = love.graphics.getWidth( ) + 1, H = love.graphics.getHeight()-20, X = -2, Y = 17, NoSavedSettings = true, AllowMove = false})
  if history then
    user_input()
  end
  if filepath then
    game_update()
    game_draw()
  end
	Slab.EndWindow()
end


--input: none
--output: none, love specific function: called in loop after love.update
--the function calls Slab to draw the windows set up in love.update
function love.draw()
  Slab.Draw()  
end

--input: none
--output: none, function to parse user key presses
function user_input()
     if Slab.IsKeyPressed("space") and current_move < #history then
        current_move = current_move + 1
      elseif Slab.IsKeyPressed("return") then
        current_move = #history
      elseif Slab.IsKeyPressed("backspace") and current_move > 0 then
        current_move = current_move - 1
        reset_vitality()
      elseif Slab.IsKeyPressed("delete") then
        current_move = 0
        reset_vitality()
     end
end