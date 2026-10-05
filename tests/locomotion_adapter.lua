-- Minimal Roblox boundary fixture; the real LocomotionService runs unchanged.
return function(Rules)
    local voices = {}
    local attrs, playerAttrs = {}, {}
    local root = {AssemblyLinearVelocity={Magnitude=0}, CFrame={LookVector={}}}
    local humanoid = {Health=200, WalkSpeed=10, FloorMaterial="Ground", MoveDirection={Magnitude=1}}
    function humanoid.MoveDirection:Dot() return 1 end
    function humanoid:GetState() return "Running" end
    local icon = {ImageTransparency=1}
    function icon:IsA(name) return name == "ImageLabel" end
    local character = {}
    function character:GetAttribute(name) return attrs[name] end
    function character:SetAttribute(name,value) attrs[name]=value end
    function character:FindFirstChildOfClass(name) return name == "Humanoid" and humanoid or nil end
    function character:FindFirstChild(name) return name == "HumanoidRootPart" and root or nil end
    local aimingGui = {}
    function aimingGui:FindFirstChild(name) return name == "hold_breath" and icon or nil end
    local gui = {}
    function gui:FindFirstChild(name) return name == "Aiming" and aimingGui or nil end
    local player = {Character=character}
    function player:GetAttribute(name) return playerAttrs[name] end
    function player:SetAttribute(name,value) playerAttrs[name]=value end
    function player:FindFirstChild() return nil end
    function player:FindFirstChildOfClass(name) return name == "PlayerGui" and gui or nil end
    local pressed=true
    local UIS={}
    function UIS:IsKeyDown(key) return pressed and key.Name == "LeftShift" end
    function UIS:GetConnectedGamepads() return {} end
    function UIS:GetFocusedTextBox() return nil end
    function UIS:GetLastInputType() return {Name="Keyboard"} end
    local key={Name="LeftShift"}
    local Enum={KeyCode={ButtonL3={Name="ButtonL3"}}, HumanoidStateType={Climbing="Climbing"}, Material={Air="Air"}, RenderPriority={Character={Value=300}}}
    function Enum.KeyCode:GetEnumItems() return {key} end
    local RunService={}
    function RunService:UnbindFromRenderStep() end
    function RunService:BindToRenderStep(name,priority,callback) self.callback=callback end
    local Voice={}
    function Voice.Play(character,kind) table.insert(voices,kind) end
    local Shared={Library={LocomotionRules=Rules,CharacterVoice=Voice}}
    local RS={}
    function RS:WaitForChild() return Shared end
    local services={Players={LocalPlayer=player},UserInputService=UIS,RunService=RunService,ReplicatedStorage=RS}
    local game={}
    function game:GetService(name) return services[name] end
    return {game=game,Enum=Enum,require=function(module) return module end,tick=os.clock,
        player=player,character=character,humanoid=humanoid,icon=icon,voices=voices,
        setPressed=function(value) pressed=value end,runService=RunService}
end
