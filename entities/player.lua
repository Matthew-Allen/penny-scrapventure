local Object = require "lib/classic"
local Entity = require "entities/entity"
local Animations = require "util/animations"
local dbg = require "lib/debugger"

-- State machine code
local State = Object:extend()
function State:update(dt) end -- Dummy update function


local AirState = State:extend()
local WalkingState = State:extend()
local DiggingState = State:extend()
local HoverState = State:extend()
function WalkingState:new(parent)
    self.stateName = "WalkingState"
    self.parent = parent
    parent.currentAnimation = Animations.penny_standing
end
function WalkingState:update(dt)
    local parent = self.parent

    parent:runImpulse(dt)
    if parent.velocity.x < 0 then
        parent.facing = "left"
        parent.animationSpeed = 10
    elseif parent.velocity.x > 0 then
        parent.facing = "right"
        parent.animationSpeed = 10
    end

    if parent.velocity.x == 0 then
        parent.currentAnimation = Animations.penny_standing
    else
        parent.currentAnimation = Animations.penny_walk
    end
    if parent.velocity.y ~= 0 then
        parent.currentState = AirState(parent)
    end

    if love.keyboard.isDown("c") then
        local diggableFacing, digTarget = parent:probeDiggables()
        if diggableFacing ~= nil then
            self.parent.currentState = DiggingState(parent, diggableFacing, digTarget)
        end
    end
end

function AirState:new(parent)
    self.stateName = "AirState"
    self.parent = parent
    self.fallTime = 0
    parent.currentAnimation = Animations.penny_jump
end
function AirState:update(dt)
    local parent = self.parent
    parent:runImpulse(dt)
    self.fallTime = self.fallTime + dt
    if parent.velocity.x < 0 then
        parent.facing = "left"
    elseif parent.velocity.x > 0 then
        parent.facing = "right"
    end

    if parent.velocity.y > 0 then
        self.fallTime = 0
        parent.animationSpeed = 10
        parent.currentAnimation = Animations.penny_jump
    elseif parent.velocity.y < 0 then
        self.fallTime = self.fallTime + dt
        if self.fallTime > .03 then
            parent.animationSpeed = 0
        end
        parent.currentAnimation = Animations.penny_fall
    else
        parent.currentState = WalkingState(parent, parent.facing)
    end
    if love.keyboard.isDown("c") then
        local diggableFacing, digTarget = parent:probeDiggables()
        if diggableFacing ~= nil then
            self.parent.currentState = DiggingState(parent, diggableFacing, digTarget)
        end
    end
    if self.parent.keysPressed["x"] == true then
        self.parent.currentState = HoverState(self.parent)
    end
end

function HoverState:new(parent)
    self.parent = parent
    self.timeHovering = 0
    parent.currentAnimation = Animations.penny_startHover
end

function HoverState:update(dt)
    self.timeHovering = self.timeHovering + dt
    self.parent:runHover(dt)
    if self.timeHovering >= .35 then
        self.parent.currentAnimation = Animations.penny_hover
    end
    if self.timeHovering >= .5 and self.parent.keysPressed["x"] then
        self.parent.currentState = WalkingState(self.parent)
    end
end

function DiggingState:new(parent, digDirection, target)
    self.stateName= "DiggingState"
    self.parent = parent
    self.digTime = 0
    self.target = target
    self.stopDigMessage = false
    parent.animationSpeed = 10
    if digDirection == "left" or digDirection == "right" then
        parent.currentAnimation = Animations.penny_drill
    elseif digDirection == "up" then
        parent.currentAnimation = Animations.penny_drillUp
    else
        parent.currentAnimation = Animations.penny_drillDown
    end


    messageQueue:send(messageQueue:newMessage(parent, target, "startDigging"))
end

function DiggingState:update(dt)
    if not love.keyboard.isDown("c") or self.stopDigMessage then
        if self.parent.facing ~= "down" and self.parent.facing ~= "up" then
            self.parent.currentState = WalkingState(self.parent, self.parent.facing)
        else
            self.parent.currentState = WalkingState(self.parent, "right")
        end
        messageQueue:send(messageQueue:newMessage(self.parent, self.target, "stopDigging"))
    end
    self.digTime = self.digTime + dt
end

local Player = Entity:extend()

function Player:new(x, y)
    Player.super:new(x, y, 9, 31)
    self.messages = {}
    self.keysPressed = {}
    self.entityType = "Player"
    self.lastBullet = 1000

    --World data init
    self.x = x
    self.y = y
    self.collisions = {}
    -- Platforming movement variables
    self.damping = 10
    self.gravity = 20
    self.velocity = {}
    self.velocity.x = 0
    self.velocity.y = 0
    self.maxVelocity = {}
    self.maxVelocity.x = 150
    self.maxVelocity.y = 500
    self.acceleration = 20
    self.onGround = false
    self.facing = "right"

    -- Entity state data
    self.collectedScrap = 0
    self.collectedResources = 0
    self.keyCooldown = 0
    self.currentAnimation = Animations.penny_standing

    self.currentState = WalkingState(self)
end

function Player:handleKeyPress(key)
    if self.keysPressed ~= nil then
        self.keysPressed[key] = true
    end
end

local function sign(number)
    if number >= 0 then
        return 1
    else
        return -1
    end
end

