local Remotes = require(script.Parent.Remotes)
local t = require(script.Parent.t)

local Constants = require(script.Constants)

local ClientRequest = {}
ClientRequest.__index = ClientRequest

function ClientRequest.new(remoteName)
	assert(t.string(remoteName))
	local self = setmetatable({
		requestTimeout = Constants.DEFAULT_REQUEST_TIMEOUT;
		defaultResponse = nil;

		_remoteInstance = Remotes:getEventAsync(remoteName);
	}, ClientRequest)

	return self
end

function ClientRequest:request(player, ...)
	local responseReceived = false
	local result
	local startTimestamp = tick()
	local connection = self._remoteInstance.OnServerEvent:Once(function(...)
		result = {...}
		responseReceived = true
	end)
	self._remoteInstance:FireClient(player, ...)

	while (not responseReceived) and (tick() - startTimestamp < self.requestTimeout) do
		task.wait()
	end

	if responseReceived then
		return unpack(result)
	else
		connection:Disconnect()
		return self.defaultResponse
	end
end

return ClientRequest