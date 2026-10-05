--!strict
-- Hidden Officer Tool. G equips it, Q opens order selection, T cycles duration, and M1
-- submits the selection to the authoritative server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local KSP = game:GetService("KeyframeSequenceProvider")
local OrdersView = require(ReplicatedStorage.Shared.Modules["Client Modules"].OfficerOrdersView)
local Orders = OrdersView.Orders
local Durations = OrdersView.Durations
local OrderEvent = ReplicatedStorage.Shared.Library.Events:WaitForChild("WhistleOrder") :: RemoteEvent
local Folder = ReplicatedStorage.Shared.Assets.Animations.Tools.Utility:WaitForChild("TrenchWhistle")
local Equipment = ReplicatedStorage.Shared.Assets:WaitForChild("Equipment")
local WhistleModel = Equipment:WaitForChild("whistle")
local Whistle = {}; Whistle.__index = Whistle
function Whistle.new(info)
	-- This equipment model is authored as `whistle > body / hitbox`; unlike a
	-- normal Roblox Tool it deliberately has no Handle. The hitbox is its grip.
	local grip = WhistleModel:FindFirstChild("hitbox", true) or WhistleModel:FindFirstChildWhichIsA("BasePart", true)
	return setmetatable({
		name="TrenchWhistle", className="TrenchWhistle", Designation="Nil", tool=nil,
		equipped=false, order=1, duration=1, tracks={}, connections={}, charges=1,
		-- Non-gun equipment models live here, not in Assets.Guns.ToolModels.
		model_reference=WhistleModel,
		motor_6d_data={Parent="Right Arm", Part0="Right Arm", Part1=grip, C0=CFrame.new(0,-0.8,-0.2)*CFrame.Angles(math.rad(90),0,math.rad(90))},
	}, Whistle)
end
function Whistle:_play(name, looped)
	local t=self.tracks[name]
	if not t then return end
	t.Looped=looped==true; t.Priority=Enum.AnimationPriority.Action2
	local speed=name=="held" and 0.25 or name=="aim" and 0.5 or name=="choosing" and 0.5 or name=="draw" and 1.5 or 1
	t:Play(name=="draw" and 0 or name=="choosing" and 0.3 or 0.1,1,speed)
end
function Whistle:_setChargeDisplay(value)
	local c=Players.LocalPlayer.Character
	local root=c and c:FindFirstChild("HumanoidRootPart")
	local bb=root and root:FindFirstChild("Equipment_BB")
	local label=bb and bb:FindFirstChild("count",true)
	if label and label:IsA("TextLabel") then label.Text=tostring(value) end
end
function Whistle:_notify(text)
	local notifications = Players.LocalPlayer.PlayerGui:FindFirstChild("Notifications")
	local utils = notifications and notifications:FindFirstChild("Utils")
	if utils then require(utils).send_notification(Players.LocalPlayer, text) end
end
function Whistle:_ready()
	local player = Players.LocalPlayer
	local character = player.Character
	return self.equipped and not self.destroyed and self.tool and self.tool.Parent == character
		and character and not player:GetAttribute("MenuOpen") and not character:GetAttribute("ActionBlocked")
		and os.clock() >= math.max(self.nextRequest or 0,self.drawReadyAt or 0)
end
function Whistle:_refreshView()
	if self.View then self.View:SetState(Orders[self.order], Durations[self.duration], self.charges) end
end
function Whistle:_selectOrder(order)
	if not self:_ready() then return end
	local index = table.find(Orders, order)
	if not index then return end
	self.order = index
	self.View:CloseSelector()
	self.View:SetMessage(nil)
	self:_refreshView()
	-- Selecting with the mouse must not also blow the whistle.
	self.nextRequest = os.clock() + .15
end
function Whistle:_selectDuration(duration)
	if not self:_ready() then return end
	local index = table.find(Durations, duration)
	if not index then return end
	self.duration = index
	self.View:SetMessage(nil)
	self:_refreshView()
