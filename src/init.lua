-- TeleportQueue
-- Yasu Yoshida
-- July 28, 2022

local OPTIONS_SYMBOL = newproxy()
local PLAYERS_SYMBOL = newproxy()
local CLOSING_SYMBOL = newproxy()
local PROCESS_SYMBOL = newproxy()
local CLEANUP_SYMBOL = newproxy()

local FORCE_REMOVE_ALL_AFTER = 60

local DEFAULT_QUEUE_OPTIONS = {
	TeleportOptions = Instance.new("TeleportOptions"),
	MaxPlayers = 50,
	PlaceId = 0,
	Id = "Default",

	GetTeleportData = function() return {} end,
	AllowedWithinQueue = function() return true end,
	OnOptionUpdated = {
		MaxPlayers = function(self, newMaxPlayers: number)
			if #self:GetPlayers()>newMaxPlayers then
				self:RemoveAll()
			end
		end,
		AllowedWithinQueue = function(self, newAllowedWithinQueueFn)
			local playersWithinQueueAtStart = self:GetPlayers()
			for _,player in playersWithinQueueAtStart do
				if not newAllowedWithinQueueFn(self, player) then
					self:Remove(player)
				end
			end
		end,
	},
}

export type FlushResult = string
local FlushResult = {
	QueueDestroyed = "TeleportQueue has been destroyed",
	QueueEmpty = "TeleportQueue is empty",

	Failure = "Failed flushing for an unknown reason",
	Success = "Successfully flushed",
}

export type AddResult = string
local AddResult = {
	QueueDestroyed = "TeleportQueue has been destroyed",
	QueueProcessing = "TeleportQueue is processing",
	QueueFull = "TeleportQueue is full",

	NotAllowed = "The player is not allowed within the TeleportQueue",
	PlayerBusy = "The player is already within the TeleportQueue",
	PlayerLeft = "The player has left the game",
	Success = "Successfully added",
}

export type TeleportQueue = {
	GetPlayers: () -> {Player},
	SetOptions: (teleportQueueOptions: QueueOptions, shouldReconcile: boolean) -> nil,
	SetOption: (optionName: string, newValue: any) -> boolean,
	GetOptions: () -> QueueOptions,
	GetOption: (optionName: string) -> any?,
	Add: (Player) -> (boolean, string?),
	Remove: (Player) -> boolean,
	RemoveAll: () -> {[Player]: boolean},
	Flush: () -> (boolean, string?),
}

export type QueueOptions = {
	AllowedWithinQueue: ((TeleportQueue, Player) -> (boolean, string?))?,
	OnPlayerRemoved: ((TeleportQueue, Player) -> nil)?,
	OnPlayerAdded: ((TeleportQueue, Player) -> nil)?,
	OnOptionUpdated: {(TeleportQueue, any) -> nil}?,

	PlaceId: number,
	Id: string | number,
	MaxPlayers: number?,
	TeleportOptions: TeleportOptions?,
}

--[=[
	@interface AddResult
	@tag enum
	@within TeleportQueue
	.QueueDestroyed "TeleportQueue has been destroyed" --TeleportQueue:Destroy() has been called
	.QueueProcessing "TeleportQueue is processing" --The Queue is in the middle of a :Fush()
	.QueueFull "TeleportQueue is full" --The MaxPlayers option has been reached
	.NotAllowed "The player is not allowed within the TeleportQueue" --AllowedWithinQueue doesn't allow the player inside the queue
	.PlayerBusy "The player is already within the TeleportQueue" --The player is already within TeleportQueue
	.PlayerLeft "The player has left the game" --The player isn't a child of game.Players
	.Success = "Successfully added" --Was able to add the player to the TeleportQueue

	A string enum value used to describe the result of using `TeleportQueue:Add()`.
]=]

--[=[
	@interface FlushResult
	@tag enum
	@within TeleportQueue
	.QueueDestroyed "TeleportQueue has been destroyed" --TeleportQueue:Destroy() has been called
	.QueueEmpty = "TeleportQueue is empty" --TeleportQueue:GetPlayers() is empty
	.Failure = "Failed flushing for an unknown reason" --Something went wrong within the pcall for TeleportAsync
	.Success = "Successfully added" --Nothing went wrong within the pcall for TeleportAsync and all requirements were met
	
	A string enum value used to describe the result of using `TeleportQueue:Flush()`.
]=]

--[=[
	@prop FlushResult FlushResult
	@within TeleportQueue
	@readonly
	@tag enums
	A table containing all members of the `FlushResult` string enum.
]=]

--[=[
	@prop AddResult AddResult
	@within TeleportQueue
	@readonly
	@tag enums
	A table containing all members of the `AddResult` string enum.
]=]

--[=[
	@class TeleportQueue
	@__index prototype

	A TeleportQueue is an object that handles a list of a players that can be teleported to a specified
	PlaceId with specific TeleportOptions with ease.
]=]

local TeleportQueue = {
	FlushResult = table.freeze(FlushResult),
	AddResult = table.freeze(AddResult),
}

