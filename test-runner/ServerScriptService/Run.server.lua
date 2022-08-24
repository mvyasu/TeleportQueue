local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestEZ = require(ReplicatedStorage.TestEZ)

local RUN_TESTS = true

-- run unit tests
if RUN_TESTS then
	print("Running unit tests...")
	local data = TestEZ.TestBootstrap:run({
		ReplicatedStorage.TeleportQueueTests
	})

	if data.failureCount > 0 then
		return
	end
end