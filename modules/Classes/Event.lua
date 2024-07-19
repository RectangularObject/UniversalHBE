type ConnectionImpl = {
	__index: ConnectionImpl,
	new: (callback: (...any) -> ...any) -> Connection,
	Disconnect: (self: Connection) -> (),
}
type Connection = typeof(setmetatable({} :: {}, {} :: ConnectionImpl))

local baseConnection: ConnectionImpl = {} :: ConnectionImpl
baseConnection.__index = baseConnection

function baseConnection.new(callback)
	local connection = setmetatable({ callback = callback }, baseConnection)
	return connection
end
function baseConnection:Disconnect()
	self.callback = nil
	self = nil
end

type EventImpl = {
	__index: EventImpl,
	new: () -> Event,
	Connect: (self: Event, callback: (...any) -> ...any) -> Connection,
	Fire: (self: Event, ...any) -> (),
}
type Event = typeof(setmetatable({} :: {}, {} :: EventImpl))

local baseEvent: EventImpl = {} :: EventImpl
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
function baseEvent:Fire(...)
	for _, connection in self.connections do
		connection.callback(...)
	end
end

return baseEvent
