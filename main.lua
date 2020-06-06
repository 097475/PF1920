-- used to allow printing while the GUI is running
io.stdout:setvbuf("no")
-- used to enable lua 5.3 syntax for unpacking tables
table.unpack = unpack
-- import of input module
require "input-output"
-- import of algorithms module
require "algorithms"
-- import of Slab library
local Slab = require 'Slab'

-- tilesets: size of a single tile
width = 32
height = 32

-- tilesets: just insert the tileset path
TILES = "scifitiles-sheet.png"
-- tilesets: just put the corresponding tile number
NOWALL = 21
WALL = 5
PIT = 18
ENTRANCE = 4
EXIT = 59
-- tilesets: rows and columns of the tileset
tiles_rows = 5
tiles_cols = 13

-- tilesets: just insert the tileset path
ARROWS = "arrow_tileset.png"
-- tilesets: just put the corresponding tile number
ORIGIN_NORTH = 1
ORIGIN_SOUTH = 2
ORIGIN_WEST = 3
ORIGIN_EAST = 4
LINE_VERTICAL = 5
LINE_HORIZONTAL = 6
LINE_NORTH_EAST = 7
LINE_SOUTH_WEST = 9
LINE_NORTH_WEST = 10
LINE_SOUTH_EAST = 11
ARROW_NORTH = 12
ARROW_EAST = 13
ARROW_SOUTH = 14
ARROW_WEST = 15
-- tilesets: rows and columns of the tileset
arrow_rows = 2
arrow_cols = 7


-- draws a line at x,y with the specified orientation, using the arrow_tileset [PURE]
function draw_line(x, y, orientation)
  Slab.SetCursorPos(x, y + 8)  
  if orientation == "SOUTH" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[LINE_VERTICAL].x, SubY = arrow_quads[LINE_VERTICAL].y, SubW = arrow_quads[LINE_VERTICAL].w, SubH = arrow_quads[LINE_VERTICAL].h})
  elseif orientation == "EAST" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[LINE_HORIZONTAL].x, SubY = arrow_quads[LINE_HORIZONTAL].y, SubW = arrow_quads[LINE_HORIZONTAL].w, SubH = arrow_quads[LINE_HORIZONTAL].h})
  elseif orientation == "SOUTHEAST" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[LINE_SOUTH_EAST].x, SubY = arrow_quads[LINE_SOUTH_EAST].y, SubW = arrow_quads[LINE_SOUTH_EAST].w, SubH = arrow_quads[LINE_SOUTH_EAST].h})
  elseif orientation == "SOUTHWEST" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[LINE_SOUTH_WEST].x, SubY = arrow_quads[LINE_SOUTH_WEST].y, SubW = arrow_quads[LINE_SOUTH_WEST].w, SubH = arrow_quads[LINE_SOUTH_WEST].h})
  elseif orientation == "NORTHEAST" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[LINE_NORTH_EAST].x, SubY = arrow_quads[LINE_NORTH_EAST].y, SubW = arrow_quads[LINE_NORTH_EAST].w, SubH = arrow_quads[LINE_NORTH_EAST].h})
  elseif orientation == "NORTHWEST" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[LINE_NORTH_WEST].x, SubY = arrow_quads[LINE_NORTH_WEST].y, SubW = arrow_quads[LINE_NORTH_WEST].w, SubH = arrow_quads[LINE_NORTH_WEST].h})
  end 
end

