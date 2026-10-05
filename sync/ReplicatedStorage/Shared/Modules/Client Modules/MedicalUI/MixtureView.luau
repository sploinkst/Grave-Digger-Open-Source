-- Chemical choices clone main.core_game.selectionboxes.selections.ex.
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Rules = require(RS.Shared.Library.ChemicalRules)
local Selection = require(script.Parent.Parent.MasterUI.SelectionView)
local View = {}; View.__index = View
function View.new(onMix, canSelect, onClose)
 local self=setmetatable({OnMix=onMix,CanSelect=canSelect,Selecting=false},View)
 self.Selector=Selection.new(onMix,canSelect,"StimulantSelecting",function()
  self.Selecting=false; if onClose then onClose() end
 end)
 return self
end
function View:Show(character) self:Hide(); self.Character=character end
function View:CloseSelector() self.Selector:Close(); self.Selecting=false end
function View:ToggleSelector()
 if self.Selecting then self:CloseSelector(); return end
 local entries={}
 for _,name in ipairs(Rules.Order) do table.insert(entries,{id=name,name=name,icon=Rules.Definitions[name].icon}) end
 self.Selecting=self.Selector:Open(self.Character,entries)
end
function View:ToggleEffects()
 local ok,mix=pcall(HttpService.JSONDecode,HttpService,self.Character:GetAttribute("StimulantMixture") or "[]")
 if not ok then return end
 local lines={}
 for _,entry in ipairs(Rules.Summarize(mix)) do table.insert(lines,entry.name..": "..entry.units.."u ("..entry.duration.."s)") end
 if _G.popupmsg then _G.popupmsg("stimcontents",#lines>0 and table.concat(lines,"\n") or "The bottle is empty.",3) end
end
function View:Hide() self:CloseSelector() end
function View:Destroy() self:Hide(); self.Selector:Destroy() end
return View
