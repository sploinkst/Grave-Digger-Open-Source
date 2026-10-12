-- GUI-only portions of the GUI and character masters, owned by GameplayPresentationService.
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local Assets = require(RS.Shared.Library.AuthoredAssets)
local Settings = require(script.Parent.Parent.SettingsManager)
local Base = require(RS.Shared.Library.MasterReference.Base)
local Tween = game:GetService("TweenService")
local player = Players.LocalPlayer
local Hud = {}
local mapRows, voteBusy = {}, false
local function text(root, name, value)
 local label = root and root:FindFirstChild(name, true)
 if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then label.Text=tostring(value or "") end
end
local function visible(root, name, value)
 local item=root and root:FindFirstChild(name)
 if item and item:IsA("GuiObject") then item.Visible=value end
 return item
end
local function read(root, name, fallback)
 local item=root and root:FindFirstChild(name)
 return item and item:IsA("ValueBase") and item.Value or fallback
end
function Hud.Refresh()
 local menu=Assets.Screen("Menu")
 local data=player:FindFirstChild("PlayerData")
 local profile=data and data:FindFirstChild("PlayerData")
 local progress=profile and profile:FindFirstChild("Progression")
 if menu and progress then
  local seconds=read(progress,"PlaySeconds",0)
  text(menu,"rank",read(progress,"Rank",0));text(menu,"medalcount",read(progress,"Medals",0))
  text(menu,"timeplayed",string.format("%dh %dm",math.floor(seconds/3600),math.floor(seconds/60)%60))
  local bar=menu:FindFirstChild("xpbar",true)
  local fill=bar and bar:FindFirstChild("internal")
  if fill then fill.Size=UDim2.fromScale((read(progress,"Duty",0)%(Base.level_req or 200))/(Base.level_req or 200),1) end
 end
 -- Scoring labels remain owned by ReplicantService.
 local hint=Assets.Widget("hint_popup")
 if hint then hint.Visible=hint:GetAttribute("HintUntil")~=nil and os.clock()<hint:GetAttribute("HintUntil") and not Settings.GetSetting("disablehints") end
