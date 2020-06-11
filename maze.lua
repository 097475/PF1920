require "input-output"

Maze = {}


-- input: Maze (meta)table, maze matrix
-- output: new maze table
--[PURE]
function Maze:new(lines_table)
    local object = {}
    object.rows = {}
    
    for i=1,#lines_table-1 do
      local row = {}
      -- need to skip first row: reserved for vitality
      for cell in lines_table[i + 1]:gmatch"." do
        if tonumber(cell) ~= nil then cell = tonumber(cell) end
        row[#row + 1] = cell
      end
      
      object.rows[i] = row
    end

    self.__index = self
    return setmetatable(object, self)
end

--input: maze, function to apply to Maze functor e.g. function(x) return x end to make a copy
--output: new Maze functor with function f applied to its elements
--[PURE]
function Maze:__call(f)
  local maze = Maze:new({})
  for i, row in ipairs(self.rows) do
    table.insert(maze.rows, {})
    for j, elem in ipairs(row) do
      table.insert(maze.rows[i], f(elem))
    end
  end
  return maze
end


--input: maze
--output: number of maze rows
--[PURE]
function Maze:maze_dimension()
    return #self.rows
end

--input: maze
--output: true if the input maze has a valid number of columns, false otherwise
--[PURE]
function Maze:is_valid()
    local n_cols = #self.rows[1]
    for key, row in pairs(self.rows) do
        if #row ~= n_cols then return false end
    end
    return true
end

--input: maze
--output: true if the input maze is empty, i.e. has no rows, false otherwise
--[PURE]
function Maze:is_empty()
    return #self.rows == 0
end

--input: maze, single character e.g. "i"
--output: table containing a list of maze coordinates corresponding to all occurrences of input character e.g. {{x=1, y=2}, {x=5, y = 3}}
--[PURE]
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

--input: maze
--output: true if the input maze has a single entry point, false otherwise
--[PURE]
function Maze:entry_point_validity()
    local entry_points = self:find_points("i")
    if #entry_points == 1 then return true else return false end
end


--input: maze
--output: maze contents, i.e. the maze matrix
--[PURE]
function Maze:get_maze()
    return self.rows
end

--input: maze
--output: table containing a list of maze coordinates corresponding to all non-wall elements of the maze
--[PURE]
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

--input: initial life, maze 
--output: start table, which contains vitality of the player, entry point and exit point(s)
--[PURE]
function build_start_table(life, maze)
  local start = {}
  start.vitality = life
  assert(maze:entry_point_validity(), "The maze file must contain only one entry point.")
  start.entry_point = maze:find_points("i")[1]
  start.exit_points = maze:find_points("u")
  return start
end

--input: filename with maze to load
--output: start table with initial vitality, entry point and exit point(s), maze table
--[PURE]
function init_game_data(filename)
  local lines = lines_from(filename)
  local maze = Maze:new(lines)
  assert(maze:is_valid(), "Maze format is not correct: rows have not the same number of columns.")
  local start = build_start_table(lines[1], maze)
  return start, maze
end
