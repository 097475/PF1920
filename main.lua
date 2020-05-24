--TODO: usare funtore
-- used to allow printing while the GUI is running
io.stdout:setvbuf("no")
-- used to enable lua 5.3 syntax for unpacking tables
table.unpack = unpack
-- import of input module
require "input"

-- https://sheepolution.com/learn/book/18
-- tilesets: just insert the tileset path
TILESET = "scifitiles-sheet.png"
-- tilesets: just put the corresponding tile number
NOWALL = 21
WALL = 5
PIT = 18
ENTRANCE = 4
EXIT = 59
-- tilesets: size of a single tile
width = 32
height = 32
-- tilesets: rows and columns of the tileset
rows = 5
cols = 13

function draw_arrowhead(x, y, orientation)
  if orientation == "SOUTH" then
    love.graphics.polygon('fill', x + width/2, y + height, x + 10, y + height - 10, x + width - 10, y + height - 10)
  elseif orientation == "NORTH" then
    love.graphics.polygon('fill', x + width/2, y, x + 10, y + 10, x + width - 10, y + 10)
  elseif orientation == "EAST" then
    love.graphics.polygon('fill', x + width, y + height/2, x + width - 10, y + 10, x + width - 10, y + height - 10)
  elseif orientation == "WEST" then
    love.graphics.polygon('fill', x, y + height/2, x + 10, y + 10, x + 10, y + height - 10)
  end
end

function draw_line(x, y, orientation, offset)
  offset = offset or 0
  if orientation == "SOUTH" then
    love.graphics.line(x + width/2, y, x+ width/2, y + height - offset)
  elseif orientation == "NORTH" then
    love.graphics.line(x + width/2, y + offset, x+ width/2, y + height)
  elseif orientation == "EAST" then
    love.graphics.line(x, y + height/2, x+ width - offset, y + height/2)
  elseif orientation == "WEST" then
    love.graphics.line(x + offset, y + height/2, x+ width, y + height/2)
  elseif orientation == "SOUTHEAST" then
    love.graphics.line(x + width/2, y, x+ width/2, y + height/2)
    love.graphics.line(x + width/2 - love.graphics.getLineWidth() / 2, y + height/2, x+ width - offset, y + height/2)
  elseif orientation == "SOUTHWEST" then
    love.graphics.line(x + width/2, y, x+ width/2, y + height/2)
    love.graphics.line(x + width/2 + love.graphics.getLineWidth() / 2, y + height/2, x + offset, y + height/2)
  elseif orientation == "NORTHEAST" then
    love.graphics.line(x + width/2, y + height, x+ width/2, y + height/2) 
    love.graphics.line(x + width/2 - love.graphics.getLineWidth() / 2, y + height/2, x+ width - offset, y + height/2)
  elseif orientation == "NORTHWEST" then
    love.graphics.line(x + width/2, y + height, x+ width/2, y + height/2)
    love.graphics.line(x + width/2 + love.graphics.getLineWidth() / 2, y + height/2, x + offset, y + height/2)
  end 
end


function draw_arrow(x, y, orientation)
  if orientation == "SOUTH" then
    draw_line(x, y, orientation, 10)
    draw_arrowhead(x, y, "SOUTH")
  elseif orientation == "NORTH" then
    draw_line(x, y, orientation, 10)
    draw_arrowhead(x, y, "NORTH")
  elseif orientation == "EAST" or orientation == "SOUTHEAST" or orientation == "NORTHEAST"then
    draw_line(x, y, orientation, 10)
    draw_arrowhead(x, y, "EAST")
  elseif orientation == "WEST" or orientation == "SOUTHWEST" or orientation == "NORTHWEST" then
    draw_line(x, y, orientation, 10)
    draw_arrowhead(x, y, "WEST")
  end  
end


function draw_origin(x, y, orientation, with_arrow)
  love.graphics.circle("fill", x + width/2, y + height/2, 5)
  
  if(with_arrow) then
    offset = 10
    draw_arrowhead(x, y, orientation)
  else
    offset = 0
  end
  
  if orientation == "SOUTH" then
    love.graphics.line(x + width/2, y + height/2, x+ width/2, y + height - offset)
  elseif orientation == "NORTH" then
    love.graphics.line(x + width/2, y + height/2, x+ width/2, y + offset)
  elseif orientation == "EAST" then
    love.graphics.line(x + width/2, y + height/2, x+ width - offset, y + height/2)
  elseif orientation == "WEST" then
    love.graphics.line(x + width/2, y + height/2, x+ offset, y + height/2)
  end  

