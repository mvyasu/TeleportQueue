local Components = script.Parent.Components

for _,descendant in Components:GetDescendants() do
	if descendant:IsA("ModuleScript") and descendant.Name:find("Component") then
		require(descendant)
	end
end

do -- creates an example TeleportQueueComponent
	local part = Instance.new("Part")
	part.BrickColor = BrickColor.new("Black")
	part.CFrame = CFrame.new(0, 6, 13)
	part.Size = Vector3.new(12, 12, 2)
	part.Anchored = true
	part.CastShadow = false
	part.Parent = workspace

	part:SetAttribute("PlaceId", game.PlaceId)
	part:SetAttribute("ShouldReserveServer", true)

	game:GetService("CollectionService"):AddTag(part, "TeleportQueueComponent")
end