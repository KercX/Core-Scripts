-------ATTACHEL BY WERTYS
---- BY WERTYS


local BackpackScript = {}
local RunService = game:GetService('RunService')
local StarterGui = game:GetService('StarterGui')
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local VRService = game:GetService('VRService')
local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Utils = require(Modules.Utils)
local Janitor = require(Modules.Janitor)
local ToolData = require(Modules.ToolData)
local Player = Players.LocalPlayer

local BackpackGui = Player:WaitForChild("PlayerGui"):WaitForChild("BackpackGui")



local Slots = {}
local EquippedTool = nil
local CurrentSlot = nil
local CurrentSlotIndex = nil
local CurrentSlotTool = nil
local CurrentTool = nil
local CurrentToolData = nil
local CurrentToolIndex = nil
local CurrentToolType = nil



local function GetSlotFromTool(tool)
	for i = 1, #Slots do
		if Slots[i].Tool == tool then
			return Slots[i]
		end
	end
end

local function GetSlotFromIndex(index)
	return Slots[index]
end


local function GetSlots()
	return Slots
end

local Hotbars = {
	[1] = {
		Slots = {},
		CurrentSlot = nil,
		CurrentSlotIndex = nil,
		CurrentSlotTool = nil,
		CurrentTool = nil,
		CurrentToolData = nil,
		CurrentToolIndex = nil,
		CurrentToolType = nil,
	},
	[2] = {
		Slots = {},
		CurrentSlot = nil,
		CurrentSlotIndex = nil,
		CurrentSlotTool = nil,
		CurrentTool = nil,
		CurrentToolData = nil,
		CurrentToolIndex = nil,
		CurrentToolType = nil,
	},
	[3] = {
		Slots = {},
		CurrentSlot = nil,
		CurrentSlotIndex = nil,
		CurrentSlotTool = nil,
		CurrentTool = nil,
		CurrentToolData = nil,
		CurrentToolIndex = nil,
		CurrentToolType = nil,
	},
}

local function GetHotbarFromSlot(slot)
	for i = 1, #Hotbars do
		if Hotbars[i].Slots[slot] then
			return Hotbars[i]
		end
	end
end



local function GetHotbarFromTool(tool)
	for i = 1, #Hotbars do
		if Hotbars[i].CurrentTool == tool then
			return Hotbars[i]
		end
	end
end



local function GetHotbarFromIndex(index)
	return Hotbars[index]
end


local function GetHotbar(index)
	return Hotbars[index]
end


BackpackScript.OpenClose = nil :: any -- Function to toggle open/close
BackpackScript.IsOpen = false :: boolean
BackpackScript.StateChanged = Instance.new("BindableEvent") :: BindableEvent -- Fires after any open/close, passes IsNowOpen

BackpackScript.ModuleName = "Backpack" :: string
BackpackScript.KeepVRTopbarOpen = true :: boolean
BackpackScript.VRIsExclusive = true :: boolean
BackpackScript.VRClosesNonExclusive = true :: boolean

