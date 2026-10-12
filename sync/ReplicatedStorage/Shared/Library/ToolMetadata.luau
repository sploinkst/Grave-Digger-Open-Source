local Metadata={}
Metadata.Designations={Primary="1",Secondary="2",Melee="3",Mining="4",Medkit="5"}
function Metadata.Weapon(tool)
 local value=tool:FindFirstChild("weapon")
 return value and value:IsA("StringValue") and value.Value~="" and value.Value or tool.Name
end
function Metadata.Slot(tool)
 local value=tool:FindFirstChild("slot")
 if not value or not value:IsA("ValueBase") then return nil,nil end
 local name=tostring(value.Value)
 local number=tonumber(name)
 if number and number==math.floor(number) and number>=0 and number<=9 then
  local key=tostring(number)
  local designation
  for category,slot in pairs(Metadata.Designations) do if slot==key then designation=category;break end end
  return key,designation or "Miscellaneous"
 end
 local aliases={primary="Primary",primarysling="Primary",secondary="Secondary",secondaryholster="Secondary",melee="Melee",meleesheath="Melee",mining="Mining",miningpickbelt="Mining",medkit="Medkit",firstaidpouch="Medkit",miscellaneous="Miscellaneous",equipment="Miscellaneous"}
 local designation=aliases[name:lower():gsub("[^%w]","")]
 return designation and Metadata.Designations[designation],designation
end
function Metadata.Hidden(tool)
 local marker=tool:FindFirstChild("no_backpack")
 return tool:GetAttribute("NoBackpack")==true or marker~=nil and (not marker:IsA("BoolValue") or marker.Value==true)
end
return Metadata
