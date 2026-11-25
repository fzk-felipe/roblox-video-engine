-- Clip: collision check. C.run(M, Ep, {from=,to=, ok={Name="pattern"}}) poses shots at a=0.1/0.5/0.9 and tests limbs.
-- Run in chunks of ~40 shots per execute_luau call; M.finalize() after. opt.ok whitelists e.g. {Nell="Armchair"} for seated actors.
local C = {}
local LIMBS = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","RightUpperLeg","RightLowerLeg"}
local function owner(p, Cast)
  local m = p
  for _ = 1, 12 do
    if not m or m.Parent == nil then return nil end
    if m.Parent == Cast then return m end
    m = m.Parent
  end
  return nil
end
local function topOf(p)
  local cf, sz = p.CFrame, p.Size
  local h = math.abs(cf.UpVector.Y) * sz.Y + math.abs(cf.RightVector.Y) * sz.X + math.abs(cf.LookVector.Y) * sz.Z
  return p.Position.Y + h / 2
end
function C.run(M, Ep, opt)
  opt = opt or {}
  local Cast, World = Ep.Cast, Ep.World
  local props = World:FindFirstChild("Props")
  local op = OverlapParams.new()
  op.FilterType = Enum.RaycastFilterType.Include
  op.FilterDescendantsInstances = {World, Cast}
  local hits, seen = {}, {}
  local probe = Instance.new("Part") probe.Anchored = true probe.CanCollide = false probe.CanQuery = false probe.Transparency = 1 probe.Parent = workspace
  for i = opt.from or 1, opt.to or #M.shots do
    local s = M.shots[i]
    for _, a in ipairs({0.1, 0.5, 0.9}) do
      local tt = (s.t0 or 0) + a * ((s.t1 or s.t0 or 0) - (s.t0 or 0))
      M.pose(i, a, tt) M.pose(i, a, tt)
      for name in pairs(s.a) do
        local ch = Cast:FindFirstChild(name)
        if ch then
          for _, ln in ipairs(LIMBS) do
            local limb = ch:FindFirstChild(ln)
            if limb and limb:IsA("BasePart") and limb.Transparency < 0.95 then
              probe.Size = limb.Size * 0.7 probe.CFrame = limb.CFrame
              local parts = workspace:GetPartsInPart(probe, op)
              for _, p in ipairs(parts) do
                if p.Transparency < 0.95 and not (p:IsA("MeshPart") and not p.CanCollide and p.CollisionFidelity ~= Enum.CollisionFidelity.Default and p.CollisionFidelity ~= Enum.CollisionFidelity.PreciseConvexDecomposition) and not p:IsDescendantOf(ch) and not (props and p:IsDescendantOf(props))
                   and not p:FindFirstAncestorWhichIsA("Accessory") and not p:FindFirstAncestorWhichIsA("Tool") then
                  local other = owner(p, Cast)
                  local floor = (other == nil) and topOf(p) < limb.Position.Y - limb.Size.Y * 0.2
                  if not floor then
                    local what = other and other.Name or p:GetFullName():gsub("^Workspace%.[^.]+%.World%.", "")
                    local key = i .. "|" .. name .. ln:gsub("Left",""):gsub("Right","") .. what
                    local okp = opt.ok and (opt.ok[name] or opt.ok["*"])
                    if not (okp and what:find(okp)) and not seen[key] then seen[key] = true table.insert(hits, {i = i, a = a, who = name, limb = ln, what = what}) end
                  end
                end
              end
            end
          end
        end
      end
    end
    task.wait()
  end
  probe:Destroy()
  return hits
end
function C.report(h)
  local g, order = {}, {}
  for _, x in ipairs(h) do
    local k = x.i .. " " .. x.who .. " -> " .. x.what:gsub("%.Model", ""):sub(1, 40)
    if not g[k] then g[k] = {} table.insert(order, k) end
    g[k][x.limb] = true
  end
  local t = {}
  for _, k in ipairs(order) do local n = 0 for _ in pairs(g[k]) do n += 1 end table.insert(t, "#" .. k .. " (" .. n .. ")") end
  return #order .. " pairs\n" .. table.concat(t, "\n")
end
return C
