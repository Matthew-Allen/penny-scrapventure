local Dirt = require "entities/dirt"

local Grass = Dirt:extend()

function Grass:draw(dt)
    love.graphics.draw(spriteTable["Diggable GrassDirt.png"],self.x, self.y)
end

return Grass
