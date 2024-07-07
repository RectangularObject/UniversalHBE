local baseConnection = {}
baseConnection.__index = baseConnection

function baseConnection.new(callback)
	local connection = setmetatable({ callback = callback }, baseConnection)
	return connection
end
function baseConnection:Disconnect()
	self.callback = nil
	self = nil
end

local baseEvent = {}
baseEvent.__index = baseEvent

function baseEvent.new()
	local event = setmetatable({ connections = {} }, baseEvent)
	return event
end
function baseEvent:Connect(callback)
	local connection = baseConnection.new(callback)
	table.insert(self.connections, connection)
	return connection
end
function baseEvent:Fire(payload)
	for _, connection in self.connections do
		connection.callback(payload)
	end
end

return baseEvent
