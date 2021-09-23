local Diggable = require "entities/diggable"

local Stone = Diggable:extend()

function Stone:new(x, y, diggableTable)
    Stone.super.new(self, x, y, diggableTable)
    self.diggableType = "stone"
    self.name = "stone"
end

function Stone:draw(dt)
    local left = self.diggables[self.index.x-1][self.index.y]
    local right = self.diggables[self.index.x+1][self.index.y]
    local up = self.diggables[self.index.x][self.index.y-1]
    local down = self.diggables[self.index.x][self.index.y+1]
    if left ~= 0 then
        left = left.diggableType
    end
    if right ~= 0 then
        right = right.diggableType
    end
    if up ~= 0 then
        up = up.diggableType
    end
    if down ~= 0 then
        down = down.diggableType
    end
    if up == "dirt" and down == "dirt" and left == "dirt" and right == "dirt" then
        love.graphics.draw(spriteTable["Diggable StoneSingleTile.png"], self.x, self.y)
    elseif left == "dirt" then
        if up == "dirt" then
            love.graphics.draw(spriteTable["Diggable StoneWithDirtTopLeftCorner.png"], self.x, self.y)
        elseif down == "dirt" then
            love.graphics.draw(spriteTable["Diggable StoneWithDirtBottomLeftCorner.png"], self.x, self.y)
        else
            love.graphics.draw(spriteTable["Diggable StoneWithDirtSideLeft.png"], self.x, self.y)
        end
    elseif right == "dirt" then
        if up == "dirt" then
            love.graphics.draw(spriteTable["Diggable StoneWithDirtTopRightCorner.png"], self.x, self.y)
        elseif down == "dirt" then
            love.graphics.draw(spriteTable["Diggable StoneWithDirtBottomRightCorner.png"], self.x, self.y)
        else
            love.graphics.draw(spriteTable["Diggable StoneWithDirtSideRight.png"], self.x, self.y)
        end
    elseif up == "dirt" then
        love.graphics.draw(spriteTable["Diggable StoneWithDirtTop.png"], self.x, self.y)
    elseif down == "dirt" then
        love.graphics.draw(spriteTable["Diggable StoneWithDirtBottom.png"], self.x, self.y)
    else
        love.graphics.draw(spriteTable["Diggable Stone.png"], self.x, self.y)
    end
end

return Stone
