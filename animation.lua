local Object = require "classic"

local Animation = Object:extend()

-- Creates quad-based animation from sprite sheet
-- Works on sprite sheets with sprites of uniform size, where all sprites in a given animation are sequential
function Animation:new(spriteSheet, rows, cols, startFrame, endFrame, xDims, yDims)
    self.dt = 0
    self.spriteSheet = spriteSheet
    self.frames = endFrame - startFrame
    self.currentFrame = 1

    self.quads = {}
    local sheetWidth = spriteSheet:getWidth()
    local sheetHeight = spriteSheet:getHeight()
    for i = 0, self.frames, 1 do
        local quadX = ((i+startFrame)%cols)*xDims
        local quadY = math.floor((startFrame + i)/cols)*yDims
        local frameQuad = love.graphics.newQuad(quadX, quadY, xDims, yDims, sheetWidth, sheetHeight)
        table.insert(self.quads, frameQuad)
    end
end

function Animation:play(x, y, speed, dt, ...)
    local nargs = select("#",...)
    local varArgs = {...}
    local scaleX = 1
    local scaleY = 1
    if nargs ~= 0 then
        scaleX = varArgs[1]
        if varArgs[2] ~= nil then
            scaleY = varArgs[2]
        end
    end
    self.currentFrame = self.currentFrame + speed*dt
    if self.currentFrame >= self.frames+1 then
        self.currentFrame = 1
    end

    love.graphics.draw(self.spriteSheet, self.quads[math.floor(self.currentFrame)], x, y, 0, scaleX, scaleY)

end

return Animation
