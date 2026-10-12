-- Runtime adapter for the supplied cosmetics master; operates on clones only.
local RS = game:GetService("ReplicatedStorage")
local Ids = require(script.Parent.WeaponIds)
local Rules = require(script.Parent.WeaponModModelRules)
local Cosmetics = {accessories={}, languages_empire={}, languages_nation={}, hats={}, nation_officerhats={}, model_replacements={}, skins={}}
local function named(parent, name)
 if typeof(parent) ~= "Instance" or type(name) ~= "string" then return nil end
 for _, child in ipairs(parent:GetChildren()) do
  if child.Name:lower() == name:lower() then return child end
 end
end
local function outfits() return named(RS.Shared.Assets,"outfits") or named(RS,"outfits") end
function Cosmetics.SkinAssets()
 local assets=RS.Shared.Assets
 return named(named(assets,"Guns"),"Skins") or named(assets,"WeaponSkins") or named(assets,"weapon_skins") or named(RS,"weapon_skins")
end
function Cosmetics.SelectedSkin(player, weapon, slot)
 local root=player and player:FindFirstChild("PlayerData")
 local data=root and root:FindFirstChild("PlayerData")
 local skins=named(data,"Skins") or named(root,"Skins") or named(player,"Skins")
 local family=Ids.AssetName(weapon)
 local canonical=Ids.Canonical(weapon)
 local source=Ids.MasterSourceName(weapon)
 local value=skins and (named(skins,source..tostring(slot or 1)) or named(skins,family..tostring(slot or 1)) or named(skins,canonical..tostring(slot or 1)) or named(skins,canonical) or named(skins,family))
 return value and value:IsA("StringValue") and value.Value or "stock"
end
function Cosmetics.SkinModel(weapon, skin)
 local folder = Cosmetics.SkinAssets()
 local family = named(folder, Ids.MasterSourceName(weapon)) or named(folder, Ids.AssetName(weapon)) or named(folder, Ids.Canonical(weapon))
 local model = named(family, skin)
 return model and (model:IsA("Model") or model:IsA("BasePart") or model:IsA("Tool")) and model or nil
end
function Cosmetics:modify_variant(model, family)
 if model and family then Rules.Apply(model,family,true) end
end
function Cosmetics:add_sheath(character, family, skin, slot, team)
 local torso=character and character:FindFirstChild("Torso")
 if not torso then return nil end
 local folder=named(outfits(),"sheaths")
 local guns=named(RS.Shared.Assets,"Guns")
 folder=folder or named(guns,"Holsters")
 local name=skin == "stock" and (family..(team and team.Name == "Royal Nation" and "nation" or "empire")) or skin
 local source=(name and named(folder,name)) or named(folder,family) or named(folder,"sheath_"..family)
 if not source then return nil end
 local clone=source:Clone()
 local root=clone:IsA("BasePart") and clone or clone:FindFirstChild("hitbox",true) or (clone:IsA("Model") and clone.PrimaryPart)
 if not root then clone:Destroy(); return nil end
 local old=character:FindFirstChild("sheath_"..family)
 if old then old:Destroy() end
 clone.Name="sheath_"..family
 local removed=slot and clone:FindFirstChild("slot"..slot)
 if removed then removed:Destroy() end
 local delta=torso.CFrame*root.CFrame:Inverse()
 for _, part in ipairs({clone,table.unpack(clone:GetDescendants())}) do
  if part:IsA("BasePart") then
   part.CFrame=delta*part.CFrame; part.Anchored=false; part.CanCollide=false; part.Massless=true
  end
 end
 local weld=Instance.new("Weld"); weld.Part0=torso; weld.Part1=root; weld.Parent=root
 clone.Parent=character
 return clone
