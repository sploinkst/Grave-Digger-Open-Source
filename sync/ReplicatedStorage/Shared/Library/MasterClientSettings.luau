-- Original master names resolve to the existing replicated settings contract.
local Settings = {}
Settings.Names = {
 toggleskins="WeaponSkins", lowgraphics="Graphics/FX", disablevfx="WeaponEffects",
 disablegore="GibEffects", disablebullettrails="BulletTrail", disablebloodbody="BloodCharacters",
 disableblood="FloorBlood", togglesprint="ToggleSprint", toggleads="ToggleAim",
 removehats="HelmetAccessories", reducegunvolume="FirearmVolume", qprimeknell="AltPrimeKnellHammer",
 pedersenstart="WhisperAutoLoader", oldmortselection="OldMortSelection", oldeliteorder="OldShockKitSelection",
 mutemusic="MuteMusic", eliteskipdread="DreadNoughtShockTrooperSkip", eliteopt="OptOutEliteReinSel",
 elitekitselection="AutoShock", dreadopt="OptOutDreadnought", disabledeathyells="DisableDeathRattles",
 disablebodyshoot="DisableBodyShooting", disableakimboreloads="DisableAmbdiSwapReload", alwaysshowlance="DisableTranHeavyLance",
 languagevoices="UntranslatedVoiceComms", hidecrosshair="HideCrosshair", hideallclassicons="HideTeammateClassIcons",
 disableobstruction="DisableObstructedBarrelMuzzle", disableinteractionhighlight="DisableInteractHighlight",
 disablehighlightconstructs="Disable Trap and Construct Highlighting", disablehairs="DisableHairs",
 autofirstperson="AutomaticFirstPerson", transpcrosshair="TransCrosshair", staticcrosshair="StaticCrosshair",
 muteofficers="MuteOfficerPings", longrangeobstruction="ExtendBarrelOb", hiderequests="RequestPopUpsHide",
 hidegamemodebrief="HideGameModeBrief", hideextendedicons="HideDistantTeammateIcons", hidechat="HideChat",
 disablevolkscope="DisplayVolkPhysicalScope", disablehints="HideHintPopups", disabledangerpings="HideDangerPings",
 disablebloodscreen="HideBloodSmear", disabletransparent="DisableTransparent", leaningtilt="LeaningTilt",
 dynamicreverb="DynamicReverb", laserobstruction="LaserObstruction",
}
Settings.Binds = {
 alt="Alternate Action", checkammo="Check Ammo", cleanface="Wipe Face", crouch="Crouch",
 dropweapon="Emergency Reload Drop", equipment="Class Equipment", firstperson="First Person",
 flipcam="Flip Camera", hidehud="Hide Hud", menu="Menu", sprint="Sprint", playerlist="Player List",
 reload="Reload", reset="Reset Character", shiftlock="Shift Lock", spectateleft="Spectate Left",
 spectateright="Spectate Right", swapteam="Swap Team", viewobj="View Objectives", voicelines="Voice Lines", vc="Voice Lines",
}
local function normalize(name) return tostring(name):lower():gsub("[^%w]", "") end
function Settings.Find(data, name)
 if not data then return nil end
 local wanted = normalize(Settings.Names[name] or name)
 for _, child in ipairs(data:GetDescendants()) do
  if normalize(child.Name) == wanted then
   local current = child:FindFirstChild("Current")
   if current and current:IsA("ValueBase") then return current end
  end
 end
end
function Settings.Read(data, name, default)
 local current = Settings.Find(data, name)
 if current then return current.Value end
 return default == nil and false or default
end
function Settings.BindName(name) return Settings.Binds[name] or name end
return Settings
