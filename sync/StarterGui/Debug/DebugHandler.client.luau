local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local debug_screenui = script.Parent
local holder_frame = debug_screenui:WaitForChild("Holder")

-- Ensure the module exists before requiring
local replicant_path = ReplicatedStorage.Shared.Modules["Client Modules"].ReplicantService
local replicantservice_module = require(replicant_path)

local camera = workspace.CurrentCamera

-- sampling (prevents heavy loops)
local SAMPLE_SIZE = 200

----------------------------------------------------------------
-- UI REFERENCES
----------------------------------------------------------------
local fps_frame = holder_frame:WaitForChild("FPS")
local fps_tablegraph = fps_frame:WaitForChild("Table")
local fps_button = fps_frame:WaitForChild("Button")
local fps_example = fps_tablegraph.Bars.Example

local ping_frame = holder_frame:WaitForChild("Ping")
local ping_tablegraph = ping_frame:WaitForChild("Table")
local ping_button = ping_frame:WaitForChild("Button")
local ping_example = ping_tablegraph.Bars.Example

local memory_frame = holder_frame:WaitForChild("Memory")
local memory_tablegraph = memory_frame:WaitForChild("Table")
local memory_example = memory_tablegraph.Bars.Example

local replication_frame = holder_frame:WaitForChild("Replication")
local replication_tablegraph = replication_frame:WaitForChild("Table")
local replication_example = replication_tablegraph.Bars.Example
local replication_button = replication_frame:WaitForChild("Button")

local instances_frame = holder_frame:WaitForChild("Instances")
local instances_tablegraph = instances_frame:WaitForChild("Table")
local instances_button = instances_frame:WaitForChild("Button")
local instances_example = instances_tablegraph.Bars.Example
local Total_Instances_TextLabel = instances_frame:FindFirstChild("Instances")
local Total_Meshes_Textlabel = instances_frame:FindFirstChild("Meshes")
local On_Screen_TextLabel = instances_frame:FindFirstChild("On-Screen")

local version_frame = holder_frame:WaitForChild("Version")

local title_button = holder_frame.Title.Button
local mouse_hover = debug_screenui.MouseHover



----------------------------------------------------------------
-- THEMES & DIAGNOSTICS SETUP
----------------------------------------------------------------
local Themes = {
	FPS = { Primary = Color3.fromRGB(80,170,255), Background = Color3.fromRGB(15,25,45), Text = Color3.fromRGB(180,220,255) },
	Ping = { Primary = Color3.fromRGB(255,170,80), Background = Color3.fromRGB(45,25,15), Text = Color3.fromRGB(255,210,180) },
	Memory = { Primary = Color3.fromRGB(140,255,140), Background = Color3.fromRGB(20,40,20), Text = Color3.fromRGB(200,255,200) },
	Replication = { Primary = Color3.fromRGB(180,120,255), Background = Color3.fromRGB(30,20,50), Text = Color3.fromRGB(220,200,255) },
	Instances = { Primary = Color3.fromRGB(255,200,100), Background = Color3.fromRGB(50,35,15), Text = Color3.fromRGB(255,230,200) }
}

local function apply_theme(frame, theme)
	frame.BackgroundColor3 = theme.Background
	for _, obj in ipairs(frame:GetDescendants()) do
		if obj:IsA("TextLabel") then obj.TextColor3 = theme.Text
		elseif obj:IsA("TextButton") then obj.BackgroundColor3 = theme.Primary obj.TextColor3 = Color3.new(1,1,1) end
	end
end

apply_theme(fps_frame, Themes.FPS)
apply_theme(ping_frame, Themes.Ping)
apply_theme(memory_frame, Themes.Memory)
apply_theme(replication_frame, Themes.Replication)
apply_theme(instances_frame, Themes.Instances)

-- Memory Diagnostic Variables
local MemoryTags = {}
for _, enum in pairs(Enum.DeveloperMemoryTag:GetEnumItems()) do table.insert(MemoryTags, {enum, enum.Name}) end
local last_memory_breakdown = {}
local active_mem_causes = "Scanning..."
local diag_timer = 0

----------------------------------------------------------------
-- GRAPH CLASS
----------------------------------------------------------------
local hovered_graph, hovered_index, pinned = nil, nil, false

local Graph = {}
Graph.__index = Graph