end


--punta a
function draw_destination(x, y, orientation)
  draw_line(x, y, orientation, width-10)
  if orientation == "SOUTH" then
    love.graphics.polygon('fill', x + width/2, y + height/2, x + 10, y + height/2 - 10, x + width - 10, y + height/2 - 10)
  elseif orientation == "NORTH" then
    love.graphics.polygon('fill', x + width/2, y + height/2, x + 10, y + height/2 + 10, x + width - 10, y + height/2 + 10)
  elseif orientation == "EAST" then
    love.graphics.polygon('fill', x + width/2, y + height/2, x + width/2 - 10, y + 10, x + width/2 - 10, y + height - 10)
  elseif orientation == "WEST" then
    love.graphics.polygon('fill', x + width/2, y + height/2, x + width/2 + 10, y + 10, x + width/2 + 10, y + height - 10)
  end
end


function draw_moves(history, current_move)
  local i = 0
  local current_x, current_y = start.entry_point.x, start.entry_point.y
  while i < current_move do
    i = i + 1
    if i == 1 then
      move = history[i][1]
      delta_x, delta_y = move_vector(move)
      if delta_x == 1 then
        draw_origin(current_x*width, current_y*height, "EAST", false)
      elseif delta_x == -1 then
        draw_origin(current_x*width, current_y*height, "WEST", false)
      elseif delta_y == 1 then
        draw_origin(current_x*width, current_y*height, "SOUTH", false)
      elseif delta_y == -1 then
        draw_origin(current_x*width, current_y*height, "NORTH", false)
      end
      current_x, current_y = current_x + delta_x, current_y + delta_y
      prev_delta_x, prev_delta_y = delta_x, delta_y
    elseif i <= current_move then
      move = history[i][1]
      delta_x, delta_y = move_vector(move)
      if prev_delta_x ~= 0 and delta_x ~= 0 then
        draw_line(current_x*width, current_y*height, "EAST")
      elseif prev_delta_y ~= 0 and delta_y ~= 0 then
        draw_line(current_x*width, current_y*height, "SOUTH")
      elseif (prev_delta_y == 1 and delta_x == -1) or (prev_delta_x == 1 and delta_y == -1) then
        draw_line(current_x*width, current_y*height, "SOUTHWEST")
      elseif (prev_delta_y == 1 and delta_x == 1) or (prev_delta_x == -1 and delta_y == -1) then
        draw_line(current_x*width, current_y*height, "SOUTHEAST")
      elseif (prev_delta_y == -1 and delta_x == -1) or (prev_delta_x == 1 and delta_y == 1) then
        draw_line(current_x*width, current_y*height, "NORTHWEST")
      elseif (prev_delta_y == -1 and delta_x == 1) or (prev_delta_x == -1 and delta_y == 1) then
        draw_line(current_x*width, current_y*height, "NORTHEAST")
      end
      current_x, current_y = current_x + delta_x, current_y + delta_y
      prev_delta_x, prev_delta_y = delta_x, delta_y
    end
    if i == current_move then
      move = history[i][1]
      delta_x, delta_y = move_vector(move)
      if delta_x == 1 then
        draw_destination(current_x*width, current_y*height, "EAST")
      elseif delta_x == -1 then
        draw_destination(current_x*width, current_y*height, "WEST")
      elseif delta_y == 1 then
        draw_destination(current_x*width, current_y*height, "SOUTH")
      elseif delta_y == -1 then
        draw_destination(current_x*width, current_y*height, "NORTH")
      end
    end
  end
end

function generate_tilemap(maze)
  local tilemap = {}
  for i,row in ipairs(maze) do
    table.insert(tilemap, {})
    for j,tile in ipairs(row) do
      if tile == "p" then
        table.insert(tilemap[i], PIT)
      elseif tile == "u" then
        table.insert(tilemap[i], EXIT)
      elseif tile == "i" then
        table.insert(tilemap[i], ENTRANCE)
      elseif tile ~= "m" then
        table.insert(tilemap[i], NOWALL)
      else
        table.insert(tilemap[i], WALL)
      end
    end
  end

  return tilemap
  
