# TeleportQueue
[![GitHub Issues](https://img.shields.io/github/issues/mvyasu/TeleportQueue.svg)](https://github.com/mvyasu/TeleportQueue/issues)
[![GitHub Stars](https://img.shields.io/github/stars/mvyasu/TeleportQueue.svg)](https://github.com/mvyasu/TeleportQueue/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

 A module that allows developers to quickly setup a teleport queue. Documentation is missing at the moment, but can be written if enough people desire it. Here's a small example of how it can be used:
 
 ```lua
local TELEPORT_QUEUE_TAG = "TeleportQueuePlayer"
local TELEPORT_QUEUE_ATTRIBUTE = "TeleportQueue"

local TeleportQueue = require(game.ReplicatedStorage.TeleportQueue)

local function createTagTeleportQueue()
	local CollectionService = game:GetService("CollectionService")
	return TeleportQueue.new({
		Id = game:GetService("HttpService"):GenerateGUID(),
		PlaceId = 0,
		
		OnOptionUpdated = {
			Id = function(self, newQueueId)
				for _,player in self:GetPlayers() do
					player:SetAttribute(TELEPORT_QUEUE_ATTRIBUTE, newQueueId)
				end
			end,
		},
		
		OnPlayerAdded = function(self, player)
			player:SetAttribute(TELEPORT_QUEUE_ATTRIBUTE, self:GetOption("Id"))
			CollectionService:AddTag(player, TELEPORT_QUEUE_TAG)
		end,
		
		OnPlayerRemoved = function(self, player)
			CollectionService:RemoveTag(player, TELEPORT_QUEUE_TAG)
			player:SetAttribute(TELEPORT_QUEUE_ATTRIBUTE, nil)
		end,
		
		AllowedWithinQueue = function(self, player)
			local currentQueueId = player:GetAttribute(TELEPORT_QUEUE_ATTRIBUTE) 
			local isWithinDifferentQueue = CollectionService:HasTag(player, TELEPORT_QUEUE_TAG) and (currentQueueId~=nil and currentQueueId~=self:GetOption("Id"))
			return not isWithinDifferentQueue, "Player is already within a different queue"
		end,
	})
end

do --an example queue
	local jailbreakQueue = createTagTeleportQueue()
	jailbreakQueue:SetOptions({
		PlaceId = 606849621,
	})

	local function onPlayerAdded(player)
		jailbreakQueue:Add(player)
		--if the player leaves, they will
		--automatically be removed from the queue
		--this includes when they teleport
	end

	local listenToPlayerAdded = game.Players.PlayerAdded:Connect(onPlayerAdded)
	for _,player in game:GetService("Players"):GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	
	task.delay(8, function()
		local flushResult, teleportResult = jailbreakQueue:Flush()
		if flushResult==TeleportQueue.FlushResult.Success then
			print("Successfully flushed the queue!")
			print("Here's the TeleportAsyncResult:", teleportResult)
			if listenToPlayerAdded then
				listenToPlayerAdded:Disconnect()
				listenToPlayerAdded = nil
			end
			jailbreakQueue:Destroy()
		else
			warn("Failed to flush the queue!")
			print("FlushResult:", flushResult)
			if flushResult==TeleportQueue.FlushResult.Failure then
				print("Error:", teleportResult)
			end
		end
	end)
end
```