end
function Cosmetics:add_accessory(character, name, team, override)
 local source=named(named(outfits(),"accessories"),name)
 local limb=source and source:FindFirstChild("limb")
 local anchor=character and limb and character:FindFirstChild(override or limb.Value)
 if not source or not source:IsA("BasePart") or not anchor or not anchor:IsA("BasePart") then return nil end
 local container=character:FindFirstChild("accessories")
 if not container then container=Instance.new("Folder"); container.Name="accessories"; container.Parent=character end
 local clone=source:Clone(); clone:SetAttribute("CosmeticAppearance",true)
 clone.Transparency=1
 if override then clone.limb.Value=override end
 if name=="prosthetic" then
  if anchor:GetAttribute("CosmeticOriginalTransparency")==nil then anchor:SetAttribute("CosmeticOriginalTransparency",anchor.Transparency) end
  anchor.Transparency=1
 end
 local class=character:FindFirstChild("class")
 local jaeger=character:GetAttribute("Class")=="Jaeger" or (class and class.Value=="jaeger")
 local bullets=clone:FindFirstChild("bullets")
 if jaeger and bullets and bullets:IsA("BasePart") then bullets.Color=Color3.fromRGB(68,121,51); bullets.Material=Enum.Material.Granite end
 local opposite=clone:FindFirstChild(team and team.Name=="Golden Empire" and "nation" or "empire")
 if clone:FindFirstChild("nation") and clone:FindFirstChild("empire") and opposite then opposite:Destroy() end
 local weld=Instance.new("Weld"); weld.Name="accessoryweld"; weld.Part0=anchor; weld.Part1=clone
 if name=="puttee" and override then weld.C1=CFrame.Angles(0,math.pi,0) end
 local delta=anchor.CFrame*weld.C1:Inverse()*clone.CFrame:Inverse()
 for _, part in ipairs({clone,table.unpack(clone:GetDescendants())}) do
  if part:IsA("BasePart") then part.CFrame=delta*part.CFrame; part.Anchored=false; part.CanCollide=false; part.Massless=true end
 end
 weld.Parent=clone; clone.Parent=container
 if (name=="spurs" or name=="puttee") and not override then self:add_accessory(character,name,team,"Right Leg") end
 return clone
end
Cosmetics.accessories.medal = "Veterancy Medals"
Cosmetics.accessories.prosthetic = "Prosthetic Leg"
Cosmetics.accessories.rosary = "Rosary Beads (Left)"
Cosmetics.accessories.rosaryright = "Rosary Beads (Right)"
Cosmetics.accessories.armbandage = "Shoulder Bandage (Left)"
Cosmetics.accessories.armbandageright = "Shoulder Bandage (Right)"
Cosmetics.accessories.bandolier = "Shotgun Bandolier"
Cosmetics.accessories.riflebandolier = "Ammo Bandolier"
Cosmetics.accessories.watch = "Trench Watch (Right)"
Cosmetics.accessories.watchleft = "Trench Watch (Left)"
Cosmetics.accessories.lucky = "Lucky Cards (Right)"
Cosmetics.accessories.luckyleft = "Lucky Cards (Left)"
Cosmetics.accessories.canteen = "Canteen Carrier"
Cosmetics.accessories.badge = "Service Badge"
Cosmetics.accessories.cape = "Rain Cape"
Cosmetics.accessories.crutches = "Crutches Strap"
Cosmetics.accessories.sling = "Generic Sling"
Cosmetics.accessories.glove = "Shooting Glove (Right)"
Cosmetics.accessories.gloveleft = "Shooting Glove (Left)"
Cosmetics.accessories.spurs = "Riding Spurs"
Cosmetics.accessories.waistbelt = "Waist Bandolier"
Cosmetics.accessories.flower = "Handcrafted Flower"
Cosmetics.accessories.handwrapsleft = "Hand Wraps (Left)"
Cosmetics.accessories.handwrapsright = "Hand Wraps (Right)"
Cosmetics.accessories.puttee = "Puttee Wraps"
Cosmetics.languages_empire.british = "<font color=\"#ffff7f\">English / British</font>"
Cosmetics.languages_empire.german = "<font color=\"#ffff7f\">German / Deutsch</font>"
Cosmetics.languages_empire.russian = "<font color=\"#ffff7f\">Russian / \208\160\209\131\209\129\209\129\208\186\208\184\208\185</font>"
Cosmetics.languages_nation.american = "<font color=\"#aa00ff\">English / American</font>"
Cosmetics.languages_nation.brazil = "<font color=\"#aa00ff\">Portuguese / Portugu\195\170s</font>"
Cosmetics.languages_nation.polish = "<font color=\"#aa00ff\">Polish / Polski</font>"
Cosmetics.hats.officerone = "Plumed Hat"
Cosmetics.hats.officertwo = "Peaked Cap"
Cosmetics.hats.officerthree = "Shako Cap"
Cosmetics.nation_officerhats.officerone = "Tarte Beret"
Cosmetics.nation_officerhats.officertwo = "Pith Hat"
Cosmetics.nation_officerhats.officerthree = "Kepi Cap"
Cosmetics.model_replacements.knife = true
Cosmetics.model_replacements.club = true
Cosmetics.model_replacements.cavsword = true
Cosmetics.model_replacements.pickaxe = true
Cosmetics.model_replacements.pick = true
local special = {shortbarrel=true,shortlever=true,extendmag=true,bipod1=true,bipod2=true,bipod3=true,bipod4=true,halesight1=true,halesight2=true,halesight3=true,longbarrel=true,longbarrelwood=true,longbarrelwoodscrew=true,longstock=true,longstockplate=true,steyrstock1=true,steyrstock2=true,steyrstock3=true,steyrstock4=true,shortcap=true,shorthandguard=true}
local function palette(model)
 local result={}
 for _, part in ipairs(model:GetDescendants()) do
  local parent=part.Parent
  local grandparent=parent and parent.Parent
  if part:IsA("BasePart") and (special[part.Name] or (part.Transparency~=1 and parent and parent.Name~="extra" and (not grandparent or grandparent.Name~="extra"))) then
   result[part.Name]=part.Color; result[part.Name.."_mat"]=part.Material
  end
 end
 return result
