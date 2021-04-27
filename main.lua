local bump = require "bump"
local Player = require "entities/player"
local DiggableDirt = require "entities/dirt"
local DiggableStone = require "entities/stone"
local DiggableGrassDirt = require "entities/grassdirt"
local DiggableScrapDirt = require "entities/scrapdirt"
local DiggableScrapStone = require "entities/scrapstone"
local Camera = require "camera"
local Map = require "map"
local MessageQueue = require "messagequeue"

spriteTable = {}
messageQueue = MessageQueue()
local entities = {}
local world = bump.newWorld(64)
local drawBoundingBoxes = false
local cam
local currentMap
local player
local showTitleScreen = true

function entities:getByName(name)
    for _, entity in ipairs(self) do
        if entity.name == name then
            return entity
        end
    end
    return nil
end

local function loadSprites(directory, table)
    local files = love.filesystem.getDirectoryItems(directory)
    for _, filename in ipairs(files) do
        if love.filesystem.getInfo(directory .. "/" .. filename).type == "file"  then
            table[filename] = love.graphics.newImage(directory .. "/" .. filename)
            print("Loaded file " .. filename)
        end
    end
end

-- places entity into bump world at the requested x and y coordinates
-- and adds to the entities list.
function spawn(entity)
    table.insert(entities, entity)
    world:add(entity, entity.x, entity.y, entity.w, entity.h)
    entity.world = world
end

local function spawnDiggableMap(map)
    for _, layer in pairs(map.layers) do
        local width = layer.width
        local height = layer.height
        local diggablesTable = {}
        for i = 0, width do
            diggablesTable[i] = {}
            for j = 0, height do
                diggablesTable[i][j] = 0
            end
        end
        for i, v in ipairs(layer.data) do
            local x = (i-1) % width
            local y = math.floor((i-1)/width)
            local newDiggable
            if v ~= 0 then
                if v == 1 then
                    newDiggable = DiggableDirt(x, y, diggablesTable)
                end
                if v == 2 then
                    newDiggable = DiggableStone(x, y, diggablesTable)
                end
                if v == 11 then
                    newDiggable = DiggableGrassDirt(x, y, diggablesTable)
                end
                if v == 12 then
                    newDiggable = DiggableScrapDirt(x, y, diggablesTable)
                end
                if v == 13 then
                    newDiggable = DiggableScrapStone(x, y, diggablesTable)
                end
                diggablesTable[x][y] = newDiggable
                spawn(newDiggable)
            end
        end
    end
end
function love.load()
    love.window.setMode(800, 600, {resizable=false})
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setBackgroundColor(135/255, 206/255, 235/255, 1)
    loadSprites("assets/sprites", spriteTable)
    local newPlayer = Player(1000,1150)
    player = newPlayer
    spawn(newPlayer)
    cam = Camera(newPlayer)

    local mapfile = require"maps/background"
    currentMap = Map(mapfile)
    local diggables = require"maps/diggablesmap"
    spawnDiggableMap(diggables)
end

function love.keypressed(key)
    showTitleScreen = false
    if key == "d" then
        if drawBoundingBoxes == false then
            drawBoundingBoxes = true
        else
            drawBoundingBoxes = false
        end
    end
    if key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    if not showTitleScreen then
        for _, entity in ipairs(entities) do
            entity:update(dt)
        end
        for i, entity in ipairs(entities) do
            if entity.alive == false then
                table.remove(entities, i)
                world:remove(entity)
            end
        end
        messageQueue.dispatch()
    end
end

local font = love.graphics.newFont(12)
function love.draw()
    if showTitleScreen then
        love.graphics.draw(spriteTable["title screen.png"], 0, 0)
    else
        local dt = love.timer.getDelta()
        cam:update(dt)
        love.graphics.scale(2,2)
        currentMap:draw()
        for _, entity in ipairs(entities) do
            entity:draw(dt)
            if drawBoundingBoxes == true then
                love.graphics.rectangle("line", entity.x, entity.y, entity.w, entity.h)
            end
        end
        local score = love.graphics.newText(font, "Scrap: " .. player.collectedScrap)
        love.graphics.draw(score, cam.x -200, cam.y-150)
    end
end