end
function Whistle:on_give(tool)
	self.tool=tool
	local character = Players.LocalPlayer.Character
	local function syncCharges()
		self.charges = character and character:GetAttribute("OfficerOrderCharges") or 1
		self:_setChargeDisplay(self.charges)
		self:_refreshView()
	end
	if character then
		table.insert(self.connections, character:GetAttributeChangedSignal("OfficerOrderCharges"):Connect(syncCharges))
	end
	syncCharges()
	local hum=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local animator=hum and (hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator"))
	if animator then
		for _, name in ipairs({"advance", "aim", "choosing", "defend", "draw", "focus", "held", "unequip", "use"}) do
			local source = Folder:FindFirstChild(name)
			local animation = source and (source:IsA("Animation") and source or source:FindFirstChildWhichIsA("Animation", true))
			local sequence = source and (source:IsA("KeyframeSequence") and source or source:FindFirstChildWhichIsA("KeyframeSequence", true))
			-- These clips are stored as an Animation containing its authored
			-- KeyframeSequence. The AnimationId is intentionally blank, so use the
			-- sequence instead of trying to load an empty asset id.
			local ok, track = pcall(function()
				local temporary
				if (not animation or animation.AnimationId == "") and sequence then
					temporary = Instance.new("Animation")
					temporary.AnimationId = KSP:RegisterKeyframeSequence(sequence)
					animation = temporary
				end
				if animation and animation.AnimationId ~= "" then
					local loaded = animator:LoadAnimation(animation)
					if temporary then temporary:Destroy() end
					return loaded
				end
			end)
			if ok and track then
				if self.destroyed then track:Destroy() else self.tracks[name] = track end
			end
		end
	end
	if self.destroyed then return end
	local function equipped()
		if self.equipped then return end
		self.equipped = true
		self.drawReadyAt=os.clock()+0.5
		if not self.View then
			self.View = OrdersView.new(function(order) self:_selectOrder(order) end,
				function(duration) self:_selectDuration(duration) end, function() return self:_ready() end,function()
					local choosing=self.tracks.choosing; if choosing then choosing:Stop(0.1) end
				end)
		end
		self.View:Show(Players.LocalPlayer.Character)
		self:_refreshView()
		self:_play("draw")
		task.delay(.5, function()
			if self.equipped then self:_play("held", true) end
		end)
	end
	table.insert(self.connections, tool.Equipped:Connect(equipped))
	table.insert(self.connections, tool.Unequipped:Connect(function()
		if not self.equipped then return end
		self.equipped = false
		if self.View then self.View:Hide() end
		for _, track in self.tracks do track:Stop(.1) end
		self:_play("unequip")
	end))
	-- The server equips this temporary Tool immediately after it replicates. If
	-- its Equipped event arrived before ToolService connected, initialize the
	-- draw/held state from its current parent instead of losing every animation.
	if tool.Parent == Players.LocalPlayer.Character then equipped() end
	table.insert(self.connections, tool.Activated:Connect(function()
		if not self:_ready() or (self.View and self.View.Selecting) then return end
		self.nextRequest = os.clock() + .4
		OrderEvent:FireServer(Orders[self.order], Durations[self.duration])
	end))
	table.insert(self.connections, OrderEvent.OnClientEvent:Connect(function(kind, value, detail)
		if kind == "Accepted" then
			self.charges = tonumber(value) or 0
			self:_setChargeDisplay(self.charges)
			self:_refreshView()
			if self.View then self.View:SetMessage(tostring(detail) .. " order issued.") end
			local animationName = string.lower(tostring(detail))
			if self.equipped then self:_play("use"); self:_play(animationName) end
		elseif kind == "State" then
			self.charges = tonumber(value) or self.charges
			self:_setChargeDisplay(self.charges)
			self:_refreshView()
			if self.View then self.View:SetMessage(nil) end
		elseif kind == "Rejected" and type(value) == "string" then
			self:_notify(value)
			if self.View then self.View:SetMessage(value) end
		end
	end))
	table.insert(self.connections, UserInputService.InputBegan:Connect(function(i,p)
		if p or not self:_ready() then return end
		if i.KeyCode == Enum.KeyCode.Q then
			self.View:ToggleSelector()
			if self.View.Selecting then self:_play("choosing",true) end
		elseif i.KeyCode == Enum.KeyCode.T then
			self:_selectDuration(Durations[self.duration % #Durations + 1])
		end
	end))
end
function Whistle:destroy()
	if self.destroyed then return end
	self.destroyed = true
	if self.View then self.View:Destroy(); self.View = nil end
	self.equipped = false
	for _, connection in self.connections do connection:Disconnect() end
	table.clear(self.connections)
	for _, track in self.tracks do track:Stop(0.1); track:Destroy() end
	table.clear(self.tracks)
	Players.LocalPlayer:SetAttribute("CantUnequip", nil)
end
return Whistle
