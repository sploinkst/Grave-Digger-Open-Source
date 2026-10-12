local RS = game:GetService("ReplicatedStorage")
local Assets = {}
function Assets.Find(name, roots, className)
	for _, root in ipairs(roots) do
		local direct = root:FindFirstChild(name)
		if direct and (not className or direct:IsA(className)) then return direct end
		for _, child in ipairs(root:GetDescendants()) do
			if child.Name == name and (not className or child:IsA(className)) then return child end
		end
	end
	return nil
end
function Assets.Roots()
	local roots = {RS.Shared.Assets}
	if game:GetService("RunService"):IsServer() then table.insert(roots, game:GetService("ServerStorage")) end
	return roots
end
function Assets.Deployable(name)
	local folder = RS.Shared.Assets:FindFirstChild("deployables")
	return folder and folder:FindFirstChild(name)
end
-- The UI library is the sole source; the old StarterGui main is retired.
function Assets.PlayerGui()
 local player=game:GetService("Players").LocalPlayer
 return player and player:FindFirstChildOfClass("PlayerGui")
end
function Assets.Screen(name)
 local gui=Assets.PlayerGui()
 return gui and gui:FindFirstChild(name)
end
Assets.WidgetPaths={
 inventory={"Inventory","inventory"}, voicewheel={"VoiceWheel","Holder"},
 deathscreen={"Spectate","Holder"}, playerlist={"Playerlist","playerlist"},
 playerlistdarken={"Playerlist","playerlistdarken"}, scoreframe={"Scoring","scoreframe"},
 objpopup={"Scoring","objpopup"}, fadetoblack={"Black","fadetoblack"},
 alert={"Alerts","alert"}, flinch={"Flinching","flinch"},
 customchat={"Chat","ChatFrame"},
}
function Assets.Widget(name)
 local extras=Assets.CoreGame()
 local extra=extras and extras:FindFirstChild(name)
 if extra then return extra end
 local path=Assets.WidgetPaths[name]
 if not path then
  local gui=Assets.PlayerGui()
  if not gui then return nil end
  for _,screen in ipairs(gui:GetChildren()) do
   if screen:IsA("ScreenGui") and screen.Name~="main" then
    local item=screen:FindFirstChild(name,true)
    if item then return item end
   end
  end
  return nil
 end
 local node=Assets.PlayerGui()
 for _,part in ipairs(path) do node=node and node:FindFirstChild(part) end
 return node
end
function Assets.MainGui() return nil end
function Assets.CoreGame()
 local screen=Assets.Screen("Extras")
 return screen and screen:IsA("ScreenGui") and screen or nil
end
return Assets
