local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Roact = require(script.Parent.Parent.Packages.Roact)
local ExternalEventConnection = require(script.Parent.Parent.Packages.ExternalEventConnection)

local events = script.Parent.Parent.Events
local clientEvents = events.ClientEvents
local seekEvent = clientEvents.Seek
local pauseEvent = clientEvents.Pause
local loadSceneFromListEvent = events.SceneControl.LoadSceneFromList
local orchestrateSceneEvent = events.SceneControl.OrchestrateScene
local clientSceneMetadataEvent = clientEvents.ClientSceneMetadata

local SeekFrame = require(script.Parent.SeekerComponents.SeekFrame)
local GamepadOpenPrompt = require(script.Parent.SeekerComponents.GamepadOpenPrompt)
local GamepadClosePrompt = require(script.Parent.SeekerComponents.GamepadClosePrompt)

local SCENE_TAG = "SequencerScene"
local SCENE_FOLDER = "SequencerScenes"

local SeekerGui = Roact.Component:extend("SeekerGui")

function SeekerGui:init()
	self:setState({
		isCollapsed = false,
		isSettingTimeManually = false,
		currentScene = nil,
		timeValue = nil,
		sceneLength = nil,
		isScrubbing = false,
		scrubbingPreviewTime = nil,
		isSoSmall = false,
		scenes = {},
		isLoading = false,
		showingGamepadClosePrompt = false,
		showingGamepadOpenPrompt = false,
		isPaused = false,
	})

	function self.formatTime(time)
		time = time or 0

		local seconds = time % 60
		local minutes = (time / 60) % 60
		local hours = (time / 3600) % 24

		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	end

	function self.unformatTime(timeString)
		local times = string.split(timeString, ":")

		if #times == 1 then
			times = { 0, 0, times[1] }
		elseif #times == 2 then
			times = { 0, times[1], times[2] }
		end

		for i, time in pairs(times) do
			times[i] = tonumber(time)
		end

		local hours = times[1] and times[1] * 3600 or 0
		local minutes = times[2] and times[2] * 60 or 0
		local seconds = times[3] and times[3] or 0

		return (hours + minutes + seconds)
	end

	function self.toggleSettingTimeManually()
		self:setState(function(state)
			return {
				isSettingTimeManually = not state.isSettingTimeManually,
			}
		end)
	end

	function self.updateScenesList()
		local scenesList = {}
		local OrchestraScenes = ReplicatedStorage:FindFirstChild(SCENE_FOLDER)

		if OrchestraScenes then
			for _, folder in ipairs(OrchestraScenes:GetChildren()) do
				if folder:IsA("Configuration") or folder:IsA("Folder") then
					table.insert(scenesList, {
						Name = folder.Name,
						Length = folder:GetAttribute("TimeLength"),
					})
				end
			end
		end

		for _, scene in ipairs(CollectionService:GetTagged(SCENE_TAG)) do
			table.insert(scenesList, {
				Name = scene.Name,
				Length = scene:GetAttribute("TimeLength"),
			})
		end

		self:setState({ scenes = scenesList })
	end

	function self.onSceneSelected(sceneName)
		if sceneName == self.state.selectedScene then
			warn("Scene is already loaded")
		end

		self:setState({
			isLoading = true,
			isCollapsed = false,
		})

		if ReplicatedStorage.Inline.Value == true then
			orchestrateSceneEvent:FireServer(sceneName)
		else
			loadSceneFromListEvent:FireServer(sceneName)
		end
	end

	function self.onSeek(ratio)
		seekEvent:FireServer(ratio)
	end

	function self.pause()
		pauseEvent:FireServer(true)
	end

	function self.unpause()
		pauseEvent:FireServer(false)
	end

	function self.onClientSceneMetadataEvent(type, sceneName, timeValue, sceneLength)
		if type == "Pass" then
			self:setState({
				currentScene = sceneName,
				timeValue = timeValue,
				sceneLength = sceneLength,
				isLoading = false,
			})
		end
	end

	function self.onPauseEvent(isPaused: boolean)
		self:setState({
			isPaused = isPaused,
		})
	end

	function self.showGamepadClosePrompt()
		self:setState({
			showingGamepadClosePrompt = true,
		})
	end

	function self.hideGamepadClosePrompt()
		self:setState({
			showingGamepadClosePrompt = false,
		})
	end

	function self.showGamepadOpenPrompt()
		self:setState({
			showingGamepadOpenPrompt = true,
		})
	end

	function self.hideGamepadOpenPrompt()
		self:setState({
			showingGamepadOpenPrompt = false,
		})
	end

	function self.setFrameTiny()
		self:setState({
			isSoSmall = true,
		})
	end

	function self.setFrameNotTiny()
		self:setState({
			isSoSmall = false,
		})
	end

	function self.toggleCollapseClicked()
		self:setState(function(state)
			return {
				isCollapsed = not state.isCollapsed,
			}
		end)
	end

	function self.toggleScrubbing()
		self:setState(function(state)
			return {
				isScrubbing = not state.isScrubbing,
			}
		end)
	end

	function self.onDraggingBegan()
		self:setState({
			isDragging = true,
		})
	end

	function self.onDraggingEnded()
		self:setState({
			isDragging = false,
		})
	end

	function self.setScrubbingPreviewTime(time)
		self:setState({
			scrubbingPreviewTime = time,
		})
	end

	self.screenGuiRef = Roact.createRef()
	self.screenWidthBinding, self.updateScreenWidthBinding = Roact.createBinding(700)

	self.updateFrameWidth = RunService.Heartbeat:Connect(function()
		local screenGui = self.screenGuiRef:getValue()

		if screenGui then
			self.updateScreenWidthBinding(screenGui.AbsoluteSize.X)
		end
	end)

	self.updateScenesList()

	if UserInputService.GamepadEnabled then
		local holdButtonsToOpen = {
			[Enum.KeyCode.ButtonR2] = false,
			[Enum.KeyCode.ButtonL2] = false,
		}

		self.gamepadConnection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				if input.KeyCode == Enum.KeyCode.ButtonR2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
					holdButtonsToOpen[input.KeyCode] = true
				elseif input.KeyCode == Enum.KeyCode.ButtonB then
					self.setFrameTiny()
					self.hideGamepadClosePrompt()
				end

				if
					holdButtonsToOpen[Enum.KeyCode.ButtonR2] == true
					and holdButtonsToOpen[Enum.KeyCode.ButtonL2] == true
				then
					task.wait(1)
					if
						holdButtonsToOpen[Enum.KeyCode.ButtonR2] == true
						and holdButtonsToOpen[Enum.KeyCode.ButtonL2] == true
					then
						self.setFrameNotTiny()

						GuiService:Select(self.screenGuiRef:getValue())

						self.hideGamepadOpenPrompt()
						self.showGamepadClosePrompt()
					end
				end
			end
		end)

		self.gamepadConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				if input.KeyCode == Enum.KeyCode.ButtonR2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
					holdButtonsToOpen[input.KeyCode] = false
				end
			end
		end)

		self.setFrameTiny()
		self.showGamepadOpenPrompt()
	end
