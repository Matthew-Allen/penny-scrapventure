local Object = require "lib/classic"

local Animation = Object:extend()

-- Creates quad-based animation from sprite sheet
-- Works on sprite sheets with sprites of uniform size, where all sprites in a given animation are sequential
-- function Animation:new(spriteSheet, rows, cols, startFrame, endFrame, xDims, yDims, ...)
--     self.dt = 0
--     self.spriteSheet = spriteSheet
--     self.frames = endFrame - startFrame
--     self.currentFrame = 1

--     local nargs = select("#", ...)
--     local varArgs = {...}
--     if nargs ~= 0 then
--         self.scaleX = varArgs[1]
--         if varArgs[2] ~= nil then
--             self.scaleY = varArgs[2]
--         end
--         if varArgs[3] ~= nil then
--             self.xOffset = varArgs[3]
--         end
--         if varArgs[4] ~= nil then
--             self.yOffset = varArgs[4]
--         end
--     else
--         self.scaleX = 1
--         self.scaleY = 1
--     end

--     self.quads = {}
--     local sheetWidth = spriteSheet:getWidth()
--     local sheetHeight = spriteSheet:getHeight()
--     for i = 0, self.frames, 1 do
--         local quadX = ((i+startFrame)%cols)*xDims
--         local quadY = math.floor((startFrame + i)/cols)*yDims
--         local frameQuad = love.graphics.newQuad(quadX, quadY, xDims, yDims, sheetWidth, sheetHeight)
--         table.insert(self.quads, frameQuad)
--     end
-- end

function Animation:new(defTable)
    self.currentFrame = 1
    for k, v in pairs(defTable) do
        self[k] = v
    end
    self.quads = {}
    local sheetWidth = self.spriteSheet:getWidth()
    local sheetHeight = self.spriteSheet:getHeight()
    self.frames = self.endFrame - self.startFrame
    for i = 0, self.frames, 1 do
        local quadX = ((i+self.startFrame)%self.cols)*self.frameWidth
        local quadY = math.floor((self.startFrame + i)/self.cols)*self.frameHeight
        local frameQuad = love.graphics.newQuad(quadX, quadY, self.frameWidth, self.frameHeight, sheetWidth, sheetHeight)
        table.insert(self.quads, frameQuad)
    end
end

function Animation:play(x, y, scaleX, scaleY, dt)
    self.currentFrame = self.currentFrame + self.animationSpeed*dt
    if self.currentFrame >= self.frames+1 then
        self.currentFrame = 1
    end

    love.graphics.draw(self.spriteSheet, self.quads[math.floor(self.currentFrame)], x+self.xOffset*(-scaleX), y+self.yOffset*scaleY, 0, scaleX, scaleY)

end

return Animation
