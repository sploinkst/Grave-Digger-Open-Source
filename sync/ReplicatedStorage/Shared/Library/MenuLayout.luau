local Assets = require(script.Parent.AuthoredAssets)
local Layout = {}
Layout.Panels = {Loadout="customisationframe", Appearance="cosmeticsframe", Settings="settingsframe", Servers="serversframe", Credits="creditsframe"}
Layout.Buttons = {}
for scene, panel in pairs(Layout.Panels) do Layout.Buttons[panel] = scene; Layout.Buttons[scene] = scene end
function Layout.Container()
 return nil -- Library.UI/Menu and Menu_Scenes own navigation.
end
function Layout.Scene(name)
 local menu = Layout.Container()
 if menu and Layout.Panels[name] and menu:FindFirstChild(Layout.Panels[name]) then return menu end
 local player = game:GetService("Players").LocalPlayer
 local gui = player and player:FindFirstChildOfClass("PlayerGui")
 local scenes = gui and gui:FindFirstChild("Menu_Scenes")
 return scenes and scenes:FindFirstChild(name)
end
function Layout.Panel(name)
 local scene = Layout.Scene(name)
 return scene and (scene:FindFirstChild(Layout.Panels[name]) or scene:FindFirstChild("Main_Frame"))
end
return Layout