end
Cosmetics.apply_skin = function(p25, p26, p27, p28) --[[ Line: 353 ]]
    --[[ Upvalues: (copy 1): Cosmetics, (copy 2): palettes ]]
    if Cosmetics.model_replacements[p26] ~= true then
        local family = named(Cosmetics.SkinAssets(), p26)
        local template = named(family, p27)
        local v29 = template and palette(template)
        if v29 then
            local v30 = named(Cosmetics.SkinAssets(), p26)
            local v31 = false
            if v30 then
                v30 = named(v30, p27)
                v31 = v30 and v30:FindFirstChild("snub") and true or v31
                if not v30 or v30:FindFirstChild("extra") == nil or v30:FindFirstChild("hitbox") == nil then
                    v30 = nil
                end;
            end;
            for _, v32 in ipairs(p25:GetDescendants()) do
                if v32:IsA("BasePart") and v29[v32.Name] then
                    v32.Color = v29[v32.Name]
                    v32.Material = v29[v32.Name .. "_mat"]
                end;
            end;
            if v31 == true and (p25:FindFirstChild("parts") and (p25.parts:FindFirstChild("break") and p25.parts:FindFirstChild("snubtrigger"))) then
                p25.parts.snubtrigger.Transparency = 0
                p25.parts["break"].Transparency = 1
                p25.parts["break"].sights.Transparency = 1
                p25.parts["break"].snubbarrel.Transparency = 0
                p25.parts["break"].snubsights.Transparency = 0
                if p25.parts:FindFirstChild("special") and (p25.parts.special:FindFirstChild("altmuzzle") and p25.parts.special:FindFirstChild("muzzle")) then
                    p25.parts.special.muzzle:Destroy()
                    p25.parts.special.altmuzzle.Name = "muzzle"
                end;
            end;
            if v30 then
                local v33 = p25:FindFirstChild("unequipped") or p25:FindFirstChild("hitbox")
                if not v33 or not v33:IsA("BasePart") then return end
                local old = p25:FindFirstChild("accessorypart")
                if old then old:Destroy() end
                local v34 = v30:Clone()
                for _, part in ipairs(v34:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "hitbox" and not part:IsDescendantOf(v34.extra) then part:Destroy() end
                end
                local delta = v33.CFrame * v34.hitbox.CFrame:Inverse()
                for _, part in ipairs(v34:GetDescendants()) do
                    if part:IsA("BasePart") then part.CFrame=delta*part.CFrame; part.Anchored=false; part.CanCollide=false; part.Massless=true end
                end
                if v34:FindFirstChild("recolour") then
                    v34.recolour:Destroy()
                end;
                v34.hitbox.CFrame = v33.CFrame
                v34.hitbox.Name = "accessory"
                v34.Name = "accessorypart"
                local l_Weld_2 = Instance.new("Weld")
                l_Weld_2.Part0 = v34.accessory
                l_Weld_2.Part1 = v33
                l_Weld_2.Parent = v34
                v34.Parent = p25
                for _, v35 in ipairs(v34.extra:GetChildren()) do
                    if v35:IsA("BasePart") then
                        if (v35.Name == "spareammo1A" or v35.Name == "spareammo2A") and (p28 and (((p28:FindFirstChild("class") and p28.class.Value == "jaeger") or p28:GetAttribute("Class") == "Jaeger"))) then
                            v35.Color = Color3.fromRGB(68, 121, 51)
                            v35.Material = Enum.Material.Granite
                        end;
                        if v35.Name == "knellsuppressor" and (p25:FindFirstChild("body") and p25.body:FindFirstChild("suppressor") == nil) then
                            v35:Destroy()
                        end;
                        if v35.Name == "reaperfront" and (p25:FindFirstChild("body") and p25.body:FindFirstChild("handguard") == nil) then
                            v35:Destroy()
                        end;
                        if v35.Name == "volkscopeghillie" and (p25:FindFirstChild("body") and p25.body:FindFirstChild("scope") == nil) then
                            v35:Destroy()
                        end;
                    end;
                    if v35:FindFirstChild("weldto") and (v35.weldto:IsA("StringValue") and p25:FindFirstChild("parts")) then
                        local v36 = p25.parts:FindFirstChild(v35.weldto.Value)
                        if v36 then
                            local l_Weld_3 = Instance.new("Weld")
                            l_Weld_3.Name = "weldtoweld"
                            l_Weld_3.Part0 = v35
                            l_Weld_3.Part1 = v36
                            l_Weld_3.Parent = v34
                        end;
                        if v35:FindFirstChild("dbfrontbarrelgilding") and (p25:FindFirstChild("parts") and (p25.parts:FindFirstChild("barrel") and p25.parts.barrel.Transparency == 1)) then
                            v35.dbfrontbarrelgilding:Destroy()
                        end;
                    end;
                end;
            end;
        end;
    end;
end;
Cosmetics.skins.pieper = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Saintly",
        ["int"] = "saint",
        ["col"] = Color3.fromRGB(231, 231, 236),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.springfield = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Stalker",
        ["int"] = "stalker",
        ["col"] = Color3.fromRGB(35, 40, 35),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.rsc = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Memory",
        ["int"] = "memory",
        ["col"] = Color3.fromRGB(205, 205, 205),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.autosg = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Reaper",
        ["int"] = "reaper",
        ["col"] = Color3.fromRGB(54, 54, 54),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.henry = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "War-torn",
        ["int"] = "wartorn",
        ["col"] = Color3.fromRGB(160, 132, 79),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.saa = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Pearl",
        ["int"] = "pearl",
        ["col"] = Color3.fromRGB(241, 231, 199),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.mpistol = {
    {
        ["name"] = "Forlorn Hope",
        ["int"] = "forlorn",
        ["col"] = Color3.fromRGB(254, 243, 187),
        ["kill_req"] = 1911
    }
}
Cosmetics.skins.remington = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Bandit",
        ["int"] = "bandit",
        ["col"] = Color3.fromRGB(159, 161, 172),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.lebel = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Liberty",
        ["int"] = "liberty",
        ["col"] = Color3.fromRGB(202, 203, 209),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    },
    {
        ["name"] = "Escape",
        ["int"] = "sling",
        ["col"] = Color3.fromRGB(125, 123, 94),
        ["kill_req"] = 17,
        ["spec"] = "special_rifle"
    }
}
Cosmetics.skins.dbgun = {
    {
        ["name"] = "Silver Steel",
        ["int"] = "silversteel",
        ["col"] = Color3.fromRGB(202, 203, 209),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Patina",
        ["int"] = "patina",
        ["col"] = Color3.fromRGB(226, 155, 64),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.crossbow = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Divinity",
        ["int"] = "divinity",
        ["col"] = Color3.fromRGB(202, 203, 209),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.walker = {
    {
        ["name"] = "Silver Steel",
        ["int"] = "silversteel",
        ["col"] = Color3.fromRGB(202, 203, 209),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Rangers",
        ["int"] = "ranger",
        ["col"] = Color3.fromRGB(226, 155, 64),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.enfield = {
    {
        ["name"] = "Silver Steel",
        ["int"] = "silversteel",
        ["col"] = Color3.fromRGB(202, 203, 209),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Jaeger",
        ["int"] = "jaeger",
        ["col"] = Color3.fromRGB(27, 42, 53),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.lever = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Yellowboy",
        ["int"] = "yellowboy",
        ["col"] = Color3.fromRGB(245, 205, 48),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.mares = {
    {
        ["name"] = "Black Steel",
        ["int"] = "blacksteel",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Conflict",
        ["int"] = "conflict",
        ["col"] = Color3.fromRGB(74, 42, 42),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.mauser = {
    {
        ["name"] = "Silver Steel",
        ["int"] = "silversteel",
        ["col"] = Color3.fromRGB(202, 203, 209),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Pearl",
        ["int"] = "pearl",
        ["col"] = Color3.fromRGB(241, 231, 199),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.scho = {
    {
        ["name"] = "Silver Steel",
        ["int"] = "silversteel",
        ["col"] = Color3.fromRGB(202, 203, 209),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Patina",
        ["int"] = "patina",
        ["col"] = Color3.fromRGB(226, 155, 64),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    },
    {
        ["name"] = "Snub",
        ["int"] = "snub",
        ["col"] = Color3.fromRGB(15, 24, 30),
        ["kill_req"] = 0,
        ["spec"] = "snub_scho"
    }
}
Cosmetics.skins.mosin = {
    {
        ["name"] = "Silver Steel",
        ["int"] = "silversteel",
        ["col"] = Color3.fromRGB(202, 203, 209),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Wolf-skin",
        ["int"] = "wolf",
        ["col"] = Color3.fromRGB(210, 209, 213),
        ["kill_req"] = 400
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.steyr = {
    {
        ["name"] = "Silver Steel",
        ["int"] = "silversteel",
        ["col"] = Color3.fromRGB(202, 203, 209),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Blued",
        ["int"] = "blued",
        ["col"] = Color3.fromRGB(93, 133, 148),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Gilded",
        ["int"] = "gilded",
        ["col"] = Color3.fromRGB(248, 217, 109),
        ["kill_req"] = 1000
    }
}
Cosmetics.skins.cavsword = {
    {
        ["name"] = "Patton",
        ["int"] = "patton",
        ["col"] = Color3.fromRGB(27, 42, 53),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Hastings",
        ["int"] = "hasting",
        ["col"] = Color3.fromRGB(231, 231, 236),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Gunto",
        ["int"] = "gunto",
        ["col"] = Color3.fromRGB(239, 184, 56),
        ["kill_req"] = 500
    },
    {
        ["name"] = "War-bringer",
        ["int"] = "civil",
        ["col"] = Color3.fromRGB(27, 42, 53),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Trench",
        ["int"] = "trenchsword",
        ["col"] = Color3.fromRGB(59, 45, 37),
        ["kill_req"] = 0,
        ["spec"] = "trench_sword"
    }
}
Cosmetics.skins.knife = {
    {
        ["name"] = "Imperial",
        ["int"] = "german",
        ["col"] = Color3.fromRGB(86, 66, 54),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Bayonet",
        ["int"] = "bayo",
        ["col"] = Color3.fromRGB(231, 231, 236),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Clouer",
        ["int"] = "nail",
        ["col"] = Color3.fromRGB(50, 51, 53),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Testament",
        ["int"] = "cross",
        ["col"] = Color3.fromRGB(215, 197, 154),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Sacrifice",
        ["int"] = "french",
        ["col"] = Color3.fromRGB(231, 231, 236),
        ["kill_req"] = 2,
        ["spec"] = "special_knife"
    }
}
Cosmetics.skins.pick = {
    {
        ["name"] = "Special",
        ["int"] = "specpick",
        ["col"] = Color3.fromRGB(86, 66, 54),
        ["kill_req"] = 0,
        ["spec"] = "early"
    }
}
Cosmetics.skins.pickaxe = {
    {
        ["name"] = "Ice-axe",
        ["int"] = "ice",
        ["col"] = Color3.fromRGB(159, 161, 172),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Gold-rush",
        ["int"] = "gold",
        ["col"] = Color3.fromRGB(56, 51, 50),
        ["kill_req"] = 500
    }
}
Cosmetics.skins.club = {
    {
        ["name"] = "Flanged",
        ["int"] = "makeshift",
        ["col"] = Color3.fromRGB(108, 88, 75),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Studded",
        ["int"] = "stud",
        ["col"] = Color3.fromRGB(86, 66, 54),
        ["kill_req"] = 100
    },
    {
        ["name"] = "Dud",
        ["int"] = "grenade",
        ["col"] = Color3.fromRGB(72, 91, 78),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Shovel",
        ["int"] = "shovel",
        ["col"] = Color3.fromRGB(99, 95, 98),
        ["kill_req"] = 500
    },
    {
        ["name"] = "Pipe",
        ["int"] = "pipe",
        ["col"] = Color3.fromRGB(231, 231, 236),
        ["kill_req"] = 0,
        ["spec"] = "special_club"
    }
}
return Cosmetics