end
function Hud.Present(action,payload)
 if type(payload)~="table" then return end
 local main,core=Assets.MainGui(),Assets.CoreGame()
 if action=="hint" then
  local hint=Assets.Widget("hint_popup")
  if hint then hint.Text=tostring(payload.message or "");hint:SetAttribute("HintUntil",os.clock()+(tonumber(payload.duration) or 5)) end
 elseif action=="game_brief" then
  if not core then return end
  text(core,"gamemode_title",payload.title);text(core,"gamemode_description",payload.description);text(core,"gamemode_label",payload.mode)
  local generation=os.clock();core:SetAttribute("BriefGeneration",generation)
  for _,name in ipairs({"gamemode_title","gamemode_description","gamemode_label"}) do visible(core,name,not Settings.GetSetting("hidegamemodebrief")) end
  task.delay(tonumber(payload.duration) or 6,function()
   if core.Parent and core:GetAttribute("BriefGeneration")==generation then for _,name in ipairs({"gamemode_title","gamemode_description","gamemode_label"}) do visible(core,name,false) end end
  end)
 elseif action=="tutorial_control" then
  local holder=core and core:FindFirstChild("tutorialcontrols");local template=holder and holder:FindFirstChild("ex")
  if not template then return end
  local name=tostring(payload.input or "control")
  local row=holder:FindFirstChild("Master_"..name)
  if not row then row=template:Clone();row.Name="Master_"..name;row.Parent=holder end
  row.Text="["..Settings.GetKey(name).Name.."] - "..tostring(payload.message or "")
  row.Visible=payload.visible~=false;holder.Visible=true
 elseif action=="tutorial_objective" then
  local panel=visible(core,"tutorialobj",payload.visible~=false)
  text(panel,"label",payload.message);text(panel,"objtext",payload.message);text(panel,"tuttext",payload.message)
 elseif action=="dogtag" or action=="dogtag_got" then
  local holder=core and core:FindFirstChild("dogtags");local template=holder and holder:FindFirstChild("ex")
  if not template then return end
  local old=holder:FindFirstChild("MasterDogtag");if old then old:Destroy() end
  local row=template:Clone();row.Name="MasterDogtag";row.Visible=true;row.Parent=holder;holder.Visible=true
  text(row,"name",payload.name or payload.message);text(row,"rank",payload.rank);text(row,"age",payload.age and ("Age "..payload.age) or "")
  task.delay(tonumber(payload.duration) or 5,function() row:Destroy() end)
 elseif action=="match_end" or action=="truce_end" or action=="game_end" then
  local name=action=="match_end" and "endofmatch" or action=="truce_end" and "endoftruce" or "endofgame"
  local panel=visible(core,name,true)
  if panel then
   for _, label in ipairs(panel:GetDescendants()) do
    local value=payload[label.Name]
    if value~=nil and (label:IsA("TextLabel") or label:IsA("TextButton")) then label.Text=tostring(value) end
   end
   task.delay(tonumber(payload.duration) or 8,function() if panel.Parent then panel.Visible=false end end)
  end
 elseif action=="campaign" then
  local map=Assets.Widget("warmap")
  if map then map.Visible=payload.visible~=false end
  if not map then return end
  if payload.visible ~= false then game:GetService("UserInputService").MouseBehavior=Enum.MouseBehavior.Default;game:GetService("UserInputService").MouseIconEnabled=true end
  local side=map:FindFirstChild("modeside")
  for _,name in ipairs({"campaignname","gamemode","desc","extra","mutatortitle","mutatordesc","teamvoting"}) do text(side,name,payload[name]) end
  local nodes=map:FindFirstChild("nodes");local template=nodes and nodes:FindFirstChild("ex")
  if template and type(payload.choices)=="table" then
   template.Visible=false
   local active={}
   for index,choice in ipairs(payload.choices) do
    if type(choice.id)=="string" then
     active[choice.id]=true
     local row=mapRows[choice.id]
     if not row or row.Parent~=nodes then
      row=template:Clone();row.Name="MasterVote_"..choice.id;row.Visible=true;row.Parent=nodes;mapRows[choice.id]=row
      row.Position=UDim2.fromScale(((index-1)%5)*0.18,math.floor((index-1)/5)*0.22)
      row.Activated:Connect(function()
       if voteBusy then return end;voteBusy=true
       RS.Shared.Library.Events.MatchControl:FireServer("VoteMap",choice.id)
       for id,entry in pairs(mapRows) do visible(entry,"selected",id==choice.id);visible(entry,"voted",id==choice.id) end
       task.delay(0.3,function() voteBusy=false end)
      end)
     end
     text(row,"votes",choice.votes);text(row,"clickvote",choice.name or choice.id)
    end
   end
   for id,row in pairs(mapRows) do if not active[id] then row:Destroy();mapRows[id]=nil end end
  end
 end
end
function Hud.Start()
 if Hud.started then return end;Hud.started=true
 local elapsed=0
 Run.Heartbeat:Connect(function(dt) elapsed=elapsed+dt;if elapsed>=0.2 then elapsed=0;Hud.Refresh() end end)
 RS.Shared.Library.Events:WaitForChild("Presentation").OnClientEvent:Connect(Hud.Present)
 task.defer(function() RS.Shared.Library.Events:WaitForChild("MatchControl"):FireServer("CampaignState") end)
 local function characterAdded()
  local main,core=Assets.MainGui(),Assets.CoreGame()
  if core then
   for _,name in ipairs({"endofmatch","endoftruce","endofgame","tutorialcontrols","tutorialobj"}) do visible(core,name,false) end
  end
  local fade=Assets.Widget("fadetoblack")
  if fade then
   fade.Visible=true;fade.BackgroundTransparency=0
   local animation=Tween:Create(fade,TweenInfo.new(1),{BackgroundTransparency=1})
   animation.Completed:Once(function() if fade.Parent then fade.Visible=false end end)
   animation:Play()
  end

  local map=Assets.Widget("warmap");if map then map.Visible=false end
 end
 player.CharacterAdded:Connect(characterAdded)
 if player.Character then characterAdded() end
end
return Hud
