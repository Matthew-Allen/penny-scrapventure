local Entity = require "entities/entity"
local Animation = require "animation"


local Player = Entity:extend()

function Player:new(x, y)
    self.entityType = "Player"
    self.lastBullet = 1000

    --World data init
    self.w = 9
    self.h = 31
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
    self.moveSpeed = 50
    self.acceleration = 20
    self.onGround = false

    -- Entity state data
    self.digging = false
    self.digTarget = nil
    self.digCooldown = 0
    self.hovering = false
    self.hoverTimeout = 0
    self.hoverTransitionTimer = 0
    self.collectedScrap = 0
    self.collectedResources = 0

    --Animations data
    self.facing = "right"
    self.animations = {}
    local penny_sheet = spriteTable["penny_sheet.png"]
    self.animations.stand = Animation(penny_sheet, 10, 9, 0, 0, 32, 32)
    self.animations.walk = Animation(penny_sheet, 10, 9, 18, 21, 32, 32)
    self.animations.jump = Animation(penny_sheet, 10, 9, 27, 27, 32, 32)
    self.animations.fall = Animation(penny_sheet, 10, 9, 45, 47, 32, 32)
    self.animations.drillDown = Animation(penny_sheet, 10, 9, 54, 58, 32, 32)
    self.animations.drillRight = Animation(penny_sheet, 10, 9, 63, 67, 32, 32)
    self.animations.drillLeft = Animation(penny_sheet, 10, 9, 72, 76, 32, 32)
    self.animations.drillUp = Animation(penny_sheet, 10, 9, 81, 85, 32, 32)
    self.animations.startHover = Animation(penny_sheet, 10, 9, 36, 40, 32, 32)
    self.animations.hover = Animation(penny_sheet, 10, 9, 41, 45, 32, 32)

    self.currentAnimation = "standing"
    self.facing = "right"
end

local function sign(number)
    if number >= 0 then
        return 1
    else
        return -1
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

    if love.keyboard.isDown("x") and self.hovering == false and self.hoverTimeout < 0 then
        self.hoverTransitionTimer = .35
        self.hovering = true
        self.hoverTimeout = .5
    elseif love.keyboard.isDown("x") and self.hovering == true and self.hoverTimeout < 0 then
        self.hovering = false
        self.hoverTimeout = .5
    end
    self.hoverTimeout = self.hoverTimeout - dt
    self.hoverTransitionTimer = self.hoverTransitionTimer - dt
    if self.hovering then
        self:runHover(dt)
    end

    if self.digging == false and self.hovering == false then
        self:runImpulse(dt)
        self.digCooldown = self.digCooldown - dt
    end
    if not (self.digTarget == nil) then
        if self.digTarget.alive == false or not love.keyboard.isDown("c") then
            local stopDigMessage = messageQueue:newMessage(self, self.digTarget, "stopDigging", nil)
            messageQueue:send(stopDigMessage)
            self.digTarget = nil
            self.digging = false
            self.digCooldown = .25
        end
    end
    for _, collision in ipairs(self.collisions) do
        if love.keyboard.isDown("c") then
            local digDirection = self:canDig(collision.other)
            if digDirection ~= "none" then
                self.digging = true
                self.digTarget = collision.other
                self.digDirection = digDirection
                local digMessage = messageQueue:newMessage(self, collision.other, "startDigging", nil)
                messageQueue:send(digMessage)
            end
        end
    end

    -- Update animation states
    if self.digging == true then
        if self.digDirection == "side" then
            if self.facing == "left" then
                self.currentAnimation = "drilling_left"
            else
                self.currentAnimation = "drilling_right"
            end
        elseif self.digDirection == "down" then
            self.currentAnimation = "drilling_down"
        elseif self.digDirection == "up" then
            self.currentAnimation = "drilling_up"
        end
    else
        if self.velocity.x > 0 then
            self.facing = "right"
        elseif self.velocity.x < 0 then
            self.facing = "left"
        end
        if self.onGround == false then
            if self.velocity.y > 0 then
                self.currentAnimation = "jumping"
            else
                self.currentAnimation = "falling"
            end
        elseif self.velocity.x == 0 and self.onGround == true then
            self.currentAnimation = "standing"
        else
            self.currentAnimation = "walking"
        end
    end

    -- Ensure that collisions table is emptied even if we don't make another move call
    self.collisions = {}
end

function Player:onMessage(message)
    if message.messageType == "getScrap" then
        self.collectedScrap = self.collectedScrap + message.data
        print("Current scrap is now: " .. self.collectedScrap)
    end
end

function Player:draw(dt)

    local rightOffset = -12
    local leftOffset = 22
    local yOffset = -1

    if self.hovering then
        if self.facing == "right" then
            if self.hoverTransitionTimer > 0  then
                self.animations.startHover:play(self.x+rightOffset, self.y+yOffset, 20, dt)
            else
                self.animations.hover:play(self.x+rightOffset, self.y+yOffset, 10, dt)
            end
        else
            if self.hoverTransitionTimer > 0 then
                self.animations.startHover:play(self.x+leftOffset, self.y+yOffset, 20, dt, -1, 1)
            else
                self.animations.hover:play(self.x+leftOffset, self.y+yOffset, 10, dt, -1, 1)
            end
        end
    elseif self.currentAnimation == "standing" then
        if self.facing == "right" then
            self.animations.stand:play(self.x+rightOffset, self.y+yOffset, 10, dt)
        else
            self.animations.stand:play(self.x+leftOffset, self.y+yOffset, 10, dt, -1, 1)
        end
    elseif self.currentAnimation == "walking" then
        if self.facing == "right" then
            self.animations.walk:play(self.x+rightOffset, self.y+yOffset, 10, dt)
        else
            self.animations.walk:play(self.x+leftOffset, self.y+yOffset, 10, dt, -1, 1)
        end
    elseif self.currentAnimation == "jumping" then
        if self.facing == "right" then
            self.animations.jump:play(self.x+rightOffset, self.y+yOffset, 10, dt)
        else
            self.animations.jump:play(self.x+leftOffset, self.y+yOffset, 10, dt, -1, 1)
        end
    elseif self.currentAnimation == "drilling_down" then
        if self.facing == "right" then
            self.animations.drillDown:play(self.x+rightOffset, self.y+yOffset, 10, dt)
        else
            self.animations.drillDown:play(self.x+leftOffset, self.y+yOffset, 10, dt, -1, 1)
        end
    elseif self.currentAnimation == "drilling_left" then
        self.animations.drillLeft:play(self.x+0, self.y+yOffset, 10, dt)
    elseif self.currentAnimation == "drilling_right" then
        self.animations.drillRight:play(self.x-22, self.y+yOffset, 10, dt)
    elseif self.currentAnimation == "drilling_up" then
        if self.facing == "right" then
            self.animations.drillUp:play(self.x+rightOffset, self.y+yOffset, 10, dt)
        else
            self.animations.drillUp:play(self.x+leftOffset, self.y+yOffset, 10, dt, -1, 1)
        end
    elseif self.currentAnimation == "falling" then
        if self.facing == "right" then
            self.animations.fall:play(self.x+rightOffset, self.y+yOffset, 10, dt)
        else
            self.animations.fall:play(self.x+leftOffset, self.y+yOffset, 10, dt, -1, 1)
        end
    end
end

return Player
