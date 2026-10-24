--------------------------------------------------------------
ValidTypes = {
    ["ESP"] = {Highlight = 1, Box = 2, None = 3},
    ["Positions"] = {Center = 1, Top = 2, Bottom = 3},
    ["OptimizationLevel"]  {Default = 0, Optimized = 1, VeryOptimized = 2}
}
--------------------------------------------------------------
Library = {
    OptimizationLevel = ValidTypes.OptimizationLevel.Default
    ESPMode = ValidTypes.ESP.Highlight,
    UpdateFreq = 0.5,
    AutoUpdate = true,
    TimeSinceLastUpdate = 0,

    -- visuals
    --- text
    Font = enum.Font.RobotoMono,
    TextSize = 20,
    TextPosition = ValidTypes.Positions.Center

    --- ESP
    FillTransparency = 0.8,
    OutlineTransparency = 0,
    FadeTime = 0.5
    
    Objects = {},
    Highlights = {},
    Billboards = {},
    Frames = {},
    Labels = {},
    Texts = {},
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
local Camera - Workspace.CurrentCamera
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
--------------------------------------------------------------
local MainUi = Instance.new("GuiMain", CoreGui)
MainUi.Name = Library:GenerateRandomString(32)
MainUi.ResetOnSpawn = false
MainUi.IgnoreGuiInset = true
--------------------------------------------------------------
local Folders = {}
function AddFolder(Name:string)
    local NewFolder = Instance.New("Folder", MainUi)
    NewFolder.Name = Library:GenerateRandomString()
    Folders[Name] = NewFolder
    return NewFolder
end
--------------------------------------------------------------
local HighlightsFolder = AddFolder("Highlights")
local BillboardsFolder = AddFolder("Billboards")
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
--------------------------------------------------------------
local function Library:AddESP(params)
    if Library.Unloaded then return end
    local obj = params.Object
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return end

    if Library.Highlights[obj] then
        if Library.OptimizationLevel > 0 then return end
        Library.Highlights[obj]:Destroy()
        Library.Highlights[obj] = nil
    end

    if Library.ESPMode == ValidTypes.ESP.Highlight then
        local Highlight = Instance.new("Highlight")
	    Highlight.FillTransparency = 1
	    Highlight.OutlineTransparency = 1
	    Highlight.Name = Library:GenerateRandomString()
	    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	    Highlight.Adornee = Object
	    Highlight.Parent = HighlightsFolder
	    Library.Highlights[Object] = Highlight

        local TextFrame = Instance.new("Frame")
	    TextFrame.Visible = false
	    TextFrame.Name = Library:GenerateRandomString()
	    TextFrame.Size = UDim2.fromScale(1, 1)
	    TextFrame.BackgroundTransparency = 1
	    TextFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	    TextFrame.Parent = BillboardsFolder

	    local TextLabel = Instance.new("TextLabel")
	    TextLabel.Name = Library:GenerateRandomString()
	    TextLabel.BackgroundTransparency = 1
	    TextLabel.Text = params.Text
	    TextLabel.TextTransparency = 1
	    TextLabel.TextStrokeTransparency = Library.TextOutlineTransparency
	    TextLabel.Size = UDim2.new(1, 0, 1, 0)
	    TextLabel.Font = Library.Font
	    TextLabel.TextSize = Library.TextSize
	    TextLabel.RichText = true
	    TextLabel.TextColor3 = params.Color
	    TextLabel.Parent = TextFrame

        Library.Frames[Object] = TextFrame
	    Library.Labels[Object] = TextLabel
	    Library.Colors[Object] = params.Color
	    Library.Texts[Object] = params.Text
	    Library.Objects[Object] = Object

        TweenObject(Highlight, Tweens.QuadOut, {FillTransparency = Library.FillTransparency, OutlineTranspatenct = Library.OutlineTransparency})
        TweenObject(TextLabel, Tweens.QuadOut, {TextTransparency = 0})
    end
end

return Library
