local Packages = game.ReplicatedStorage:WaitForChild("Packages")
local TeleportQueue = require(Packages.TeleportQueue)
local Component = require(Packages.Component)

local QueueSurfaceGui = require(script.QueueSurfaceGui)

local TELEPORT_QUEUE_SYMBOL = newproxy()
local TOUCH_CONNECTION_SYMBOL = newproxy()
local TIMER_LOOP_THREAD = newproxy()

local COUNT_DOWN_TIME = 20

local TeleportQueueComponent = Component.new({
	Tag = "TeleportQueueComponent"
})

function TeleportQueueComponent:Construct()
	local queueTeleportOptions = Instance.new("TeleportOptions")
	queueTeleportOptions.ShouldReserveServer = self.Instance:GetAttribute("ShouldReserveServer")

	self[TELEPORT_QUEUE_SYMBOL] = TeleportQueue.new({
		Id = tostring(newproxy()),
		PlaceId = self.Instance:GetAttribute("PlaceId"),
		TeleportOptions = queueTeleportOptions
	})

	local newSurfaceGuiInstances = QueueSurfaceGui()
	self.SurfaceGui = newSurfaceGuiInstances.SurfaceGui
	self.SubtitleLabel = newSurfaceGuiInstances.SubtitleLabel
	self.PlayersLabel = newSurfaceGuiInstances.PlayersLabel
	self.TimerLabel = newSurfaceGuiInstances.TimerLabel

	self.SurfaceGui.Parent = self.Instance
end

function TeleportQueueComponent:UpdateSurfaceGui()
	self.PlayersLabel.Text = #self[TELEPORT_QUEUE_SYMBOL]:GetPlayers()
	self.SubtitleLabel.Text = self.Status
	self.TimerLabel.Text = self.Timer
end

function TeleportQueueComponent:Start()
	do --handles the component's loop
		self[TIMER_LOOP_THREAD] = task.spawn(function()
			while true do
				self.Status = "Ready"
				self.Timer = COUNT_DOWN_TIME
				self:UpdateSurfaceGui()

				for timeLeft = COUNT_DOWN_TIME,0,-1 do
					task.wait(1)
					self.Timer = timeLeft
					self:UpdateSurfaceGui()
				end
				
				self.Status = "Teleporting"
				self:UpdateSurfaceGui()

				self[TELEPORT_QUEUE_SYMBOL]:Flush()
				self:UpdateSurfaceGui()

				task.wait(4)
			end
		end)
	end
	do --handles queue updates
		self[TELEPORT_QUEUE_SYMBOL]:Observe(function()
			self:UpdateSurfaceGui()
		end)
	
		self[TOUCH_CONNECTION_SYMBOL] = self.Instance.Touched:Connect(function(hit)
			local player = game.Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				self[TELEPORT_QUEUE_SYMBOL]:Add(player)
			end
		end)
	end
end

function TeleportQueueComponent:Stop()
	self[TELEPORT_QUEUE_SYMBOL]:Destroy()
	if self[TOUCH_CONNECTION_SYMBOL] then
		self[TOUCH_CONNECTION_SYMBOL]:Disconnect()
		self[TOUCH_CONNECTION_SYMBOL] = nil
	end
	if self[TIMER_LOOP_THREAD] then
		task.cancel(self[TIMER_LOOP_THREAD])
		self[TIMER_LOOP_THREAD] = nil
	end
	self.SurfaceGui:Destroy()
end

return TeleportQueueComponent