TeleportQueue.prototype = {}
TeleportQueue.__index = TeleportQueue.prototype

--[=[
	@param startOptions QueueOptions?
	@return TeleportQueue
	
	Constructs a TeleportQueue object
	
	:::caution
	You don't need to give any QueueOptions when creating a new TeleportQueue, but
	you should be wary of the fact that not setting an Id or PlaceId can cause unwanted results!
]=]

function TeleportQueue.new(startOptions: QueueOptions): TeleportQueue
	local self = setmetatable({}, TeleportQueue)
	self[PROCESS_SYMBOL] = false
	self[CLOSING_SYMBOL] = false
	self[PLAYERS_SYMBOL] = {}
	self[OPTIONS_SYMBOL] = {}

	self:SetOptions(startOptions, true)

	self[CLEANUP_SYMBOL] = {
		game:GetService("Players").PlayerRemoving:Connect(function(player)
			self:Remove(player)
		end),
		game:GetService("Players").ChildRemoved:Connect(function(player)
			self:Remove(player)
		end)
	}

	return self
end

--[=[
	@return {Player}

	Returns an array of players that are in the queue
]=]

function TeleportQueue.prototype:GetPlayers()
	return table.clone(self[PLAYERS_SYMBOL])
end

--[=[
	@param optionName string
	@param newvalue any
	@return boolean --whether it successfully set the option

	Sets an option to a new value. If there's a function in OnOptionUpdated
	for the option that is changing, it will run that function as well.
]=]

function TeleportQueue.prototype:SetOption(optionName: string, newValue: any): boolean
	if self[CLOSING_SYMBOL] then
		return false
	end
	if self[OPTIONS_SYMBOL][optionName]~=newValue then
		self[OPTIONS_SYMBOL][optionName] = newValue

		local OnOptionUpdated = self:GetOption("OnOptionUpdated")
		local onOptionUpdatedFn = if OnOptionUpdated then OnOptionUpdated[optionName] else nil
		if onOptionUpdatedFn then
			onOptionUpdatedFn(self, newValue)
		end
	end
	return true
end

--[=[
	@param optionName string
	@return any? --The value of the option
]=]

function TeleportQueue.prototype:GetOption(optionName: string): any?
	return self[OPTIONS_SYMBOL][optionName]
end

--[=[
	@return QueueOptions --the current QueueOptions that has been shallow copied with table.clone()
]=]

function TeleportQueue.prototype:GetOptions(): QueueOptions
	return table.clone(self[OPTIONS_SYMBOL])
end

--[=[
	@param newTeleportQueueOptions QueueOptions
	@param shouldReconcile boolean? --if set to true, then the passed option dictionary will be reconciled with the defaults
	@return QueueOptions --the current QueueOptions that has been shallow copied with table.clone()
	
	This can be used to set multiple options at once instead of only one at a time with `:SetOption()`.
	You shouldn't ever need to use the shouldReconcile parameter since it's only used when the TeleportQueue is constructed.
]=]

function TeleportQueue.prototype:SetOptions(newTeleportQueueOptions: QueueOptions, shouldReconcile: boolean?): nil
	if self[CLOSING_SYMBOL] then
		return nil
	end
	local function reconcileDeep(src, template): {[any]: any}
		local tbl = table.clone(src)
		for k,v in template do
			local sv = src[k]
			if sv==nil then
				tbl[k] = if typeof(v)=="table" then table.clone(v) else v
			elseif typeof(sv)=="table" then
				if typeof(v)=="table" then
					tbl[k] = reconcileDeep(tbl[k], v)
				else
					tbl[k] = table.clone(sv)
				end
			end
		end
		return tbl
	end
	local newOptions = newTeleportQueueOptions or {}
	for k,v in pairs(if shouldReconcile then reconcileDeep(newOptions, DEFAULT_QUEUE_OPTIONS) else newOptions) do
		self:SetOption(k, v)
	end
	return nil
end

--[=[
	@param player Player
	@return boolean --whether it had to remove the player from the queue or not
	
	Removes the provided player from the queue if they are within the queue.
	If they are not within the queue, it'll do nothing.
]=]

function TeleportQueue.prototype:Remove(player: Player): boolean
	local playerIndex = table.find(self[PLAYERS_SYMBOL] or {}, player)
	if playerIndex then
		table.remove(self[PLAYERS_SYMBOL], playerIndex)

		local onPlayerRemovedFn = self:GetOption("OnPlayerRemoved")
		if onPlayerRemovedFn then
			onPlayerRemovedFn(self, player)
		end

		return true
	end
	return false
end

--[=[
	@return {[Player]: boolean} --a lookup dictionary for whether it had to remove the player from the queue or not
	
	Removes all the players from the queue in a while loop.
]=]