-- draws the path origin with the specified orientation, using the arrow_tileset [PURE]
function draw_origin(x, y, orientation)
  Slab.SetCursorPos(x, y + 8)  
  if orientation == "SOUTH" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[ORIGIN_SOUTH].x, SubY = arrow_quads[ORIGIN_SOUTH].y, SubW = arrow_quads[ORIGIN_SOUTH].w, SubH = arrow_quads[ORIGIN_SOUTH].h})
  elseif orientation == "NORTH" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[ORIGIN_NORTH].x, SubY = arrow_quads[ORIGIN_NORTH].y, SubW = arrow_quads[ORIGIN_NORTH].w, SubH = arrow_quads[ORIGIN_NORTH].h})
  elseif orientation == "EAST" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[ORIGIN_EAST].x, SubY = arrow_quads[ORIGIN_EAST].y, SubW = arrow_quads[ORIGIN_EAST].w, SubH = arrow_quads[ORIGIN_EAST].h})
  elseif orientation == "WEST" then
    Slab.Image('Path', { Image = arrow , SubX = arrow_quads[ORIGIN_WEST].x, SubY = arrow_quads[ORIGIN_WEST].y, SubW = arrow_quads[ORIGIN_WEST].w, SubH = arrow_quads[ORIGIN_WEST].h})
  end  
end


-- draws the last step in the drawn path (the arrow) with the specified orientation, from the arrow_tileset [PURE]
function draw_destination(x, y, orientation)
  Slab.SetCursorPos(x, y + 8)  
  if orientation == "SOUTH" then
  Slab.Image('Path', { Image = arrow , SubX = arrow_quads[ARROW_SOUTH].x, SubY = arrow_quads[ARROW_SOUTH].y, SubW = arrow_quads[ARROW_SOUTH].w, SubH = arrow_quads[ARROW_SOUTH].h})
  elseif orientation == "NORTH" then
  Slab.Image('Path', { Image = arrow , SubX = arrow_quads[ARROW_NORTH].x, SubY = arrow_quads[ARROW_NORTH].y, SubW = arrow_quads[ARROW_NORTH].w, SubH = arrow_quads[ARROW_NORTH].h})
  elseif orientation == "EAST" then
  Slab.Image('Path', { Image = arrow , SubX = arrow_quads[ARROW_EAST].x, SubY = arrow_quads[ARROW_EAST].y, SubW = arrow_quads[ARROW_EAST].w, SubH = arrow_quads[ARROW_EAST].h})
  elseif orientation == "NORTH" then
  Slab.Image('Path', { Image = arrow , SubX = arrow_quads[ARROW_WEST].x, SubY = arrow_quads[ARROW_WEST].y, SubW = arrow_quads[ARROW_WEST].w, SubH = arrow_quads[ARROW_WEST].h})
  end
end

-- Draws the path represented by history up to current_move
function draw_moves(history, current_move)
  local i = 0
  local current_x, current_y = start.entry_point.x, start.entry_point.y
  while i < current_move do
    i = i + 1
    if i == 1 then
      move = history[i].move
      delta_x, delta_y = move_vector(move)
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
      move = history[i].move
      delta_x, delta_y = move_vector(move)
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
      move = history[i].move
      delta_x, delta_y = move_vector(move)
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


-- Converts a maze to a matrix of tile numbers, using the maze as functor [PURE]
function generate_tilemap(maze)
  -- Function that maps each element of the maze to the corresponding tile number [PURE]
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


-- resets life to initial life, index is reset to 0 to restart the life calculation from start
function reset_vitality() 
  life = start.vitality
  index = 0
end


-- loads indexes and values when a new maze is selected
-- program entry point is here
function game_load()
  current_move = 0
  index = 0
  start, maze = init_game_data(filepath)
  life = start.vitality
  tilemap = generate_tilemap(maze):get_maze()
end

function run_algorithm(selected_algorithm)
    history = nil
    current_move = 0
    index = 0
    life = start.vitality
    history = create_solver(selected_algorithm)(filepath)
    if selected_algorithm ~= astar and selected_algorithm ~= dijkstra and selected_algorithm ~= dfs and selected_algorithm ~= find_all_paths and selected_algorithm ~= rec_dfs then
      table.remove(history, 1)
    end
end


