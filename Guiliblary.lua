-- GuiLib.lua
local GuiLib = {}
GuiLib.__index = GuiLib

local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function tween(obj, goal, time)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
end

function GuiLib:CreateWindow(config)
    local self = setmetatable({}, GuiLib)

    self.Config = config or {}
    self.Title = self.Config.Title or "My GUI"
    self.Theme = self.Config.Theme or "Blue"
    self.Notifications = self.Config.Notifications ~= false
    self.ToggleImageId = self.Config.ToggleImageId or "rbxassetid://1234567890"

    self.Tabs = {}
    self.CurrentPage = nil

    -- ScreenGui
    self.Gui = Instance.new("ScreenGui", PlayerGui)
    self.Gui.Name = "GuiLib_"..self.Title
    self.Gui.ResetOnSpawn = false

    -- Main Frame
    local Frame = Instance.new("Frame", self.Gui)
    Frame.Size = UDim2.new(0, 400, 0, 300)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Frame.Active = true
    Frame.Draggable = true
    self.Frame = Frame

    -- Title Bar
    local TitleBar = Instance.new("Frame", Frame)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 5, 0, 0)
    TitleLabel.Text = self.Title
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.new(1,1,1)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Minimize Button (-)
    local MinBtn = Instance.new("TextButton", TitleBar)
    MinBtn.Text = "-"
    MinBtn.Size = UDim2.new(0, 25, 1, 0)
    MinBtn.Position = UDim2.new(1, -55, 0, 0)
    MinBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    MinBtn.TextColor3 = Color3.new(1,1,1)

    -- Close Button (X)
    local CloseBtn = Instance.new("TextButton", TitleBar)
    CloseBtn.Text = "X"
    CloseBtn.Size = UDim2.new(0, 25, 1, 0)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(70,0,0)
    CloseBtn.TextColor3 = Color3.new(1,1,1)

    -- Tab Container
    local TabHolder = Instance.new("Frame", Frame)
    TabHolder.Size = UDim2.new(0, 100, 1, -30)
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.BackgroundColor3 = Color3.fromRGB(25,25,25)

    local ContentHolder = Instance.new("Frame", Frame)
    ContentHolder.Size = UDim2.new(1, -100, 1, -30)
    ContentHolder.Position = UDim2.new(0, 100, 0, 30)
    ContentHolder.BackgroundColor3 = Color3.fromRGB(35,35,35)

    self.TabHolder = TabHolder
    self.ContentHolder = ContentHolder

    -- Minimize Function
    local Minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            tween(Frame, {Size = UDim2.new(0,400,0,30)}, 0.3)
            TabHolder.Visible = false
            ContentHolder.Visible = false
        else
            tween(Frame, {Size = UDim2.new(0,400,0,300)}, 0.3)
            TabHolder.Visible = true
            ContentHolder.Visible = true
        end
    end)

    -- Close Function
    CloseBtn.MouseButton1Click:Connect(function()
        self.Gui:Destroy()
    end)

    return self
end

