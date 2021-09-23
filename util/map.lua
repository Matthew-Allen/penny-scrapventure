local Object = require "lib/classic"
local Barrier = require "entities/barrier"

local Map = Object:extend()

function Map:new(mapfile)
    local defaultMaxSprites = 1000 -- Arbitrary base size, spritebatches expand when you pass the default number anyways

    self.mapfile = mapfile
    self.spriteBatches = {}
    for _, sheet in pairs(mapfile.tilesets) do
        local imageString = string.gsub(sheet.image, "%.%.%/", "")
        sheet.loveImage = love.graphics.newImage(imageString)
    end

    for _, layer in pairs(mapfile.layers) do
        if layer.type ~= "objectgroup" then
            local firstTile = layer.data[1]
            local layerTileset
            for i = #mapfile.tilesets, 1, -1 do
                if firstTile <= mapfile.tilesets[i].firstgid or i == 1 then
                    layerTileset = mapfile.tilesets[i]
                    break
                end
            end
            local newSpriteBatch = love.graphics.newSpriteBatch(layerTileset.loveImage, defaultMaxSprites, "dynamic")
            table.insert(self.spriteBatches, newSpriteBatch)
            for i, tile in ipairs(layer.data) do
                if tile ~= 0 then
                    local x = i%layer.width*mapfile.tilewidth
                    local y = math.floor(i/layer.width)*mapfile.tileheight
                    local quadX = ((tile-1)%(layerTileset.imagewidth/layerTileset.tilewidth))*layerTileset.tilewidth
                    local quadY = math.floor(tile/(layerTileset.imagewidth/layerTileset.tilewidth))*layerTileset.tileheight
                    local texQuad = love.graphics.newQuad(quadX, quadY, layerTileset.tilewidth, layerTileset.tileheight,layerTileset.imagewidth, layerTileset.imageheight)
                    newSpriteBatch:add(texQuad,x, y)
                end
            end
        else
            for _, object in pairs(layer.objects) do
                if object.type == "blocker" then
                    local newBlocker = Barrier(object.x + 32, object.y, object.width, object.height)
                    spawn(newBlocker)
                end
            end
        end
    end
end

function Map:draw()
   for _, batch in ipairs(self.spriteBatches) do
       love.graphics.draw(batch)
   end
end

return Map
