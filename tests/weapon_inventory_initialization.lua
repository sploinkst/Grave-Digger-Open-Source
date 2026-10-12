local f=assert(io.open('sync/ReplicatedStorage/Shared/Library/Classes/BaseTool.luau','rb'))
local source=f:read('*a');f:close()
local body=assert(source:match('(function BaseTool:on_give.-)\n\t%-%- These are replicated'))
body=body:gsub('tool: Tool, holster: Model%?, model: Model%?','tool, holster, model')..'\nend'
local binding,warnings=nil,0
local library={FindFirstChild=function() return binding end}
local env=setmetatable({BaseTool={},WeaponIds={MasterSourceName=function() return 'mosin' end},
 script={Parent={Parent=library}},warn=function() warnings=warnings+1 end,
 require=function() return binding.api end}, {__index=_G})
assert(load(body,'weapon inventory initialization','t',env))()
local function initialize()
 local controller=setmetatable({className='VolkRifle',IsFirearm=true,_applyWeaponWelds=function() end},{__index=env.BaseTool})
 local tool={};controller:on_give(tool)
 assert(controller.tool==tool and type(controller.animations)=="table")
end
env.BaseTool.animations="BrowningMachineGun"
initialize();assert(warnings==1)
binding={IsA=function() return true end,api={Prepare=function() error('broken binding') end}}
initialize();assert(warnings==2)
local prepared=0;binding.api.Prepare=function() prepared=prepared+1 end
initialize();assert(prepared==1 and warnings==2)
print('Weapon inventory initialization: missing and failing animation bindings retain tool registration; available bindings prepare normally')
