local Entity = require "entities/entity"

local Diggable = Entity:extend()

Diggable.beingDug = false
Diggable.digTime = 0
function Diggable:new(x, y, diggableTable)
    self.entityType = "diggable"
    self.index = {}
    self.index.x = x
    self.index.y = y

    self.position = {}
    self.x = x*32
    self.y = y*32
    self.diggables = diggableTable
    self.w = 32
    self.h = 32
end

function Diggable:update(dt)
    if self.beingDug == true then
        self.digTime = self.digTime + dt
    elseif self.beingDug == false then
        self.digTime = 0
    end

    if self.digTime > 1 then
        messageQueue:send(messageQueue:newMessage(self, self.digger, "blockBreak"))
        self:die()
    end
end

function Diggable:die()
    self.alive = false
end

function Diggable:onMessage(message)
    if message.messageType == "startDigging" then
        self.digger = message.sender
        self.beingDug = true
    elseif message.messageType == "stopDigging" then
        self.beingDug = false
        self.digTime = 0
    end
end

return Diggable