function Player:probeDiggables()
    for _, collision in ipairs(self.collisions) do
        local entity = collision.other
        if entity.entityType == "diggable" then
            if self.y + (self.h/2) > entity.y and self.y + (self.h/2) < entity.y+entity.h then
                if entity.x > self.x then
                    return "right", entity
                else
                    return "left", entity
                end
            elseif self.y+self.h <= entity.y and love.keyboard.isDown("down") then
                return "down", entity
            elseif self.y >= entity.y+entity.h and love.keyboard.isDown("up") then
                return "up", entity
            else
                return nil, entity
            end
        end
    end
end

function Player:runHover(dt)

    if love.keyboard.isDown("left") then
        self.velocity.x = self.velocity.x - self.acceleration
    elseif love.keyboard.isDown("right") then
        self.velocity.x = self.velocity.x + self.acceleration
    end
    if love.keyboard.isDown("up") then
        self.velocity.y = self.velocity.y + self.acceleration
    elseif love.keyboard.isDown("down") then
        self.velocity.y = self.velocity.y - self.acceleration
    end

    local newX = self.x + self.velocity.x*dt
    local newY = self.y - self.velocity.y*dt
    self.x, self.y, self.collisions = self.world:move(self, newX, newY)

    -- If we collided, set velocity to 0, determine whether we're on the ground or falling
    if newX ~= self.x then
        self.velocity.x = 0
    end
    if newY ~= self.y then
        if newY > self.y then
            self.onGround = true
        end
        self.velocity.y = 0
    else
        self.onGround = false
    end

    -- Respect maximum velocity
    if math.abs(self.velocity.x) > self.maxVelocity.x then
        self.velocity.x = self.maxVelocity.x*sign(self.velocity.x)
    end
    if math.abs(self.velocity.y) > self.maxVelocity.y then
        self.velocity.y = self.maxVelocity.y*sign(self.velocity.y)
    end

    --Set velocity values to 0 if damping would cause oscillation, otherwise perform damping
    if math.abs(self.velocity.x) < self.damping then
        self.velocity.x = 0
    else
        self.velocity.x = self.velocity.x - sign(self.velocity.x)*self.damping
    end
    if math.abs(self.velocity.y) < self.damping then
        self.velocity.y = 0
    else
        self.velocity.y = self.velocity.y - sign(self.velocity.y)*self.damping
    end
end

function Player:runImpulse(dt)

    if love.keyboard.isDown("z") and self.onGround == true then
        self.velocity.y = self.maxVelocity.y
        self.onGround = false
    end
    self.velocity.y = self.velocity.y - self.gravity
    if love.keyboard.isDown("left") then
        self.velocity.x = self.velocity.x - self.acceleration
    elseif love.keyboard.isDown("right") then
        self.velocity.x = self.velocity.x + self.acceleration
    end

    local newX = self.x + self.velocity.x*dt
    local newY = self.y - self.velocity.y*dt
    self.x, self.y, self.collisions = self.world:move(self, newX, newY)

    -- If we collided, set velocity to 0, determine whether we're on the ground or falling
    if newX ~= self.x then
        self.velocity.x = 0
    end
    if newY ~= self.y then
        if newY > self.y then
            self.onGround = true
        end
        self.velocity.y = 0
    else
        self.onGround = false
    end

    -- Respect maximum velocity
    if math.abs(self.velocity.x) > self.maxVelocity.x then
        self.velocity.x = self.maxVelocity.x*sign(self.velocity.x)
    end
    if math.abs(self.velocity.y) > self.maxVelocity.y then
        self.velocity.y = self.maxVelocity.y*sign(self.velocity.y)
    end

    --Set velocity values to 0 if damping would cause oscillation, otherwise perform damping
    if math.abs(self.velocity.x) < self.damping then
        self.velocity.x = 0
    else
        self.velocity.x = self.velocity.x - sign(self.velocity.x)*self.damping
    end
    if math.abs(self.velocity.y) < self.damping then
        self.velocity.y = 0
    else
        self.velocity.y = self.velocity.y - sign(self.velocity.y)*self.damping
    end
end

function Player:canDig(entity)
    if entity.entityType == "diggable" and not self.digging and self.digCooldown < 0 then
        if self.y + (self.h/2) > entity.y and self.y + (self.h/2) < entity.y+entity.h then
            return "side"
        elseif self.y+self.h <= entity.y and love.keyboard.isDown("down") then
            return "down"
        elseif self.y >= entity.y+entity.h and love.keyboard.isDown("up") then
            return "up"
        end
    end
    return "none"
end

function Player:update(dt)

    self.currentState:update(dt)
    -- Ensure that collisions table is emptied even if we don't make another move call
    self.collisions = {}
    self.messages = {}
    self.keysPressed = {} -- Clear keys pressed after every iteration because they should only register once.
end

function Player:onMessage(message)
    table.insert(self.messages, message)
    if message.messageType == "getScrap" then
        self.collectedScrap = self.collectedScrap + message.data
        print("Current scrap is now: " .. self.collectedScrap)
    end
    if message.messageType == "blockBreak" then
        self.currentState.stopDigMessage = true
    end
end

function Player:draw(dt)

    local xScale
    if self.facing == "right" then
        xScale = 1
    else
        xScale = -1
    end

    self.currentAnimation:play(self.x+4, self.y, xScale, 1, dt)
end

return Player
