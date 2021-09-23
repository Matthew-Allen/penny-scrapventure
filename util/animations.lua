local Animation = require "util/animation"

local animationDefs = {
    penny_standing = {
        spriteSheetName = "penny_sheet.png",
        rows = 10,
        cols = 9,
        startFrame = 0,
        endFrame = 0,
        frameWidth = 32,
        frameHeight = 32,
        xOffset = 19,
        yOffset = -2,
        animationSpeed = 10
    },
    penny_walk = {
        spriteSheetName = "penny_sheet.png",
        rows = 10,
        cols = 9,
        startFrame = 18,
        endFrame = 21,
        frameWidth = 32,
        frameHeight = 32,
        xOffset = 19,
        yOffset = -2,
        animationSpeed = 10
    },
    penny_jump = {
        spriteSheetName = "penny_sheet.png",
        rows = 10,
        cols = 9,
        startFrame = 27,
        endFrame = 27,
        frameWidth = 32,
        frameHeight = 32,
        xOffset = 19,
        yOffset = -2,
        animationSpeed = 10
    },
    penny_fall = {
        spriteSheetName = "penny_sheet.png",
        rows = 10,
        cols = 9,
        startFrame = 45,
        endFrame = 47,
        frameWidth = 32,
        frameHeight = 32,
        xOffset = 19,
        yOffset = -2,
        animationSpeed = 10
    },
    penny_drill = {
        spriteSheetName = "penny_sheet.png",
        rows = 10,
        cols = 9,
        startFrame = 63,
        endFrame = 67,
        frameWidth = 32,
        frameHeight = 32,
        xOffset = 28,
        yOffset = -2,
        animationSpeed = 10
    },
    penny_drillUp = {
        spriteSheetName = "penny_sheet.png",
        rows = 10,
        cols = 9,
        startFrame = 81,
        endFrame = 85,
        frameWidth = 32,
        frameHeight = 32,
        xOffset = 15,
        yOffset = 0,
        animationSpeed = 10
    },
    penny_drillDown = {
        spriteSheetName = "penny_sheet.png",
        rows = 10,
        cols = 9,
        startFrame = 54,
        endFrame = 58,
        frameWidth = 32,
        frameHeight = 32,
        xOffset = 15,
        yOffset = 0,
        animationSpeed = 10
    },
    penny_startHover = {
        spriteSheetName = "penny_sheet.png",
        rows = 10,
        cols = 9,
        startFrame = 36,
        endFrame = 40,
        frameWidth = 32,
        frameHeight = 32,
        xOffset = 0,
        yOffset = 0,
        animationSpeed = 15
    },
    penny_hover = {
        spriteSheetName = "penny_sheet.png",
        rows = 10,
        cols = 9,
        startFrame = 41,
        endFrame = 45,
        frameWidth = 32,
        frameHeight = 32,
        xOffset = 0,
        yOffset = 0,
        animationSpeed = 10
    }
}

local Animations = {}

function Animations:init(textures)
    for k, v in pairs(animationDefs) do
        print("Loading animation " .. k)
        v.spriteSheet = textures[v.spriteSheetName]
        self[k] = Animation(v)
    end
end

return Animations
