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
							GetTeleportData = function(self)
								return {
									ServerOwner = 1
								}
							end,
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
				
				--[[
				it("should update the TeleportQueued attribute for all players in the queue", function()
					local player = createPlayer()
					teleportQueue:Add(player)
					
					local newId = game:GetService("HttpService"):GenerateGUID()
					teleportQueue:SetOption("Id", newId)
					
					expect(player:GetAttribute("TeleportQueued")).to.equal(newId)
				end)
				]]
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