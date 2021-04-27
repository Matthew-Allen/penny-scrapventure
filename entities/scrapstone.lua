local Diggable = require "entities/diggable"

local ScrapStone = Diggable:extend()

function ScrapStone:new(x, y, diggableTable)
    ScrapStone.super.new(self,x, y, diggableTable)
    self.diggableType = "scrapdirt"
end

function ScrapStone:die()
    local message = messageQueue:newMessage(self, self.digger, "getScrap", 2)
    print(message.messageType)
    messageQueue:send(message)
end

function ScrapStone:draw(dt)
    love.graphics.draw(spriteTable["Diggable StoneScrap.png"],self.x, self.y)
end
return ScrapStone
