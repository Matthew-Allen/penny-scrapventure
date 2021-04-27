local Entity = require "entities/entity"
local Animation = require "animation"

local Recycler = Entity:extend()

function Recycler:new(x, y)

    self.state = "idle"
    self.animations = {}
    local spriteSheet = spriteTable["Recycler Sheet.png"]
    self.animations.idle = Animation(spriteSheet, 9, 6, 0, 0, 32, 32)
    self.animations.input = Animation(spriteSheet, 9, 6, 6, 16, 32, 32)
    self.animations.output_copper = Animation(spriteSheet, 9, 6, 24, 30, 32, 32)
end

function Recycler:update(dt)
    if self.state == "input" then
        self.processingTimer = self.processingTimer - dt
    end
    if self.state == "input" and self.processingTimer < 0 then
        self.state = "output_copper"
    end
end

function Recycler:onMessage(message)
    if message.messageType == "process" then
        self.state = "processing"
        self.processingTimer = 1
    end
end

function Recycler:draw(dt)
    if self.state == "idle" then
        self.animations.idle:play(self.x, self.y, 10, dt)
    elseif self.state == "input" then
        self.animations.input:play(self.x, self.y, 10, dt)
    elseif self.state == "output_copper" then
        self.animations.output_copper:play(self.x, self.y, 10, dt)
    end
end