function Graph.new(frame, template, maxBars, theme, name)
	local self = setmetatable({}, Graph)
	self.frame, self.template, self.maxBars, self.name = frame, template, maxBars, name
	self.values, self.bars = {}, {}
	self.page, self.pages, self.paused = 0, 1, false
	template.Visible = false

	-- Locate the labels for live updates
	self.lbl_current = frame:FindFirstChild("Current" .. (name == "FPS" and "Frames" or name)) 
		or frame:FindFirstChild("Current" .. name) 
		or frame:FindFirstChild(name .. "Usage") -- Fallback for different naming conventions

	self.lbl_average = frame:FindFirstChild("Average" .. name)
		or frame:FindFirstChild("Average" .. (name == "FPS" and "Frames" or name))

	local options = frame.Table.Options

	-- PAUSE BUTTON
	options.Pause.Activated:Connect(function() 
		self.paused = not self.paused
		options.Pause.BackgroundColor3 = self.paused and Color3.fromRGB(255, 100, 100) or Themes[name].Primary
	end)

	-- PAGE NAVIGATION LEFT (moves to older data)
	options.Left.Activated:Connect(function() 
		self.page = math.min(self.pages - 1, self.page + 1)
	end)

	-- PAGE NAVIGATION RIGHT (moves to newer data)
	options.Right.Activated:Connect(function() 
		self.page = math.max(0, self.page - 1)
	end)

	self.lbl_page = options.Page

	for i = 1, maxBars do
		local bar = template:Clone()
		bar.Parent = frame.Table.Bars
		bar.AnchorPoint = Vector2.new(0,1)
		bar.Size = UDim2.new((1/maxBars)*0.85, 0, 0.01, 0)
		bar.Position = UDim2.new((i-1)/maxBars, 0, 1, 0)
		bar.Visible = false
		bar.MouseEnter:Connect(function() if not pinned then hovered_graph, hovered_index = self, i end end)
		bar.MouseLeave:Connect(function() if not pinned then hovered_graph, hovered_index = nil, nil end end)
		bar.MouseButton1Click:Connect(function() pinned = not pinned if pinned then hovered_graph, hovered_index = self, i end end)
		self.bars[i] = bar
	end
	return self
end