-- love specific function: called only once at start of the program
-- loads indexes and values that are global for the program, loads up graphics, sets window size
function love.load(args)
  filepath = ""
  image = love.graphics.newImage(TILES)
  arrow = love.graphics.newImage(ARROWS)
  local image_width = image:getWidth()
  local image_height = image:getHeight()
  tile_quads = {}
  for i=0, tiles_rows do
    for j=0, tiles_cols do
      table.insert(tile_quads, {x = j * width, y = i * height, w = width, h = height})
    end
  end
  arrow_quads = {}
  for i=0, arrow_rows do
    for j=0, arrow_cols do
      table.insert(arrow_quads, {x = j * width, y = i * height, w = width, h = height})
    end
  end
  love.window.setTitle("Maze solver")
  love.window.setMode(1000, 500, {resizable=true})
  love.graphics.setBackgroundColor(0.4, 0.88, 1.0)
  Slab.Initialize(args)
end


-- updates the life value
function game_update() 
  while index < current_move and history do
    index = index + 1
    life = life + history[index].life_change
  end
end

-- function that draws the actual window contents: the maze and the path
function game_draw() 
  if algorithm_label then Slab.Text("Solver : " .. algorithm_label.. "\t") Slab.SameLine() end
  Slab.Text("Life: " .. life)
  if history then
      Slab.SameLine()
      Slab.Text("\tSteps: " .. current_move)
  end
  Slab.Text("Keys: [SPACE] -> Execute one step \t [ENTER] -> Execute full path \t [BACKSPACE] -> Backtrack one step \t [DELETE] -> Backtrack all steps")
  
  for i,row in ipairs(tilemap) do
    for j,tile in ipairs(row) do
      --Draw the image with the correct quad
      Slab.Image('Tiles', { Image = image , SubX = tile_quads[tile].x, SubY = tile_quads[tile].y, SubW = tile_quads[tile].w, SubH = tile_quads[tile].h})
      Slab.SameLine()
      x,y = Slab.GetCursorPos()
      Slab.SetCursorPos(x-4, y)
      if type(maze:get_maze()[i][j]) == "number" or maze:get_maze()[i][j] == "f" then
          x,y = Slab.GetCursorPos()
          Slab.SetCursorPos(x-32, y)
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

-- menu bar creation
function create_menu()
  if Slab.BeginMainMenuBar() then
    if Slab.BeginMenu("File") then
        if Slab.MenuItem("Open") then
          openDialog = true
        end
        if Slab.MenuItem("Save") then
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
        --run_algorithm(dfs)
        run_algorithm(rec_dfs)
      end
      if Slab.MenuItem("Breadth-First Search") and maze then
        algorithm_label = "Breadth-First Search"
        run_algorithm(bfs)
      end  
      if Slab.MenuItem("Find-All-Paths") and maze then
        algorithm_label = "Find-All-Paths"
        run_algorithm(find_all_paths)
      end  
      if Slab.MenuItem("Best-First Search") and maze then
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
  
  if openDialog then
    local Result = Slab.FileDialog({AllowMultiSelect = false, Type = 'openfile'})
    if Result.Button ~= "" then
      openDialog = false
      if Result.Button == "OK" then
				filepath = Result.Files[1]
        game_load()
			end
    end
  end
end


-- love specific function: called in loop before love.draw
-- the function sets up windows and images to be drawn by the Slab library, and also updates vitality
function love.update(dt)
  Slab.Update(dt)
  create_menu()
	Slab.BeginWindow('MainWindow', {Title = nil, AutoSizeWindow = false, W = love.graphics.getWidth( ) + 1, H = love.graphics.getHeight()-20, X = -2, Y = 17, NoSavedSettings = true, AllowMove = false})
  if history then
    user_input()
  end
  if filepath ~= "" then
    game_update()
    game_draw()
  end
	Slab.EndWindow()
end


-- love specific function: called in loop after love.update
-- the function calls Slab to draw the windows set up in love.update
-- [PURE]
function love.draw()
  Slab.Draw()  
end

-- function to parse user key presses
-- takes input from outside
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