end

function reset_vitality() 
  life = start.vitality
  index = 0
end

function game_load()
    current_move = 0
    index = 0

    start, maze = init_game_data(filepath)
    life = start.vitality
    ------------------------------------------------- call the rest of the program here, the program should return the path in this format
    history = {{"U", 2},{"R", 1},{"U", 3},{"R", 0},{"R", -4},{"R", 1},{"D", 0}}
    -------------------------------------------------
    
    image = love.graphics.newImage(TILESET)
    local image_width = image:getWidth()
    local image_height = image:getHeight()

    quads = {}
    for i=0, rows do
      for j=0, cols do
        table.insert(quads, love.graphics.newQuad(j * width, i * height, width, height, image_width, image_height))
      end
    end
    
  tilemap = generate_tilemap(maze)
end

function love.load()
  gamestate = "menu"
  filepath = "mazes/maze_1.txt"
  love.graphics.setLineWidth(5)
  love.graphics.setLineStyle("rough")
  love.window.maximize()
end

function menu_update() end

function game_update() 
  while index < current_move do
    index = index + 1
    life = life + history[index][2]
  end
end


function love.update(dt)
  if gamestate == "menu" then
    menu_update()
  elseif gamestate == "game" then
    game_update()
  end
end

function menu_draw() 
  love.graphics.setFont(love.graphics.newFont(48))
  love.graphics.print("Insert the path of the maze to solve:", 40, 20)
  love.graphics.rectangle("fill", 40, 120 , love.graphics.getWidth() - 80, 90)
  love.graphics.setFont(love.graphics.newFont(72))
  love.graphics.setColor(0,0,0,1)
  love.graphics.print(filepath, 50, 120)
  love.graphics.setColor(1,1,1,1)
  love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 150, 250, 300,100, 10,10)
  love.graphics.setFont(love.graphics.newFont(48))
  love.graphics.setColor(0,0,0,1)
  love.graphics.print("CONFIRM", love.graphics.getWidth()/2 - 115, 250 + 25)
  love.graphics.setColor(1,1,1,1)
end

function game_draw() 
  love.graphics.setFont(love.graphics.newFont(12))
  love.graphics.print("Life: " .. life, width, height/2)
  
  love.graphics.print("Keys: [SPACE] -> Execute one step \t [ENTER] -> Execute full path \t [BACKSPACE] -> Backtrack one step \t [DELETE] -> Backtrack all steps \t [ESCAPE] Go back to maze input", width*3, height/2)
  
  for i,row in ipairs(tilemap) do
    for j,tile in ipairs(row) do
      --Draw the image with the correct quad
      love.graphics.draw(image, quads[tile], j * width, i * height)
      if type(maze[i][j]) == "number" or maze[i][j] == "f" then
          love.graphics.setColor(0,0,0,1)
          love.graphics.print(maze[i][j], j * width, i * height)
          love.graphics.setColor(1,1,1,1)
      end
    end
  end
  
  draw_moves(history, current_move)
end

function love.draw()
  
  if gamestate == "menu" then
    menu_draw()
  elseif gamestate == "game" then
    game_draw()
  end
  
end


function love.keypressed(key, scancode, isrepeat)
   if gamestate == "game" then
     if key == "space" and current_move < #history then
        current_move = current_move + 1
      elseif key == "return" then
        current_move = #history
      elseif key == "backspace" then
        current_move = current_move - 1
        reset_vitality()
      elseif key == "delete" then
        current_move = 0
        reset_vitality()
      elseif key == "escape" then
        gamestate = "menu"
     end
    elseif gamestate == "menu" then
      if key == "backspace" then
        filepath = string.sub(filepath, 1, #filepath - 1)
      end
    end
end

function love.textinput(text)
  filepath = filepath .. text
end

function love.mousepressed(x, y, button, istouch, presses)
  if gamestate == "menu" and x > love.graphics.getWidth()/2 - 150 and x < x + 300 and y > 250 and y < 250 + 100  then
    game_load()
    gamestate = "game"
  end
end
