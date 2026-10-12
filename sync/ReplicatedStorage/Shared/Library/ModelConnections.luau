-- Resolve authored model joints without requiring a live physics assembly.
local Connections = {}
function Connections.Parts(model)
 local parts = {}
 if model:IsA("BasePart") then table.insert(parts,model) end
 for _, item in ipairs(model:GetDescendants()) do
  if item:IsA("BasePart") then table.insert(parts,item) end
 end
 return parts
end
function Connections.From(model, root)
 local allowed, edges = {}, {}
 for _, part in ipairs(Connections.Parts(model)) do allowed[part]=true; edges[part]={} end
 for _, joint in ipairs(model:GetDescendants()) do
  if joint:IsA("JointInstance") or joint:IsA("WeldConstraint") then
   local a,b=joint.Part0,joint.Part1
   if allowed[a] and allowed[b] then table.insert(edges[a],b); table.insert(edges[b],a) end
  elseif joint:IsA("RigidConstraint") then
   local a=joint.Attachment0 and joint.Attachment0.Parent
   local b=joint.Attachment1 and joint.Attachment1.Parent
   if allowed[a] and allowed[b] then table.insert(edges[a],b); table.insert(edges[b],a) end
  end
 end
 local connected, queue = {[root]=true}, {root}
 local index=1
 while index<=#queue do
  local current=queue[index]; index=index+1
  for _, nextPart in ipairs(edges[current] or {}) do
   if not connected[nextPart] then connected[nextPart]=true; table.insert(queue,nextPart) end
  end
 end
 return connected
end
return Connections
