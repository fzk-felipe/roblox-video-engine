-- Plays episode 2 ("The floor is lava"): Lava.pose places everything each frame; this adds the clock and Emily's animations.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
cam.CameraType = Enum.CameraType.Scriptable
UIS.MouseIconEnabled = false
task.spawn(function() for i = 1, 30 do if pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end) then break end task.wait(0.1) end end)
local player = Players.LocalPlayer
if player.Character then player.Character:Destroy() end
player.CharacterAdded:Connect(function(c) task.defer(function() c:Destroy() end) end)

local Cast = workspace:WaitForChild("Ep2"):WaitForChild("Cast")
workspace.Ep2:WaitForChild("World"):WaitForChild("Props"):WaitForChild("LavaGlow")
while #Cast:GetChildren() < 61 do task.wait() end
local Lava = require(game:GetService("ReplicatedStorage"):WaitForChild("Film"):WaitForChild("Lava"))
local need = {}   -- [avatar][animation] taken from the shot list
for _, s in Lava.shots do for name, sp in s.a do if type(sp) == "table" and sp.anim then need[name] = need[name] or {} need[name][sp.anim] = true end end end
local tracks, playing = {}, {}
for _, m in Cast:GetChildren() do
  local hum = m:FindFirstChildOfClass("Humanoid")
  if hum then
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    tracks[m.Name] = {}
    for name, id in Lava.ANIMS do
      if m.Name == "Emily" or (need[m.Name] and need[m.Name][name]) then
        local a = Instance.new("Animation") a.AnimationId = "rbxassetid://" .. id
        local ok, t = pcall(function() return animator:LoadAnimation(a) end)
        if ok then t.Looped = true t.Priority = Enum.AnimationPriority.Action tracks[m.Name][name] = t end
      end
    end
  end
end
local function setAnim(shot)
  for name, set in tracks do
    local sp = shot.a[name]
    if type(sp) ~= "table" then sp = sp and {} or nil end   -- R38: `false`/`true` in the shot list
    local want = sp and (sp.anim or (name == "Emily" and "idle" or nil)) or nil
    if playing[name] ~= want then
      if playing[name] and set[playing[name]] then set[playing[name]]:Stop(0.1) end
      if want and set[want] then set[want]:Play(0.1) set[want].TimePosition = (#name * 0.37) % 1 end
      playing[name] = want
    end
    if want and set[want] then set[want]:AdjustSpeed(sp.still and 0 or 1) end
  end
end
Lava.pose(1, 0, 0, cam)
task.wait(1.5)   -- lets every part and face load before the first frame
-- claquete: a white screen for 0.2 s right before the first frame, so scripts/inicio.py finds the start of the film in the recording
local clap = Instance.new("ScreenGui") clap.IgnoreGuiInset = true clap.DisplayOrder = 1000 clap.ResetOnSpawn = false
local white = Instance.new("Frame") white.Size = UDim2.fromScale(1, 1) white.BackgroundColor3 = Color3.new(1, 1, 1) white.BorderSizePixel = 0 white.Parent = clap
clap.Parent = player:WaitForChild("PlayerGui")
task.wait(0.2)
clap:Destroy()
RunService.RenderStepped:Wait()
print("LAVA_START")
local t0, last = nil, 0
RunService:BindToRenderStep("Lava", Enum.RenderPriority.Camera.Value + 1, function()
  t0 = t0 or os.clock()
  local t = os.clock() - t0
  local i, a = Lava.at(t)
  if i ~= last then last = i setAnim(Lava.shots[i]) print("SHOT", i, string.format("%.2f", t)) end
  Lava.pose(i, a, t, cam)
  if t > Lava.TOTAL and last ~= -1 then print("LAVA_DONE") last = -1 RunService:UnbindFromRenderStep("Lava") end
end)
