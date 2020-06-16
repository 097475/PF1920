function MONAD ( modifier )
    local prototype = {}
    local unit = function ( value )
        local monad = { bind = function ( self , func , ... )
                              return func ( value , ... )
                              end }
        if type (modifier)== "function" then modifier(monad , value) end
        return setmetatable( monad , { __index = prototype })
    end
    return unit
end


function maybe_behavior( monad , value )
    if value == nil then 
        monad.is_null = true
        monad.bind = function () return monad end
    end
end

function write_behaviour(monad, value)
  if value == nil then
    monad.is_null = true
    monad.bind = function () return monad end
    local file = io.open("log.txt", "w")
    file:write("Error in writing file\n")
  else
    local file = io.open("log.txt", "w")
    file:write("Success in writing file\n")
  end
end

Maybe = MONAD(maybe_behavior)
Write = MONAD(write_behaviour)
