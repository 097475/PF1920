function MONAD ( modifier )
    local prototype = {}
    local unit = function ( value )
        local monad = { bind = function ( self , func , ... ) return func ( value , ... ) end }
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


function prova(a)
    if a == nil then print("Cagnolino") else print(a) end
end

Maybe = MONAD(maybe_behavior)
local monad = Maybe(nil)
monad:bind(prova)