function GuiLib:AddTab(tabName)
    local TabButton = Instance.new("TextButton", self.TabHolder)
    TabButton.Size = UDim2.new(1, 0, 0, 30)
    TabButton.Text = tabName
    TabButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    TabButton.TextColor3 = Color3.new(1,1,1)

    local Page = Instance.new("ScrollingFrame", self.ContentHolder)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.ScrollBarThickness = 4

    TabButton.MouseButton1Click:Connect(function()
        for _,v in pairs(self.ContentHolder:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        Page.Visible = true
        self.CurrentPage = Page
    end)

    -- aktifkan langsung tab pertama
    if #self.Tabs == 0 then
        Page.Visible = true
        self.CurrentPage = Page
    end

    table.insert(self.Tabs, {Button = TabButton, Page = Page})
    return Page
end

function GuiLib:AddButton(tab, text, callback)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = UDim2.new(0, 5, 0, (#tab:GetChildren()-1) * 35)
    Btn.Text = text
    Btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.MouseButton1Click:Connect(callback)
end

function GuiLib:AddToggle(tab, text, default, callback)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = UDim2.new(0, 5, 0, (#tab:GetChildren()-1) * 35)
    Btn.Text = text..": "..tostring(default)
    Btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Btn.TextColor3 = Color3.new(1,1,1)

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = text..": "..tostring(state)
        callback(state)
    end)
end

function GuiLib:AddTextbox(tab, placeholder, callback)
    local Box = Instance.new("TextBox", tab)
    Box.Size = UDim2.new(1, -10, 0, 30)
    Box.Position = UDim2.new(0, 5, 0, (#tab:GetChildren()-1) * 35)
    Box.PlaceholderText = placeholder
    Box.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Box.TextColor3 = Color3.new(1,1,1)

    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)
end

function GuiLib:Notify(msg)
    if not self.Notifications then return end
    local Badge = Instance.new("TextLabel", self.Gui)
    Badge.Size = UDim2.new(0,200,0,40)
    Badge.Position = UDim2.new(0.5,-100,0,-60)
    Badge.BackgroundColor3 = Color3.fromRGB(0,100,200)
    Badge.Text = msg
    Badge.TextColor3 = Color3.new(1,1,1)

    tween(Badge, {Position = UDim2.new(0.5,-100,0,10)}, 0.3)
    task.delay(2, function()
        tween(Badge, {Position = UDim2.new(0.5,-100,0,-60)}, 0.3)
        task.wait(0.3)
        Badge:Destroy()
    end)
end

return GuiLib
    -- Title Bar
    local TitleBar = Instance.new("Frame", Frame)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 5, 0, 0)
    TitleLabel.Text = self.Title
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.new(1,1,1)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Minimize Button (-)
    local MinBtn = Instance.new("TextButton", TitleBar)
    MinBtn.Text = "-"
    MinBtn.Size = UDim2.new(0, 25, 1, 0)
    MinBtn.Position = UDim2.new(1, -55, 0, 0)
    MinBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    MinBtn.TextColor3 = Color3.new(1,1,1)

    -- Close Button (X)
    local CloseBtn = Instance.new("TextButton", TitleBar)
    CloseBtn.Text = "X"
    CloseBtn.Size = UDim2.new(0, 25, 1, 0)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(70,0,0)
    CloseBtn.TextColor3 = Color3.new(1,1,1)

    -- Tab Container
    local TabHolder = Instance.new("Frame", Frame)
    TabHolder.Size = UDim2.new(0, 100, 1, -30)
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.BackgroundColor3 = Color3.fromRGB(25,25,25)

    local ContentHolder = Instance.new("Frame", Frame)
    ContentHolder.Size = UDim2.new(1, -100, 1, -30)
    ContentHolder.Position = UDim2.new(0, 100, 0, 30)
    ContentHolder.BackgroundColor3 = Color3.fromRGB(35,35,35)

    self.TabHolder = TabHolder
    self.ContentHolder = ContentHolder

    -- Minimize Function
    local Minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            tween(Frame, {Size = UDim2.new(0,400,0,30)}, 0.3)
        else
            tween(Frame, {Size = UDim2.new(0,400,0,300)}, 0.3)
        end
    end)

    -- Close Function
    CloseBtn.MouseButton1Click:Connect(function()
        self.Gui:Destroy()
    end)

    return self
end

-- === ADD TAB ===
function GuiLib:AddTab(tabName)
    local TabButton = Instance.new("TextButton", self.TabHolder)
    TabButton.Size = UDim2.new(1, 0, 0, 30)
    TabButton.Text = tabName
    TabButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
    TabButton.TextColor3 = Color3.new(1,1,1)

    local Page = Instance.new("ScrollingFrame", self.ContentHolder)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.ScrollBarThickness = 4

    TabButton.MouseButton1Click:Connect(function()
        for _,v in pairs(self.ContentHolder:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        Page.Visible = true
    end)

    return Page
end

-- === ADD BUTTON ===
function GuiLib:AddButton(tab, text, callback)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = UDim2.new(0, 5, 0, #tab:GetChildren() * 35)
    Btn.Text = text
    Btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Btn.TextColor3 = Color3.new(1,1,1)

    Btn.MouseButton1Click:Connect(callback)
end

-- === ADD TOGGLE ===
function GuiLib:AddToggle(tab, text, default, callback)
    local Btn = Instance.new("TextButton", tab)
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = UDim2.new(0, 5, 0, #tab:GetChildren() * 35)
    Btn.Text = text..": "..tostring(default)
    Btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Btn.TextColor3 = Color3.new(1,1,1)

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = text..": "..tostring(state)
        callback(state)
    end)
end

-- === ADD TEXTBOX ===
function GuiLib:AddTextbox(tab, placeholder, callback)
    local Box = Instance.new("TextBox", tab)
    Box.Size = UDim2.new(1, -10, 0, 30)
    Box.Position = UDim2.new(0, 5, 0, #tab:GetChildren() * 35)
    Box.PlaceholderText = placeholder
    Box.BackgroundColor3 = Color3.fromRGB(60,60,60)
    Box.TextColor3 = Color3.new(1,1,1)

    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)
end

-- === NOTIFICATION BADGE ===
function GuiLib:Notify(msg)
    if not self.Notifications then return end
    local Badge = Instance.new("TextLabel", self.Gui)
    Badge.Size = UDim2.new(0,200,0,40)
    Badge.Position = UDim2.new(0.5,-100,0,10)
    Badge.BackgroundColor3 = Color3.fromRGB(0,100,200)
    Badge.Text = msg
    Badge.TextColor3 = Color3.new(1,1,1)

    tween(Badge, {Position = UDim2.new(0.5,-100,0,60)}, 0.5)
    task.delay(2, function()
        tween(Badge, {Position = UDim2.new(0.5,-100,0,-60)}, 0.5)
        task.wait(0.5)
        Badge:Destroy()
    end)
end

return GuiLib
