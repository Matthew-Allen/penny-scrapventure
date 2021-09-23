local Diggable = require "entities/diggable"

local ScrapDirt = Diggable:extend()

function ScrapDirt:new(x, y, diggableTable)
    ScrapDirt.super.new(self,x, y, diggableTable)
    self.diggableType = "scrapdirt"
    self.name = "scrapdirt"
end

function ScrapDirt:die()
    local message = messageQueue:newMessage(self, self.digger, "getScrap", 1)
    print(message.messageType)
    messageQueue:send(message)
end

function ScrapDirt:draw(dt)
    love.graphics.draw(spriteTable["Diggable JunkDirt.png"],self.x, self.y)
end
return ScrapDirt
