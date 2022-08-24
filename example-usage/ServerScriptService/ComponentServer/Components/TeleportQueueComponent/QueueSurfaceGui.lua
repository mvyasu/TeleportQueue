return function()
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "SurfaceGui"
	surfaceGui.Brightness = 2
	surfaceGui.ClipsDescendants = true
	surfaceGui.PixelsPerStud = 30
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 200)
	frame.SizeConstraint = Enum.SizeConstraint.RelativeXX

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = frame

	local players = Instance.new("Frame")
	players.Name = "Players"
	players.BackgroundColor3 = Color3.fromRGB(230, 255, 0)
	players.BackgroundTransparency = 1
	players.BorderSizePixel = 0
	players.Size = UDim2.fromScale(1, 1)
	players.SizeConstraint = Enum.SizeConstraint.RelativeYY

	local uIListLayout1 = Instance.new("UIListLayout")
	uIListLayout1.Name = "UIListLayout"
	uIListLayout1.Padding = UDim.new(0, 20)
	uIListLayout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout1.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout1.Parent = players

	local number = Instance.new("TextLabel")
	number.Name = "Number"
	number.Font = Enum.Font.LuckiestGuy
	number.Text = "0"
	number.TextColor3 = Color3.fromRGB(255, 255, 255)
	number.TextSize = 86
	number.TextWrapped = true
	number.AutomaticSize = Enum.AutomaticSize.Y
	number.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	number.BackgroundTransparency = 1
	number.Size = UDim2.fromScale(1, 0.25)

	local uIStroke = Instance.new("UIStroke")
	uIStroke.Name = "UIStroke"
	uIStroke.Thickness = 10
	uIStroke.Parent = number

	number.Parent = players

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Font = Enum.Font.LuckiestGuy
	title.Text = "PLAYERS"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 30
	title.TextWrapped = true
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1
	title.LayoutOrder = -1
	title.Size = UDim2.fromScale(1, 0.25)

	local uIStroke1 = Instance.new("UIStroke")
	uIStroke1.Name = "UIStroke"
	uIStroke1.Thickness = 6
	uIStroke1.Parent = title

	title.Parent = players

	players.Parent = frame

	local timer = Instance.new("Frame")
	timer.Name = "Timer"
	timer.BackgroundColor3 = Color3.fromRGB(230, 255, 0)
	timer.BackgroundTransparency = 1
	timer.BorderSizePixel = 0
	timer.Size = UDim2.fromScale(1, 1)
	timer.SizeConstraint = Enum.SizeConstraint.RelativeYY

	local uIListLayout2 = Instance.new("UIListLayout")
	uIListLayout2.Name = "UIListLayout"
	uIListLayout2.Padding = UDim.new(0, 20)
	uIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout2.Parent = timer

	local number1 = Instance.new("TextLabel")
	number1.Name = "Number"
	number1.Font = Enum.Font.LuckiestGuy
	number1.Text = "20"
	number1.TextColor3 = Color3.fromRGB(255, 255, 255)
	number1.TextSize = 86
	number1.TextWrapped = true
	number1.AutomaticSize = Enum.AutomaticSize.Y
	number1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	number1.BackgroundTransparency = 1
	number1.Size = UDim2.fromScale(1, 0.25)

	local uIStroke2 = Instance.new("UIStroke")
	uIStroke2.Name = "UIStroke"
	uIStroke2.Thickness = 10
	uIStroke2.Parent = number1

	number1.Parent = timer

	local title1 = Instance.new("TextLabel")
	title1.Name = "Title"
	title1.Font = Enum.Font.LuckiestGuy
	title1.Text = "TIMER"
	title1.TextColor3 = Color3.fromRGB(255, 255, 255)
	title1.TextSize = 30
	title1.TextWrapped = true
	title1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title1.BackgroundTransparency = 1
	title1.LayoutOrder = -1
	title1.Size = UDim2.fromScale(1, 0.25)

	local uIStroke3 = Instance.new("UIStroke")
	uIStroke3.Name = "UIStroke"
	uIStroke3.Thickness = 6
	uIStroke3.Parent = title1

	title1.Parent = timer

	timer.Parent = frame

	frame.Parent = surfaceGui

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Font = Enum.Font.LuckiestGuy
	subtitle.RichText = true
	subtitle.Text = "READY"
	subtitle.TextColor3 = Color3.fromRGB(0, 255, 0)
	subtitle.TextSize = 60
	subtitle.TextWrapped = true
	subtitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	subtitle.BackgroundTransparency = 1
	subtitle.Size = UDim2.new(1, 0, 0, 40)
	subtitle.Parent = surfaceGui

	local uIListLayout3 = Instance.new("UIListLayout")
	uIListLayout3.Name = "UIListLayout"
	uIListLayout3.Padding = UDim.new(0, 25)
	uIListLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout3.Parent = surfaceGui

	return {
		SurfaceGui = surfaceGui,
		SubtitleLabel = subtitle,
		PlayersLabel = number,
		TimerLabel = number1,
	}
end