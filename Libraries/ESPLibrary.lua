--------------------------------------------------------------
ValidTypes = {
    ["ESP"] = {Highlight = 1, Box = 2, None = 3},
    ["Positions"] = {Center = 1, Top = 2, Bottom = 3},
    ["OptimizationLevel"] = {Default = 0, Optimized = 1, VeryOptimized = 2}
}
--------------------------------------------------------------
Library = {
	DebugOutput = false,
    OptimizationLevel = ValidTypes.OptimizationLevel.Default,
    ESPMode = ValidTypes.ESP.Highlight,
    UpdateFreq = 0.05,
    AutoUpdate = true,
    TimeSinceLastUpdate = 0,

    -- visuals
    --- text
    Font = Enum.Font.RobotoMono,
    TextSize = 20,
    --TextPosition = ValidTypes.Positions.Center

    --- ESP
    FillTransparency = 0.75,
    OutlineTransparency = 0,
    FadeTime = 0,
	DefaultMaxDistance = 100,

	-- data/instances
    Objects = {},
	ObjectData = {},
    Highlights = {},
    TextLabels = {},
    Colors = {},
    
} Library.Unloaded = false
--------------------------------------------------------------
CloneReference = cloneref or function(O) return O end
local Players = CloneReference(game:GetService("Players"))
local CoreGui = getgenv and CloneReference(game:GetService("CoreGui")) or Players.LocalPlayer.PlayerGui
local Workspace = CloneReference(workspace)
local RunService = CloneReference(game:GetService("RunService"))
local UserInputService = CloneReference(game:GetService("UserInputService"))
local Debris = CloneReference(game:GetService("Debris"))
local TweenService = CloneReference(game:GetService("TweenService"))
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
--------------------------------------------------------------
function Library:GenerateRandomString(Length)
	local Chars = {}
	local Pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	for I = 1, (Length or 24) do
		local Idx = math.random(1, #Pool)
		Chars[I] = Pool:sub(Idx, Idx)
	end
    local Result = table.concat(Chars)
	return Result
end

local function GetHiddenUI()
	if gethui then return gethui() end
	local Folder = Instance.new("Folder", CoreGui)
	Folder.Name = ("%032x"):format(math.random(0, 2^31))
	return Folder
end
--------------------------------------------------------------
local Hui = GetHiddenUI()
Hui.Name = Library:GenerateRandomString(32)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = Library:GenerateRandomString()
ScreenGui.Parent = Hui
--------------------------------------------------------------
local Folders = {}
function AddFolder(Name:string)
    local NewFolder = Instance.new("Folder", Hui)
    NewFolder.Name = Library:GenerateRandomString()
    Folders[Name] = NewFolder
    return NewFolder
end
--------------------------------------------------------------
local HighlightsFolder = AddFolder("Highlights")
local TextHolder = Instance.new("Frame", ScreenGui)
TextHolder.Size = UDim2.fromScale(1,1)
TextHolder.BackgroundTransparency = 1
--------------------------------------------------------------
local Tweens = {
    QuadOut = TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    BackOut = TweenInfo.new(0, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}
function TweenObject(obj,info,prop, Callback:() -> ())
    info.Time = Library.FadeTime
    tween = TweenService:Create(obj,info,prop)
    if Callback then tween.Completed:Once(function() Callback() end) end
    tween:Play()
end
local function debugPrint(string)
	if Library.DebugOutput then
		print(string)
	end
end
--------------------------------------------------------------
function Library:RemoveESP(Object)
	local obj = Object
	debugPrint(`Attempt to remove {obj} from ESP.`)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return end
	debugPrint("Object exists")
	if Library.Objects[obj] then
		Library.Objects[obj] = nil
		Library.ObjectData[obj] = nil
		if Library.Highlights[obj] then
			Library.Highlights[obj]:Destroy()
			Library.Highlights[obj] = nil
		end
		if Library.TextLabels[obj] then
			Library.TextLabels[obj]:Destroy()
			Library.TextLabels[obj] = nil
		end
		debugPrint("Object successfully removed from ESP.")
	end
end

function Library:AddESP(params)
	-- params: {Object:BasePart|Model, Text:string, Color:Color3}
    if Library.Unloaded then return end
	debugPrint(`Attempt to add {obj} to ESP.`)
    local obj = params.Object or params
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return end
	debugPrint("Object found")
	if Library.Objects[obj] then return debugPrint("Object has already been added.") end
	Library.Objects[obj] = obj
	debugPrint("Setting data..")
	if obj == params then
		Library.ObjectData[obj] = {
			Color = Color3.New(1,1,1),
			Text = (obj.Name or "Object"),
			MaxDistance = Library.DefaultMaxDistance
		}
	else
		Library.ObjectData[obj] = {
			Color = params.Color or Color3.New(1,1,1),
			Text = params.Text or (obj.Name or "Object"),
			MaxDistance = params.MaxDistance or Library.DefaultMaxDistance
		}
	end
	obj.Destroying:Once(function() Library:RemoveESP(obj) end)
	debugPrint("Object successfully added.")
end
--------------------------------------------------------------
function Library.Update(dt)
	if Library.Unloaded then return end
	Library.TimeSinceLastUpdate += dt
	if Library.TimeSinceLastUpdate < Library.UpdateFreq then return end
	Library.TimeSinceLastUpdate = 0

	for objId, obj in Library.Objects do
		if not obj or (obj and not obj:IsDescendantOf(workspace) or obj:IsDescendantOf(LocalPlayer.Character)) then
			debugPrint(`{obj} not found, removing..`)
			Library:RemoveESP(obj)
		end
		if obj and Library.ObjectData[obj] then
			objOutOfRange = false
			local Distance = ((obj:IsA("Model") and obj:GetPivot().Position or obj.Position) - Camera.CFrame.Position).Magnitude
			if Distance > objInfo.MaxDistance then objOutOfRange = true end
			objData = Library.ObjectData[obj]
			-- Create Highlight
			if not Library.Highlights[obj] then
				Library.Highlights[obj] = Instance.new("Highlight", HighlightsFolder)
				Library.Highlights[obj].Name = Library:GenerateRandomString()
				Library.Highlights[obj].DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				Library.Highlights[obj].Adornee = obj
			end
			objHighlight = Library.Highlights[obj]
			-- Update Highlight
			if objHighlight.FillColor ~= objData.Color then objHighlight.FillColor = objData.Color end
			if objHighlight.OutlineColor ~= objData.Color then objHighlight.OutlineColor = objData.Color end
			if objHighlight.FillTransparency ~= Library.FillTransparency then objHighlight.FillTransparency = Library.FillTransparency end
			if objHighlight.OutlineTransparency ~= Library.OutlineTransparency then objHighlight.OutlineTransparency = Library.OutlineTransparency end

			if objOutOfRange then 
				objHighlight.Adornee = nil
			else
				Library.Highlights[obj].Adornee = obj
			end

			-- Create Text
			if not Library.TextLabels[obj] then
				Library.TextLabels[obj] = Instance.new("TextLabel", TextHolder)
				Library.TextLabels[obj].Name = Library:GenerateRandomString()
				Library.TextLabels[obj].BackgroundTransparency = 1
				Library.TextLabels[obj].TextStrokeTransparency = 0
				Library.TextLabels[obj].Size = UDim2.fromOffset(21,21)
				Library.TextLabels[obj].RichText = true
				Library.TextLabels[obj].AnchorPoint = Vector2.new(0.5,0.5)
				Library.TextLabels[obj].Text = objData.Text
			end
			objText = Library.TextLabels[obj]
			-- Update Text
			if objText.TextColor3 ~= objData.Color then objText.TextColor3 = objData.Color end
			if objText.TextSize ~= Library.TextSize then objText.TextSize = Library.TextSize end
			if objText.TextStrokeColor3 ~= Color3.fromRGB(objData.Color.R/2,objData.Color.G/2,objData.Color.B/2) then objText.TextStrokeColor3 = Color3.fromRGB(objData.Color.R/2,objData.Color.G/2,objData.Color.B/2) end
			if objText.Font ~= Library.Font then objText.Font = Library.Font end

			-- Position Text
			local objScreenPosition, objOnScreen = Camera:WorldToViewportPoint(obj:IsA("Model") and obj:GetPivot().Position or obj.Position)
			if not objScreenPosition then return end
			objText.Visible = objOnScreen
			if objOutOfRange then objText.Visible = false end
			if objOnScreen and not objOutOfRange then
				objText.Position = UDim2.fromScale(
					objScreenPosition.X / Camera.ViewportSize.X,
					objScreenPosition.Y / Camera.ViewportSize.Y
				)
			end
		end
	end
end
--------------------------------------------------------------
function Library.SetOptimizationLevel(level:string)
	if ValidTypes.OptimizationLevel[level] then Library.OptimizationLevel = ValidTypes.OptimizationLevel[level] end
end
--------------------------------------------------------------
function Library:ClearAllESP()
	if Library.Unloaded then return end
	for objId, obj in Library.Objects do
		Library:RemoveESP(obj)
	end
end

function Library:Unload()
	if Library.Unloaded then return end
	Library:ClearAllESP()
	TextHolder:Destroy()
	for _,v in Folders do v:Destroy() end
	CameraConnection:Disconnect()
	Library.Unloaded = true
end
--------------------------------------------------------------
CameraConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = Workspace.CurrentCamera
end)
--------------------------------------------------------------
if getgenv then
	getgenv().ESPLibrary = Library
end
return Library