function Graph:push(value)
	if self.paused then return end
	table.insert(self.values, value)
	if #self.values > self.maxBars * 10 then table.remove(self.values, 1) end
	self.pages = math.max(1, math.ceil(#self.values / self.maxBars))
	self.page = math.clamp(self.page, 0, self.pages - 1)
end

function Graph:render(normalizeFunc, severityFunc)
	local endIndex = #self.values - (self.page * self.maxBars)
	local startIndex = math.max(1, endIndex - self.maxBars + 1)
	local maxVal = 0.0001

	-- Update page display
	if self.lbl_page then
		self.lbl_page.Text = string.format("%d/%d", self.page + 1, self.pages)
	end

	-- Calculate average from all values
	local sum = 0
	local count = 0
	for _, v in ipairs(self.values) do
		local num = typeof(v) == "table" and v.total or v
		sum = sum + num
		count = count + 1
	end
	local average = count > 0 and (sum / count) or 0

	-- Find Max and Update the "Current" TextLabel
	local latest = self.values[#self.values]
	if latest and self.lbl_current then
		local num = typeof(latest) == "table" and latest.total or latest
		local suffix = (self.name == "Ping" and " ms") or (self.name == "Memory" and " MB") or ""
		self.lbl_current.Text = string.format("Current: %.1f%s", num, suffix)
	end

	-- Update the "Average" TextLabel
	if self.lbl_average then
		local suffix = (self.name == "Ping" and " ms") or (self.name == "Memory" and " MB") or ""
		self.lbl_average.Text = string.format("Average: %.1f%s", average, suffix)
	end

	for i = startIndex, endIndex do
		local v = self.values[i]
		local num = typeof(v) == "table" and v.total or v
		maxVal = math.max(maxVal, num)
	end

	for i = 1, self.maxBars do
		local bar = self.bars[i]
		local raw = self.values[startIndex + i - 1]
		if raw then
			bar.Visible = true
			local scale = normalizeFunc(raw, maxVal)
			bar.Size = UDim2.new(bar.Size.X.Scale, 0, math.clamp(scale, 0.01, 1), 0)
			bar.Position = UDim2.new(bar.Position.X.Scale, 0, 1 - scale, 0)
			bar.BackgroundColor3 = severityFunc(raw)
		else bar.Visible = false end
	end
	return startIndex
end

----------------------------------------------------------------
-- INSTANCES & TRACKING
----------------------------------------------------------------
local fps_graph = Graph.new(fps_frame, fps_example, 60, Themes.FPS, "FPS")
local ping_graph = Graph.new(ping_frame, ping_example, 60, Themes.Ping, "Ping")
local memory_graph = Graph.new(memory_frame, memory_example, 60, Themes.Memory, "Memory")
local replication_graph = Graph.new(replication_frame, replication_example, 60, Themes.Replication, "Replication")
local instances_graph = Graph.new(instances_frame, instances_example, 60, Themes.Instances, "Instances")

local total_processed_at_last_frame = 0

RunService.RenderStepped:Connect(function(dt)
	if dt <= 0 then return end

	-- 1. Performance Data
	local fps = 1/dt
	local ping = Players.LocalPlayer:GetNetworkPing() * 1000
	local memory = Stats:GetTotalMemoryUsageMb()

	-- 2. Instance Counting (refresh each frame for accuracy)
	local workspace_descendants = workspace:GetDescendants()
	local camera_descendants = camera:GetDescendants()
	local total_instances = #workspace_descendants + #camera_descendants

	local total_meshes = 0
	local on_screen = 0

	local step = math.max(1, math.floor(#workspace_descendants / SAMPLE_SIZE))

	for i = 1, #workspace_descendants, step do
		local obj = workspace_descendants[i]

		if obj:IsA("MeshPart") then
			total_meshes += 1
		end

		if obj:IsA("BasePart") then
			local screenPos, visible = camera:WorldToViewportPoint(obj.Position)

			if visible and screenPos.Z > 0 then
				on_screen += 1
			end
		end
	end

	-- Count meshes in camera
	for i = 1, #camera_descendants do
		local obj = camera_descendants[i]
		if obj:IsA("MeshPart") then
			total_meshes += 1
		end
	end

	-- 3. Memory Diagnostic
	diag_timer += dt
	if diag_timer >= 0.25 then
		diag_timer = 0
		local m1, m2 = {name="None", raw=0}, {name="None", raw=0}
		for _, tagInfo in ipairs(MemoryTags) do
			local val = Stats:GetMemoryUsageMbForTag(tagInfo[1])
			local last = last_memory_breakdown[tagInfo[2]] or val
			local delta = math.abs(val - last)
			if delta > m1.raw then m2 = m1 m1 = {name = tagInfo[2], raw = delta, val = val}
			elseif delta > m2.raw then m2 = {name = tagInfo[2], raw = delta, val = val} end
			last_memory_breakdown[tagInfo[2]] = val
		end
		active_mem_causes = string.format("1. %s (+%.1fMB)\n2. %s (+%.1fMB)", m1.name, m1.raw, m2.name, m2.raw)
	end

	-- 4. Replication Delta Logic
	local buffer = replicantservice_module:GetReplicationBuffer()
	local total_now = #buffer
	local newEvents = 0
	local breakdown = {FastCast=0, VFX=0, Texture=0, Holster=0}

	if total_now > total_processed_at_last_frame then
		for i = total_now, (total_processed_at_last_frame + 1), -1 do
			local event = buffer[i]
			if event then
				newEvents += 1
				if breakdown[event.Type] then breakdown[event.Type] += 1 end
			end
		end
	elseif total_now < total_processed_at_last_frame and total_now > 0 then
		newEvents = 1 
	end
	total_processed_at_last_frame = total_now

	-- 5. Push Data
	fps_graph:push(fps)
	ping_graph:push({total = ping, recv = Stats.DataReceiveKbps, send = Stats.DataSendKbps})
	memory_graph:push({total = memory, causes = active_mem_causes})
	replication_graph:push({total = newEvents, breakdown = breakdown})
	instances_graph:push({total = total_instances, meshes = total_meshes, onScreen = on_screen})

	-- 6. Update Instances Labels (live)
	if Total_Instances_TextLabel then Total_Instances_TextLabel.Text = "Instances: " .. tostring(total_instances) end
	if Total_Meshes_Textlabel then Total_Meshes_Textlabel.Text = "Meshes: " .. tostring(total_meshes) end
	if On_Screen_TextLabel then On_Screen_TextLabel.Text = "On-Screen: " .. tostring(on_screen) end

	-- 7. Render All (Updates Bars AND Current Labels AND Average Labels AND Page Numbers)
	local f_s = fps_graph:render(function(v,m) return math.clamp(v/60,0,1) end, function(v) return Themes.FPS.Primary:Lerp(Color3.new(1,0,0), math.clamp(1-(v/60),0,1)) end)
	local p_s = ping_graph:render(function(v,m) return math.clamp(v.total/m,0,1) end, function(v) return Themes.Ping.Primary:Lerp(Color3.new(1,0,0), math.clamp(v.total/300,0,1)) end)
	local m_s = memory_graph:render(function(v,m) return math.clamp(v.total/m,0,1) end, function(v) return Themes.Memory.Primary end)
	local r_s = replication_graph:render(function(v,m) return math.clamp(v.total/(m > 0 and m or 1),0,1) end, function(v) return Themes.Replication.Primary:Lerp(Color3.new(1,0,0), math.clamp(v.total/20,0,1)) end)
	local i_s = instances_graph:render(function(v,m) return math.clamp(v.total/m,0,1) end, function(v) return Themes.Instances.Primary:Lerp(Color3.new(1,0,0), math.clamp(v.total/10000,0,1)) end)

	-- 8. Hover Tooltips
	if hovered_graph and hovered_index then
		mouse_hover.Visible = true
		if not pinned then
			local m = UserInputService:GetMouseLocation()
			mouse_hover.Position = UDim2.fromOffset(m.X+12, m.Y+12)
		end

		local idx = (hovered_graph == fps_graph and f_s) or (hovered_graph == ping_graph and p_s) or (hovered_graph == memory_graph and m_s) or (hovered_graph == replication_graph and r_s) or i_s
		local data = hovered_graph.values[idx + hovered_index - 1]

		if data then
			if hovered_graph == fps_graph then
				mouse_hover.Text = string.format("[FPS]\nValue: %.1f\nMS: %.2f", data, 1000/data)
			elseif hovered_graph == ping_graph then
				mouse_hover.Text = string.format("[NETWORK]\nPing: %.1fms\nIn: %.1fKB/s\nOut: %.1fKB/s", data.total, data.recv, data.send)
			elseif hovered_graph == memory_graph then
				mouse_hover.Text = string.format("[MEMORY]\nTotal: %.1fMB\nTop Shifts:\n%s", data.total, data.causes)
			elseif hovered_graph == replication_graph then
				mouse_hover.Text = string.format("[REPLICATION]\nTotal: %d\nFastCast: %d\nVFX: %d\nTexture: %d\nHolster: %d", data.total, data.breakdown.FastCast, data.breakdown.VFX, data.breakdown.Texture, data.breakdown.Holster)
			elseif hovered_graph == instances_graph then
				mouse_hover.Text = string.format("[INSTANCES]\nTotal: %d\nMeshes: %d\nOn-Screen: %d", data.total, data.meshes, data.onScreen)
			end
		end
	else 
		mouse_hover.Visible = false 
	end
end)

----------------------------------------------------------------
-- TOGGLES
----------------------------------------------------------------
title_button.Activated:Connect(function()
	local state = not fps_frame.Visible
	fps_frame.Visible = state 
	ping_frame.Visible = state 
	memory_frame.Visible = state 
	replication_frame.Visible = state 
	instances_frame.Visible = state
	version_frame.Visible = state
end)

fps_button.Activated:Connect(function() fps_tablegraph.Visible = not fps_tablegraph.Visible end)
ping_button.Activated:Connect(function() ping_tablegraph.Visible = not ping_tablegraph.Visible end)
memory_frame.Button.Activated:Connect(function() memory_tablegraph.Visible = not memory_tablegraph.Visible end)
replication_button.Activated:Connect(function() replication_tablegraph.Visible = not replication_tablegraph.Visible end)
instances_button.Activated:Connect(function() instances_tablegraph.Visible = not instances_tablegraph.Visible end)

local version_folder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Configuration"):WaitForChild("Game_Variables"):WaitForChild("Version")
for _, child:StringValue in version_folder:GetChildren() do
	local ui_reference = version_frame:FindFirstChild(child.Name)
	if ui_reference then ui_reference.Text = child.Name .. ": " .. child.Value end

	child:GetPropertyChangedSignal("Value"):Connect(function()
		if ui_reference then ui_reference.Text = child.Name .. ": " .. child.Value end
	end)
	
end

debug_screenui.Enabled = true
