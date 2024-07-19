local LogHandler = {}

function LogHandler.DebugPrint(...: any)
	if _G.DEBUG then
        print(...)
	end
end

return LogHandler