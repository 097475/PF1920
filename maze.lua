Maze = {}

function Maze:new()
    local object = {}

    object.rows = {}

    self.__index = self
    return setmetatable(object, self)
end

function Maze:initialize(lines_table)
    for i=1,#lines-1 do
        row = {}
        -- need to skip first row: reserved for vitality
        for cell in lines[i + 1]:gmatch"." do
          if tonumber(cell) ~= nil then cell = tonumber(cell) end
          row[#row + 1] = cell
        end
        self.rows[i] = row
    end
end

function Maze:maze_dimension()
    return #rows
end

function Maze:is_valid()
    local n_cols = #self.rows[1]
    for key, row in pairs(self.rows) do
        if #row ~= n_cols then do return false end end
    end
    return true
end

function Maze:is_empty()
    return #self.rows
end

function Maze:find_points(symbol)
    local points = {}
    for row_key, row_table in pairs(self.rows) do
        for col_key, element in pairs(row_table) do
        if element == symbol then
            local points_index = #points + 1
            points[points_index] = {}
            points[points_index].x = col_key
            points[points_index].y = row_key
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