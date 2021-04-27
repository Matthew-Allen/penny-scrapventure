local Object = require "classic"

local MessageQueue = Object:extend()

local internalList
local index
function MessageQueue:new()
    index = -1
    internalList = {}
end

function MessageQueue:send(newMessage)
    index = index+1
    internalList[index] = newMessage
end

function MessageQueue:newMessage(sender, receiver, messageType, data)
    local newMessage = {}
    newMessage.sender = sender
    newMessage.receiver = receiver
    newMessage.messageType = messageType
    newMessage.data = data
    return newMessage
end

function MessageQueue:dispatch()
    while index ~= -1 do
        if internalList[index].receiver ~= nil then
            internalList[index].receiver:onMessage(internalList[index])
        end
        internalList[index] = nil
        index = index - 1
    end
end

return MessageQueue
