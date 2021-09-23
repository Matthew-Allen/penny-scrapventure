local Object = require"classic"

local Vector = Object:extend()


function Vector:new(x,y)
    self.x = x
    self.y = y
end

function Vector.__add(a,b)
    if type(a) == "number" then
        return Vector(a+b.x, a+b.y)
    elseif type(b) == "number" then
        return Vector(a.x+b, a.y+b)
    else
        return Vector(a.x+b.x,a.y+b.y)
    end
end

function Vector.__mul(a,b)
    if type(a) == "number" then
        return Vector(b.x*a, b.y*a)
    elseif type(b) == "number" then
        return Vector(a.x*b, a.y*b)
    else
        return Vector(a.x*b.x, a.y*b.y)
    end
end

function Vector.__eq(a,b)
    return a.x == b.x and a.y == b.y
end

function Vector.__lt(a,b)
    return a.magnitude() < b.magnitude()
end

function Vector.__gt(a,b)
    return a.magnitude() > b.magnitude()
end

function Vector:__tostring()
    return ("(" .. self.x .. "," .. self.y .. ")")
end

function Vector:dotProduct(vec)
    return (self.x*vec.x + self.y*vec.y)
end

function Vector:magnitude()
    return math.sqrt(self.x^2 + self.y^2)
end

function Vector:normalized()
    return Vector(self.x/self:magnitude(), self.y/self:magnitude())
end

function Vector:normalize()
    local magnitude = self:magnitude()
    self.x = self.x/magnitude
    self.y = self.y/magnitude
end


local v1 = Vector(5,10)
local v2 = Vector(15,20)

print(v1 + v2)
