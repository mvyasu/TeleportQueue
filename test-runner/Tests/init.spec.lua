return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TeleportQueue = require(ReplicatedStorage:FindFirstChild("TeleportQueue", true))

	describe("TeleportQueue", function()
		local teleportQueue
		local players = {}
		
		local function createPlayer(notParented: boolean?): Folder
			local newPlayer = Instance.new("Folder", if notParented then nil else game.Players)
			table.insert(players, newPlayer)
			return newPlayer
		end

		beforeEach(function()
			teleportQueue = TeleportQueue.new({
				PlaceId = 606849621,
				Id = game:GetService("HttpService"):GenerateGUID(),
			})
		end)

		afterEach(function()
			if teleportQueue then
				teleportQueue:Destroy()
				teleportQueue = nil
			end
			if players then
				for _,player in pairs(players) do
					player:Destroy()
				end
				table.clear(players)
			end
		end)

		describe("Listeners", function()
			describe(".Changed", function()
				local timesFired = 0
				beforeEach(function()
					timesFired = 0
					teleportQueue.Changed.Event:Connect(function(kind)
						timesFired += 1
					end)
				end)

				it("should only fire once after :Add()", function()
					teleportQueue:Add(createPlayer())
					task.wait()
					expect(timesFired).to.equal(1)
				end)
				it("should only fire once after :SetOption(), :SetOptions(), :Add(), or :Remove()", function()
					local examplePlayer = createPlayer()
					teleportQueue:Add(examplePlayer)
					teleportQueue:Remove(examplePlayer)
					teleportQueue:SetOption("MaxPlayers", 5)
					teleportQueue:SetOptions({
						TeleportOptions = Instance.new("TeleportOptions"),
						MaxPlayers = 8,
					})
					task.wait()
					expect(timesFired).to.equal(4)
				end)
				it("should only fire once when using :RemoveAll()", function()
					teleportQueue:Add(createPlayer())
					teleportQueue:Add(createPlayer())
					teleportQueue:Add(createPlayer())
					teleportQueue:RemoveAll()
					task.wait()
					expect(timesFired).to.equal(4)
				end)
				it("should not fire when using :RemoveAll() if the queue is empty", function()
					teleportQueue:RemoveAll()
					task.wait()
					expect(timesFired).to.equal(0)
				end)
				it("should pass along the kind 'PlayersAdded' and an array of players added when using :Add()", function()
					local args = {}
					teleportQueue.Changed.Event:Once(function(...)
						args = {...}
					end)
					teleportQueue:Add(createPlayer())
					task.wait()
					expect(args[1]).to.equal(TeleportQueue.UpdateKind.PlayersAdded)
					expect(typeof(args[2])).to.equal("table")
					expect(args[2][1]:IsA("Folder")).to.equal(true)
				end)
				it("should pass along the kind 'PlayersRemoved' and an array of players removed when using :Remove() and :RemoveAll()", function()
					for _,removeMethod in {"Remove", "RemoveAll"} do
						local player = createPlayer()
						teleportQueue:Add(player)

						local args = {}
						teleportQueue.Changed.Event:Once(function(...)
							args = {...}
						end)
						teleportQueue[removeMethod](teleportQueue, player)
						task.wait()
						expect(args[1]).to.equal(TeleportQueue.UpdateKind.PlayersRemoved)
						expect(typeof(args[2])).to.equal("table")
						expect(args[2][1]:IsA("Folder")).to.equal(true)
					end
				end)
			end)
			
			describe(":Observe()", function()
				it("should return an RBXScriptConnection", function()
					local observeType = typeof(teleportQueue:Observe(function() end))
					expect(observeType).to.equal("RBXScriptConnection")
				end)
				it("should expect the update kind to be 'Initializing' as the first kind of update", function()
					local lastUpdateKind
					teleportQueue:Observe(function(updateKind: TeleportQueue.UpdateKind)
						lastUpdateKind = updateKind
					end)
					task.wait()
					expect(lastUpdateKind).to.equal(TeleportQueue.UpdateKind.Initializing)
				end)
			end)
		end)
		
		describe("Options", function()
			describe(":GetOptions()", function()
				it("should reconcile options with the default template", function()
					local totalOptions = 0
					for _,v in teleportQueue:GetOptions() do
						totalOptions += 1
					end
					expect(totalOptions>=6).to.equal(true)
				end)
			end)

			describe(":SetOptions()", function()
				it("should allow the options to be changed", function()
					expect(function()
						teleportQueue:SetOptions({
							OnOptionUpdated = {
								PlaceId = function() end,
							},
							MaxPlayer = 1,
						})
					end).never.to.throw()
				end)
				
				it("allow no arguements to be passed", function()					
					expect(function()
						teleportQueue:SetOptions()
					end).never.to.throw()
				end)
			end)

			describe(":GetOption()", function()
				it("should be able to retrieve an option", function()
					expect(teleportQueue:GetOption("PlaceId")).to.equal(606849621)
				end)
			end)

			describe(":SetOption()", function()
				it("should be able to change a signular option", function()
					expect(teleportQueue:SetOption("PlaceId", 100)).to.equal(true)
				end)
				
				it("should not change an option once the queue is destroyed", function()
					teleportQueue:Destroy()
					expect(teleportQueue:SetOption("PlaceId", 50)).to.equal(false)
				end)
				
				it("should use :RemoveAll() if MaxPlayers is less than the amount of players in the queue", function()
					for i = 1,2 do
						teleportQueue:Add(createPlayer())
					end
					teleportQueue:SetOption("MaxPlayers", 1)
					expect(#teleportQueue:GetPlayers()).to.equal(0)
				end)

				it("should remove players from the queue if they no longer pass AllowedWithinQueue", function()
					local leavePlayerAlone = createPlayer()
					teleportQueue:Add(leavePlayerAlone)
					teleportQueue:Add(createPlayer())
					teleportQueue:SetOption("AllowedWithinQueue", function(self, player)
						return leavePlayerAlone==player, "Not allowed anymore"
					end)
					expect(#teleportQueue:GetPlayers()).to.equal(1)
				end)
			end)
		end)
		
		describe("Queue", function()
			describe(":Add()", function()
				it("should not add a player that isn't parented to Players", function()
					expect(
						teleportQueue:Add(createPlayer(true))	
					).to.equal(TeleportQueue.AddResult.PlayerLeft)
				end)

				it("should not add a player that is already within a queue", function()
					local player = createPlayer()
					teleportQueue:Add(player)

					expect(teleportQueue:Add(player)).to.equal(TeleportQueue.AddResult.PlayerBusy)
				end)

				it("should add a player parented to Players", function()
					expect(
						teleportQueue:Add(createPlayer())
					).to.equal(TeleportQueue.AddResult.Success)
				end)

				it("should not allow someone to be added if MaxPlayers is reached", function()
					local hasFailed = false
					for i = 1,100 do
						if teleportQueue:Add(createPlayer())~=TeleportQueue.AddResult.Success then
							hasFailed = true
							break
						end
					end
					expect(hasFailed).to.equal(true)
				end)
			end)
			
			describe(":Remove()", function()
				it("should remove a player from the queue array", function()
					local player = createPlayer()
					teleportQueue:Add(player)
					teleportQueue:Remove(player)
					expect(table.find(teleportQueue:GetPlayers(), player)).to.equal(nil)
				end)
				
				it("should be ran when a player leaves the game", function()
					local player = createPlayer()
					teleportQueue:Add(player)
					player:Destroy()
					task.wait()
					expect(table.find(teleportQueue:GetPlayers(), player)).to.equal(nil)
				end)
			end)

			describe(":Flush()", function()
				it("should not try teleporting the queue if it's empty", function()
					expect(teleportQueue:Flush()).to.equal(TeleportQueue.FlushResult.QueueEmpty)
				end)

				it("should not try teleporting the queue if the queue is destroyed", function()
					teleportQueue:Destroy()
					expect(teleportQueue:Flush()).to.equal(TeleportQueue.FlushResult.QueueDestroyed)
				end)
				
				it("should try teleporting everyone in the queue", function()
					for i = 1,10 do
						teleportQueue:Add(createPlayer())
					end
					local flushResult, teleportResult = teleportQueue:Flush()
					expect(flushResult==TeleportQueue.FlushResult.Success).to.equal(true)
				end)
			end)
		end)
		
	end)
end