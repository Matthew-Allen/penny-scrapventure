local Object = require "lib/classic"

local TileBG = Object:extend()

function TileBG:new(xSize, ySize, tileArray)
    self.bgCanvas = love.graphics.newCanvas(xSize*16, ySize*16)
    love.graphics.setCanvas(self.bgCanvas)
    love.graphics.clear()

    for i = 1, xSize, 1 do
        for j = 1, ySize, 1 do
            love.graphics.draw(tileArray[i][j], (i-1)*16, (j-1)*16)
        end
    end
    love.graphics.setCanvas()
end

function TileBG:draw(dt)
    love.graphics.draw(self.bgCanvas)
end

return TileBG
