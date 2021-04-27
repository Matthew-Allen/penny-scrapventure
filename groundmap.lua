local Entity = require "entity"
local Animation = require "animation"

local Ground = Entity:Extend()

local tiles
function Ground:new(mapfile)
    tiles = {}
    for i = 0, mapfile.layers[0].height, 1 do
        tiles[i] = {}
    end
end

function Ground:update(dt)
end

function Ground:draw(dt)
end

return Ground