function TeleportQueue.prototype:RemoveAll(): {[Player]: boolean}
	local removalResults = {}
	while #self[PLAYERS_SYMBOL]>0 do
		local index, player = next(self[PLAYERS_SYMBOL])
		local success, result = pcall(self.Remove, self, player)

		if not success then
			warn(("[TeleportQueue]: Failed to remove player from teleport queue! %s"):format(result))
		end

		removalResults[player] = success and result
	end
	return removalResults
end

--[=[
	@return (AddResult, string?) --what happened when trying to add the player
	
	If the AddResult returned is `AddResult.NotAllowed`, then it will return a second value
	and that second value is the reasoning from the AllowedWithinQueue option function
]=]

function TeleportQueue.prototype:Add(player: Player): (AddResult, string?)
	do
		if self[CLOSING_SYMBOL] then
			return AddResult.QueueDestroyed
		end

		local hasPlayerLeft = not player:IsDescendantOf(game:GetService("Players"))
		if hasPlayerLeft then
			return AddResult.PlayerLeft
		end

		local isQueueFull = #self:GetPlayers()>=self:GetOption("MaxPlayers")
		if isQueueFull then
			return AddResult.QueueFull
		end

		local isProcessingTeleport = self[PROCESS_SYMBOL]
		if isProcessingTeleport then
			return AddResult.QueueProcessing
		end

		local isWithinCurrentQueue = table.find(self:GetPlayers(), player)~=nil
		if isWithinCurrentQueue then
			return AddResult.PlayerBusy
		end

		local isAllowedWithinQueue, reasoning = self:GetOption("AllowedWithinQueue")(self, player)
		if not isAllowedWithinQueue then
			return AddResult.NotAllowed, reasoning
		end
	end

	local onPlayerAddedFn = self:GetOption("OnPlayerAdded")
	if onPlayerAddedFn then
		onPlayerAddedFn(self, player)
	end

	table.insert(self[PLAYERS_SYMBOL], player)

	return AddResult.Success
end

--[=[
	@return (FlushResult, (TeleportAsyncResult | string)?) --what happened when trying to flush the TeleportQueue
	
	If FlushResult is `FlushResult.Success` or `FlushResult.Failure`, it will return a second value. If it was a success,
	then that second value is a `TeleportAsyncResult`. If it was not, then it's a `string` describing what went wrong.
]=]

function TeleportQueue.prototype:Flush(): (FlushResult, (TeleportAsyncResult | string)?)
	local playersWithinQueue = self:GetPlayers()
	do --ensures flush can be done at the moment
		if self[CLOSING_SYMBOL] then
			return FlushResult.QueueDestroyed
		elseif #playersWithinQueue<1 then
			return FlushResult.QueueEmpty
		end
	end

	self[PROCESS_SYMBOL] = true

	local wasSuccessful, teleportResult = pcall(function()
		local actualPlayersTeleporting = table.clone(playersWithinQueue)
		do --necessary to prevent warnings with init.spec
			for i = #actualPlayersTeleporting, 1, -1 do
				if not actualPlayersTeleporting[i]:IsA("Player") then
					table.remove(actualPlayersTeleporting, i)
				end
			end
			if #actualPlayersTeleporting<=0 then
				return {}
			end
		end
		local queuePlaceId = self:GetOption("PlaceId")
		local teleportOptions = self:GetOption("TeleportOptions") or Instance.new("TeleportOptions")
		return game:GetService("TeleportService"):TeleportAsync(queuePlaceId, actualPlayersTeleporting, teleportOptions)
	end)

	self[PROCESS_SYMBOL] = false

	if not wasSuccessful then
		warn("[TeleportQueue]: Failed to flush queue! "..teleportResult)
	end

	return if wasSuccessful then FlushResult.Success else FlushResult.Failure, teleportResult
end

--[=[
	@yields
	
	Cleans up any connections that TeleportQueue and locks `:Add()`, `:Flush()`, `:SetOption()`, `:SetOptions()`.
	It will yield until `:Flush()` is done processing. If it has been yielding for over FORCE_REMOVE_ALL_AFTER, then
	it will automatically stop yielding. 
	
	Once it is done yielding, it runs `:RemoveAll()`. It doesn't not yield at all if `:Flush()` is not being processed.
]=]

function TeleportQueue.prototype:Destroy()
	self[CLOSING_SYMBOL] = true

	for _,object in self[CLEANUP_SYMBOL] do
		local success, result = pcall(function()
			local t = typeof(object)
			if t == "RBXScriptConnection" then
				object:Disconnect()
			end
		end)
		if not success then
			warn(("[TeleportQueue]: Something went wrong when attempting to cleanup a '%s'! %s"):format(typeof(object), result))
		end
	end
	table.clear(self[CLEANUP_SYMBOL])

	do --waits until the processing is complete and removes everyone from queue
		local waitStartTimestamp = tick() 
		if self[PROCESS_SYMBOL] then
			repeat task.wait() until not self[PROCESS_SYMBOL] or tick()-waitStartTimestamp>FORCE_REMOVE_ALL_AFTER
		end
		self:RemoveAll()
	end
end

return TeleportQueue