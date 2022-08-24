[![GitHub Issues](https://img.shields.io/github/issues/mvyasu/TeleportQueue.svg)](https://github.com/mvyasu/TeleportQueue/issues)
[![GitHub Stars](https://img.shields.io/github/stars/mvyasu/TeleportQueue.svg)](https://github.com/mvyasu/TeleportQueue/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# TeleportQueue

TeleportQueue is a simple module that allows Roblox developers to quickly setup a teleport queue alongside options with ease. In other words, it's a headstart for creating a system that involves teleporting a group of players to a specific place. The current release can be found and downloaded [here](https://github.com/mvyasu/TeleportQueue/releases).

You can read the [documentation](https://mvyasu.github.io/TeleportQueue/api) for more info.
 
## Basic Usage

To begin using this resource, you'll want to first construct a new TeleportQueue:

```lua
local TeleportQueue = require(game:GetService("ReplicatedStorage").Packages.TeleportQueue)

local newTeleportQueue = TeleportQueue.new({
	PlaceId = 606849621, -- Jailbreak's PlaceId
	Id = game:GetService("HttpService"):GenerateGUID(), -- How we identify the queue
})
```
There are [more options](https://mvyasu.github.io/TeleportQueue/api/TeleportQueue#QueueOptions) that you can pass besides `PlaceId` and `Id`, but these are the most important options in my opinion besides `TeleportOptions`. Now that you have created a new queue, you can add players to it like so:

```lua
local addResult = newTeleportQueue:Add(player)
if addResult == TeleportQueue.AddResult.Success then
	print("Added the player to the queue!")
end
```
The TeleportQueue will automatically remove the added player from the queue if they leave the game. However, if you ever need to remove a player from the queue, all you need to do is:

```lua
newTeleportQueue:Remove(player)
```
Once you're done with adding and removing players from the queue and are ready to teleport them:

```lua
local flushResult, teleportResult = newTeleportQueue:Flush()
if flushResult == TeleportQueue.FlushResult.Success then
	print("Here's the TeleportAsyncResult:", teleportResult)
end
```
If the flush was successful, the players should teleport out of the server, causing them to be removed from the queue, but potentially not immediately. This means if something goes wrong and they didn't teleport for some reason, they will still be left inside the queue. If you don't want to keep them inside the queue, you can call this:

```lua
newTeleportQueue:RemoveAll()
```
Once you're done with the TeleportQueue, you'll need to destroy it. If you don't, you could potentially run into a memory leak since you aren't disconnecting the connections that it uses to automatically remove players from the queue. To destroy a queue when you're done, all you need to do is:

```lua
newTeleportQueue:Destroy()
```
After this is called, calling certain methods for the TeleportQueue will no longer do anything.

## Advanced Example

With everything explained above, below is an example of how you could use the module in a more advanced way. What makes the TeleportQueue below special is that it's adding a tag and giving an attribute to players in the queue. With those, it can be determined who is in the same queue as other people.

In other words, you can use that info for components on the client and show who is in what queue.

 ```lua
local TeleportQueue = require(game:GetService("ReplicatedStorage").Packages.TeleportQueue)

local function createTagTeleportQueue()
	local TELEPORT_QUEUE_TAG = "TeleportQueuePlayer"
	local TELEPORT_QUEUE_ATTRIBUTE = "TeleportQueue"
	
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
			
			local hasTag = CollectionService:HasTag(player, TELEPORT_QUEUE_TAG)
			local hasQueueId = currentQueueId~=nil and currentQueueId~=self:GetOption("Id")
			
			local isWithinDifferentQueue = hasTag and hasQueueId
			return not isWithinDifferentQueue, "Player is already within a different queue"
		end,
	})
end

do
	local jailbreakQueue = createTagTeleportQueue()
	jailbreakQueue:SetOptions({
		PlaceId = 606849621,
	})

	local function onPlayerAdded(player)
		jailbreakQueue:Add(player)
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