BackpackScript.BackpackEmpty = Instance.new("BindableEvent") :: BindableEvent -- Fires when the backpack is empty (no tools
BackpackScript.BackpackEmpty.Name = "BackpackEmpty"

BackpackScript.BackpackItemAdded = Instance.new("BindableEvent") :: BindableEvent -- Fires when an item is added to the backpack
BackpackScript.BackpackItemAdded.Name = "BackpackAdded"

BackpackScript.BackpackItemRemoved = Instance.new("BindableEvent") :: BindableEvent -- Fires when an item is removed from the backpack
BackpackScript.BackpackItemRemoved.Name = "BackpackRemoved"


---------TopbarMechanic

local BackpackEnabled: boolean = true

local Icon: any = require(script.Parent.topbarplus)

local inventoryIcon: any = Icon.new()
	:setName("Inventory")
	:setImage(ARROW_IMAGE_OPEN, "Selected")
	:setImage(ARROW_IMAGE_CLOSE, "Deselected")
	:setImageScale(1)
	:setCaption("Inventory")
	:bindToggleKey(Enum.KeyCode.Backquote)
	:autoDeselect(false)

inventoryIcon.toggled:Connect(function(): ()
	if not GuiService.MenuIsOpen then
		BackpackScript.OpenClose()
	end
end)



local SlotsNumber {
	[1] = 10,
	[2] = 10,
	[3] = 10,
	[4] = 10,
	[5] = 10,
}

local function GetSlots()
	NumberOfHotbarSlots = SlotsNumber[1]
	NumberOfInventorySlots = SlotsNumber[2]
end


local FAKE_INVENTORY_OPENED_ATTRIBUTE: string = "FAKE_INVENTORY_OPENED"
local function IsInventoryFake(): boolean
	return Players.LocalPlayer:GetAttribute(FAKE_INVENTORY_OPENED_ATTRIBUTE) == true
end

local function UpdateInventoryIcon()
	local inventoryIcon: any = Icon.getIcon("Inventory")
	if inventoryIcon then
		local backpackGui = BackpackScript.BackpackGui
		if backpackGui and backpackGui.Enabled then
			inventoryIcon:setImage(ARROW_IMAGE_OPEN, "Selected")
			inventoryIcon:setImage(ARROW_IMAGE_CLOSE, "Deselected")
		else
			inventoryIcon:setImage(ARROW_IMAGE_CLOSE, "Selected")
			inventoryIcon:setImage(ARROW_IMAGE_OPEN, "Deselected")
		end
	end
end





local Frame = script.Parent.BackpackGui.BackpackFrame
local function UpdateBackpackGuiEnabled(enabled: boolean, isFake: boolean?): ()
	local fakeInventoryOpen: boolean = isFake or IsInventoryFake()
	Frame.Visible = enabled
	UpdateInventoryIcon()
end

local function UpdateBackpackGuiVisibility(visible: boolean): ()
end

local TextBox = Frame:FindFirstChild("SearchBox") :: TextBox
local function UpdateSearchBox(): ()
	TextBox.Visible = not IsInventoryFake()
end

-----SETTINGS TEXTBOX

local SearchBox = Frame:FindFirstChild("SearchBox") :: TextBox
local function UpdateSearchBox(): ()
	
end


local function ChangeSlots(): ()
	GetSlots()
	BackpackScript.UpdateLayout()
	BackpackScript.UpdateScrollingFrameCanvasSize()
	BackpackScript.Update()
	UpdateSearchBox()
	UpdateSearchBox()
	UpdateBackpackGuiEnabled(BackpackScript.Isnotopen)
end


-----GUI TO BACKPACK ATTACHEL

local function GetBackpackGui(): ScreenGui
	if not BackpackScript.BackpackGui then
		BackpackScript.BackpackGui = BackpackScript.BackpackGui:Clone()
		BackpackScript.BackpackGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		UpdateBackpackGuiEnabled(BackpackScript.Isnotopen)
	end
	return BackpackScript.BackpackGui
end

local function GetBackpackFrame(): Frame
	return GetBackpackGui().BackpackFrame
end

------SETTING FRAME TO BACKPACK ATTACHEL

local function GetInventoryFrame(): Frame
	return GetBackpackFrame().Inventory
end



local Frame = script.Parent.BackpackGui.BackpackFrame
local function UpdateBackpackGuiEnabled(enabled: boolean, isFake: boolean?): ()
	local fakeInventoryOpen: boolean = isFake or IsInventoryFake()
	Frame.Visible = not enabled


end

local Frame = Instance.new("Frame")
Frame.Name = "BackpackFrame"
Frame.Parent = script.Parent.BackpackGui
Frame.Visible = false
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.BackgroundTransparency = 0.5
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
local function (openframe)
	openframe.Visible = true
	Keybinds:BindAction("Inventory", function()
		openframe.Visible = not openframe.Visible
		Enum.KeyCode.Backquote
		openframe.Visible = not openframe.Visible
	end)
end

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Parent = Frame
SearchBox.Size = UDim2.new(0.15, 0, 0.15, 0)
SearchBox.Position = UDim2.new(0.85, 0, 0.05, 0)
SearchBox.BackgroundTransparency = 0.5
SearchBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SearchBox.Text = "Search"
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextScaled = true
SearchBox.TextWrapped = true
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.TextYAlignment = Enum.TextYAlignment.Top
SearchBox.Font = Enum.Font.Montserrat

local function SeatchSearchBox(): ()
	SearchBox.Visible = true
	Keybinds:BindAction("Inventory", function()
		SearchBox.Visible = not SearchBox.Visible
		SearchBox.Visible = not SearchBox.Visible
	end)
end


local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Parent = Frame
ScrollingFrame.Size = UDim2.new(0.85, 0, 0.8, 0)
ScrollingFrame.Position = UDim2.new(0.15, 0, 0.1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 10
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.ScrollBarImageTransparency = 0.5
ScrollingFrame.ScrollBarThickness = 10


local function GetSlots(): Frame
	return ScrollingFrame
end


--------SETUP ALL

local function GetSlots(): Frame
	return ScrollingFrame
end


local function GetSlot(index: number): Frame
	return GetSlots():FindFirstChild("Slot" .. index)
	return GetSlots():FindFirstChild("Slot" .. index)
end

local function GetSlotItem(slot: Frame): Tool
	return slot:FindFirstChild("Tool")
end

----TOOL ROLE 

local function GetSlotItem(slot: Frame): Tool
	return slot:FindFirstChild("Tool")
end

local function GetSlotItem(slot: Frame): Tool
	return slot:FindFirstChild("Tool")
end

local function EquipSlot(slot: Frame): ()
	local tool: Tool = GetSlotItem(slot)
	if tool then
		tool.Parent = GetCharacter()
	end
end

local function HotbarSlotClicked(slot: Frame): ()
	if not slot then
		return
	end
	EquipSlot(slot)
end

local function BackpackSlotClicked(slot: Frame): ()
	if not slot then
		return
	end
	end
end
end


local function GetSlots(): Frame
	wait(4)
	return ScrollingFrame
end

local function GetSlot(index: number): Frame
	return GetSlots():FindFirstChild("Slot" .. index)
end	


end

return {
	["GetSlots"] = GetSlots,
	["GetSlot"] = GetSlot,
	["GetSlotItem"] = GetSlotItem,
	["EquipSlot"] = EquipSlot,
	["HotbarSlotClicked"] = HotbarSlotClicked,
	["BackpackSlotClicked"] = BackpackSlotClicked,
	
return Attachel
