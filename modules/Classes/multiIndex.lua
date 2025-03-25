return function(...: { [any]: any } | (any, any) -> any): (any, any) -> any
	local indexables = { ... }
	return function(object: any, index: any): any
		for _, indexable in ipairs(indexables) do
			local v: any
			if type(indexable) == "function" then
				v = indexable(object, index)
			else
				v = indexable[index]
			end
			if v then return v end
		end
		return nil
	end
end
