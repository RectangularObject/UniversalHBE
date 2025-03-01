type ConnectionImpl = {
	__index: ConnectionImpl,

	callback: (...any) -> (),

	Disconnect: (self: Connection) -> (),
}
export type Connection = typeof(setmetatable({} :: ConnectionImpl, {} :: ConnectionImpl))

local EventConnection = {}
local Connection: ConnectionImpl = {} :: ConnectionImpl
Connection.__index = Connection

function EventConnection.new(callback: (...any) -> ()): Connection
	local self = setmetatable({}, Connection)
	self.callback = callback
	return self
end
function Connection:Disconnect()
	self.callback = nil
	self = nil
end

type EventImpl = {
	__index: EventImpl,

	connections: { Connection },

	Connect: (self: Event, callback: (...any) -> ...any) -> Connection,
	Fire: (self: Event, ...any) -> (),
}
export type Event = typeof(setmetatable({} :: EventImpl, {} :: EventImpl))

local module = {}
local Event: EventImpl = {} :: EventImpl
Event.__index = Event

function module.new(): Event
	local self = setmetatable({}, Event)
	self.connections = {}
	return self
end
function Event:Connect(callback)
	local connection = EventConnection.new(callback)
	table.insert(self.connections, connection)
	return connection
end
function Event:Fire(...)
	for _, connection in self.connections do
		connection.callback(...)
	end
end

return module
