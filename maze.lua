require "input-output"

Maze = {}

function Maze:new()
    local object = {}

    object.rows = {}

    self.__index = self
    return setmetatable(object, self)
end

--input: function to apply to Maze functor e.g. function(x) return x + 1 end
--output: new Maze functor with function f applied to its elements
function Maze:__call(f)
  local maze = Maze:new()
  for i, row in ipairs(self.rows) do
    table.insert(maze.rows, {})
    for j, elem in ipairs(row) do
      table.insert(maze.rows[i], f(elem))
    end
  end
  return maze
end

--input
function Maze:initialize(lines_table)
    for i=1,#lines_table-1 do
        row = {}
        -- need to skip first row: reserved for vitality
        for cell in lines_table[i + 1]:gmatch"." do
          if tonumber(cell) ~= nil then cell = tonumber(cell) end
          row[#row + 1] = cell
        end
        self.rows[i] = row
    end
end

--output number of maze rows
function Maze:maze_dimension()
    return #self.rows
end

function Maze:is_valid()
    local n_cols = #self.rows[1]
    for key, row in pairs(self.rows) do
        if #row ~= n_cols then return false end
    end
    return true
end

function Maze:is_empty()
    return #self.rows == 0
end

function Maze:find_points(symbol)
    local points = {}
    for row_key, row_table in pairs(self.rows) do
        for col_key, element in pairs(row_table) do
          if element == symbol then
            points[#points + 1] = {x = col_key, y = row_key}
          end
        end
    end
    return points
end

function Maze:entry_point_validity()
    local entry_points = self:find_points("i")
    if #entry_points == 1 then return true else return false end
end

function Maze:get_maze()
    return self.rows
end

function Maze:get_walkable_cells()
    local points = {}
    for row_key, row_table in pairs(self.rows) do
        for col_key, element in pairs(row_table) do
          if element ~= "m" then
            points[#points + 1] = {x = col_key, y = row_key}
          end
        end
    end
    return points
end


-- builds a maze from the table containing lines of the file
function build_maze(lines_table)
  local maze = Maze:new()
  maze:initialize(lines_table)
  return maze
end


-- builds the start table: it contains vitality of the player, entry point and exit points
function build_start_table(lines_table, maze)
  local start = {}
  start.vitality = lines_table[1]
  assert(maze:entry_point_validity(), "The maze file must contain only one entry point.")
  start.entry_point = maze:find_points("i")[1]
  start.exit_points = maze:find_points("u")
  return start
end

-- builds maze table and start table and checks for input errors
function init_game_data(filename)
  local lines = lines_from(filename)
  local maze = build_maze(lines)
  assert(maze:is_valid(), "Maze format is not correct: rows have not the same number of columns.")
  local start = build_start_table(lines, maze)
  return start, maze
end