end

function SeekerGui:render()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		DisplayOrder = 999,
		[Roact.Ref] = self.screenGuiRef,
	}, {
		clientSceneMetadataEventListener = Roact.createElement(ExternalEventConnection, {
			event = clientSceneMetadataEvent.Event,
			callback = self.onClientSceneMetadataEvent,
		}),
		pauseEventListener = Roact.createElement(ExternalEventConnection, {
			event = pauseEvent.OnClientEvent,
			callback = self.onPauseEvent,
		}),
		sceneAddedListener = Roact.createElement(ExternalEventConnection, {
			event = CollectionService:GetInstanceAddedSignal(SCENE_TAG),
			callback = self.updateScenesList,
		}),
		sceneRemovedListener = Roact.createElement(ExternalEventConnection, {
			event = CollectionService:GetInstanceRemovedSignal(SCENE_TAG),
			callback = self.updateScenesList,
		}),
		GamepadOpenPrompt = self.state.showingGamepadOpenPrompt == true and Roact.createElement(GamepadOpenPrompt, {
			hideGamepadOpenPrompt = self.hideGamepadOpenPrompt,
		}),
		GamepadClosePrompt = self.state.showingGamepadClosePrompt == true and Roact.createElement(GamepadClosePrompt, {
			hideGamepadClosePrompt = self.hideGamepadClosePrompt,
		}),
		SeekFrame = Roact.createElement(SeekFrame, {
			scenes = self.state.scenes,
			isLoading = self.state.isLoading,
			isScrubbing = self.state.isScrubbing,
			isDragging = self.state.isDragging,
			isCollapsed = self.state.isCollapsed,
			currentScene = self.state.currentScene,
			sceneLength = self.state.sceneLength,
			timeValue = self.state.timeValue,
			scrubbingPreviewTime = self.state.scrubbingPreviewTime,
			isSoSmall = self.state.isSoSmall,
			isSettingTimeManually = self.state.isSettingTimeManually,
			onSeek = self.onSeek,
			toggleCollapseClicked = self.toggleCollapseClicked,
			toggleScrubbing = self.toggleScrubbing,
			setScrubbingPreviewTime = self.setScrubbingPreviewTime,
			onDraggingBegan = self.onDraggingBegan,
			onDraggingEnded = self.onDraggingEnded,
			screenGuiRef = self.screenGuiRef,
			setFrameTiny = self.setFrameTiny,
			setFrameNotTiny = self.setFrameNotTiny,
			onSceneSelected = self.onSceneSelected,
			toggleSettingTimeManually = self.toggleSettingTimeManually,
			formatTime = self.formatTime,
			unformatTime = self.unformatTime,
			screenWidthBinding = self.screenWidthBinding,
			isPaused = self.state.isPaused,
			pause = self.pause,
			unpause = self.unpause,
		}),
	})
end

return SeekerGui
