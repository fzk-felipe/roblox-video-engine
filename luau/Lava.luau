-- Ep. 2 "The floor is lava": shot list + poser. Source of truth: projects/floor-is-lava/Lava.luau
local V = Vector3.new
local M = {}
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Ep = workspace:WaitForChild("Ep2")
local Cast, World = Ep:WaitForChild("Cast"), Ep:WaitForChild("World")
local Props = World:WaitForChild("Props")
M.ANIMS = { sit = 2506281703, idle = 507766388, walk = 507777826, run = 507767714, wave = 507770239, point = 507770453, cheer = 507770677, laugh = 507770818, jump = 507765000 }
local END = {2.58, 3.76, 5.64, 8.12, 9.73, 12.42, 14.55, 16.39, 18.0, 20.16, 21.23, 22.91, 24.79, 26.56, 27.95, 29.58, 31.63, 32.95, 34.94, 36.43, 37.89, 39.66, 41.33, 43.31, 44.84, 46.09, 47.73, 49.61, 51.14, 53.05, 54.51, 56.18, 58.31, 59.8, 61.93, 63.42, 64.6, 65.67, 67.37, 69.67, 72.6, 74.28, 75.42, 75.93, 76.44, 78.64, 79.64, 80.92, 82.56, 84.09, 86.18, 87.85, 89.13, 91.86, 93.53, 95.3, 96.55, 98.39, 100.09, 101.58, 103.35, 105.48, 107.22, 109.1, 110.63, 112.83, 114.32, 115.85, 117.45, 118.94, 121.24, 122.49, 124.16, 126.16}
local BOOM = {[5] = 9.26, [9] = 17.53, [12] = 22.44, [19] = 34.47, [27] = 47.26, [33] = 57.84, [49] = 82.09, [54] = 91.39}
M.TOTAL = END[#END]
local O = { home = V(-3000, 0, 0), street = V(-3000, 0, 300), gym = V(-3000, 0, 600) }
local PARK = CFrame.new(-3000, -300, 0)

local BLACK, WHITE = Color3.new(0, 0, 0), Color3.new(1, 1, 1)
local RED, PINK, BLUE = Color3.fromRGB(190, 30, 45), Color3.fromRGB(255, 140, 160), Color3.fromRGB(120, 195, 255)
local function fr(parent, x, y, w, h, color, round, rot, z)
  local f = Instance.new("Frame") f.AnchorPoint = Vector2.new(0.5, 0.5) f.Position = UDim2.fromScale(x, y) f.Size = UDim2.fromScale(w, h)
  f.BackgroundColor3 = color f.BorderSizePixel = 0 f.Rotation = rot or 0 f.ZIndex = z or 2
  if round then local c = Instance.new("UICorner") c.CornerRadius = UDim.new(round, 0) c.Parent = f end
  f.Parent = parent return f
end
local function stroke(f, th, color) local s = Instance.new("UIStroke") s.Thickness = th s.Color = color or BLACK s.Parent = f return f end
local function ring(parent, x, y, w, h, th, color, z) local f = fr(parent, x, y, w, h, WHITE, 0.5, 0, z) f.BackgroundTransparency = 1 return stroke(f, th, color) end
local function arc(parent, x, y, w, h, up, th, color, z)
  local c = fr(parent, x, y, w, h, WHITE, nil, 0, z) c.BackgroundTransparency = 1 c.ClipsDescendants = true
  ring(c, 0.5, up and 1 or 0, 0.78, 1.56, th, color, z) return c
end
local function emoji(parent, x, y, s, text, z)
  local t = Instance.new("TextLabel") t.AnchorPoint = Vector2.new(0.5, 0.5) t.Position = UDim2.fromScale(x, y) t.Size = UDim2.fromScale(s, s)
  t.BackgroundTransparency = 1 t.Text = text t.TextScaled = true t.ZIndex = z or 7 t.Parent = parent
end
local EXPR = {
  neutral = { eye = "open", mouth = "flat" }, smile = { eye = "open", mouth = "smile" }, happy = { eye = "happy", mouth = "grin" },
  laugh = { eye = "squint", mouth = "grin" }, shock = { eye = "wide", mouth = "open", brow = { -12, 12, -0.05 } }, scream = { eye = "wide", mouth = "scream", brow = { -14, 14, -0.05 } },
  sad = { eye = "open", py = 0.6, brow = { -20, 20, 0 }, mouth = "frown" }, cry = { eye = "sadc", brow = { -20, 20, 0 }, mouth = "scream", ex = "tears" },
  angry = { eye = "open", brow = { 24, -24, 0.05 }, mouth = "teeth", ex = "anger" }, stern = { eye = "half", brow = { 16, -16, 0.05 }, mouth = "flat" },
  smug = { eye = "half", brow = { -8, 14, 0 }, mouth = "smirk" }, nervous = { eye = "wide", mouth = "wavy", ex = "sweat" }, half = { eye = "half", mouth = "flat" },
  tired = { eye = "half", mouth = "frown", ex = "bags" }, focus = { eye = "open", brow = { 20, -20, 0.05 }, mouth = "tiny" }, o = { eye = "open", mouth = "o" },
  teeth = { eye = "open", mouth = "teeth", ex = "sweat" }, grin = { eye = "open", brow = { 22, -22, 0.05 }, mouth = "grin" }, squint = { eye = "squint", mouth = "wavy" },
  stare = { eye = "wide", mouth = "wavy", ex = "sweat" }, dry = { eye = "wide", mouth = "wavy", ex = "tears" }, closed = { eye = "closed", mouth = "smile" },
  catstare = { eye = "wide", mouth = "tiny" },
}
local function drawFace(gui, expr, style, skin)
  gui:ClearAllChildren()
  local E = EXPR[expr] or EXPR.neutral
  local cat, dog = style:find("cat") ~= nil, style:find("dog") ~= nil
  local INK = cat and Color3.fromRGB(235, 235, 245) or BLACK
  local EYE = cat and Color3.fromRGB(255, 215, 70) or WHITE
  local ey = 0.42
  for side, sx in { [-1] = 0.29, [1] = 0.71 } do
    local k = E.eye
    if k == "open" or k == "wide" or k == "half" then
      local s = k == "wide" and 0.33 or 0.25
      stroke(fr(gui, sx, ey, s, s, EYE, 0.5, 0, 2), 6, cat and BLACK or INK)
      if cat then fr(gui, sx, ey, 0.05, s * 0.8, BLACK, 0.5, 0, 3)
      else local ps = k == "wide" and 0.08 or 0.13 fr(gui, sx + (E.px or 0) * 0.05, ey + (E.py or 0) * 0.05, ps, ps, BLACK, 0.5, 0, 3) end
      if k == "half" then fr(gui, sx, ey - 0.1, 0.34, 0.17, skin, nil, 0, 4) fr(gui, sx, ey - 0.012, 0.3, 0.04, INK, 0.5, 0, 5) end
    elseif k == "dot" then fr(gui, sx, ey, 0.11, 0.11, INK, 0.5)
    elseif k == "closed" then fr(gui, sx, ey, 0.22, 0.045, INK, 0.5)
    elseif k == "happy" then arc(gui, sx, ey - 0.02, 0.27, 0.13, true, 8, INK, 2)
    elseif k == "sadc" then arc(gui, sx, ey + 0.02, 0.27, 0.13, false, 8, INK, 2)
    elseif k == "x" then fr(gui, sx, ey, 0.24, 0.05, INK, 0.5, 45) fr(gui, sx, ey, 0.24, 0.05, INK, 0.5, -45)
    elseif k == "squint" then fr(gui, sx, ey - 0.04, 0.2, 0.045, INK, 0.5, 24 * -side) fr(gui, sx, ey + 0.04, 0.2, 0.045, INK, 0.5, -24 * -side) end
    local wb = style:find("wbrow") ~= nil
    if E.brow or wb then
      local b = E.brow or { 0, 0, 0 }
      local f = fr(gui, sx, ey - 0.215 + b[3], wb and 0.27 or 0.22, wb and 0.075 or 0.05, wb and Color3.fromRGB(245, 245, 245) or INK, 0.5, side == -1 and b[1] or b[2], 6)
      if wb then stroke(f, 3, Color3.fromRGB(150, 150, 160)) end
    end
    if style:find("glasses") then ring(gui, sx, ey, 0.37, 0.37, 7, Color3.fromRGB(40, 40, 60), 6) end
    if style:find("lashes") then fr(gui, sx + side * 0.15, ey - 0.11, 0.1, 0.035, BLACK, 0.5, side * 40, 6) end
    if style:find("freckles") then for j = -1, 1 do fr(gui, sx + j * 0.06, ey + 0.2 + math.abs(j) * 0.025, 0.035, 0.035, Color3.fromRGB(190, 120, 90), 0.5) end end
    if E.ex == "tears" then fr(gui, sx, ey + 0.33, 0.085, 0.42, BLUE, 0.5, 0, 1) end
    if E.ex == "bags" then arc(gui, sx, ey + 0.17, 0.24, 0.06, false, 4, Color3.fromRGB(120, 90, 110), 2) end
  end
  if style:find("glasses") then fr(gui, 0.5, 0.42, 0.07, 0.035, Color3.fromRGB(40, 40, 60), 0.5, 0, 6) end
  if E.ex == "sweat" then fr(gui, 0.9, 0.17, 0.085, 0.14, BLUE, 0.5, -12, 7) fr(gui, 0.9, 0.11, 0.045, 0.07, BLUE, 0.5, -12, 7) end
  if E.ex == "anger" then for k = 0, 1 do fr(gui, 0.13, 0.14, 0.17, 0.045, Color3.fromRGB(225, 40, 50), 0.5, 45 + k * 90, 7) end end
  local my, m = 0.75, E.mouth
  if dog then fr(gui, 0.5, 0.6, 0.17, 0.1, BLACK, 0.5, 0, 5) my = 0.8 end
  if cat then fr(gui, 0.5, 0.63, 0.08, 0.06, PINK, 0.5, 0, 5) for s = -1, 1, 2 do fr(gui, 0.5 + s * 0.27, 0.66, 0.2, 0.018, INK, 0.5, s * 8) fr(gui, 0.5 + s * 0.27, 0.72, 0.2, 0.018, INK, 0.5, s * -8) end my = 0.78 end
  if m == "flat" then fr(gui, 0.5, my, 0.2, 0.045, INK, 0.5)
  elseif m == "tiny" then fr(gui, 0.5, my, 0.09, 0.04, INK, 0.5)
  elseif m == "smirk" then fr(gui, 0.54, my, 0.2, 0.045, INK, 0.5, -13)
  elseif m == "smile" then arc(gui, 0.5, my, 0.3, 0.1, false, 8, INK, 2)
  elseif m == "frown" then arc(gui, 0.5, my + 0.02, 0.3, 0.1, true, 8, INK, 2)
  elseif m == "o" then stroke(fr(gui, 0.5, my, 0.1, 0.12, RED, 0.5), 6, INK)
  elseif m == "wavy" then for j = -1, 1 do fr(gui, 0.5 + j * 0.085, my, 0.1, 0.04, INK, 0.5, j == 0 and -28 or 28) end
  elseif m == "open" then stroke(fr(gui, 0.5, my + 0.01, 0.2, 0.18, RED, 0.5), 6, INK) fr(gui, 0.5, my + 0.06, 0.1, 0.06, PINK, 0.5, 0, 3)
  elseif m == "teeth" then
    stroke(fr(gui, 0.5, my, 0.32, 0.13, WHITE, 0.25), 6, INK) fr(gui, 0.5, my, 0.32, 0.016, INK, nil, 0, 3)
    for j = -1, 1 do fr(gui, 0.5 + j * 0.08, my, 0.014, 0.13, INK, nil, 0, 3) end
  elseif m == "grin" then
    local c = fr(gui, 0.5, my + 0.035, 0.38, 0.18, WHITE, nil, 0, 2) c.BackgroundTransparency = 1 c.ClipsDescendants = true
    stroke(fr(c, 0.5, 0, 0.86, 1.72, RED, 0.5, 0, 2), 6, INK) fr(c, 0.5, 0.09, 0.8, 0.2, WHITE, nil, 0, 3) fr(c, 0.5, 0.8, 0.3, 0.3, PINK, 0.5, 0, 3)
    fr(gui, 0.5, my - 0.055, 0.36, 0.03, INK, 0.5, 0, 4)
    if dog then fr(gui, 0.56, my + 0.14, 0.11, 0.16, PINK, 0.5, 0, 5) end
  elseif m == "scream" then
    stroke(fr(gui, 0.5, my + 0.01, 0.36, 0.27, Color3.fromRGB(215, 35, 45), 0.22), 6, INK)
    for j = 0, 3 do fr(gui, 0.365 + j * 0.09, my - 0.1, 0.075, 0.075, WHITE, nil, 45, 3) end
    for j = 0, 2 do fr(gui, 0.41 + j * 0.09, my + 0.12, 0.075, 0.075, WHITE, nil, 45, 3) end
  end
  if style:find("wmustache") then stroke(fr(gui, 0.5, 0.625, 0.4, 0.1, Color3.fromRGB(245, 245, 245), 0.5, 0, 6), 3, Color3.fromRGB(150, 150, 160))
  elseif style:find("mustache") then fr(gui, 0.5, 0.625, 0.36, 0.09, Color3.fromRGB(110, 70, 40), 0.5, 0, 6) end
end

local function with(base, over) for k, v in over or {} do base[k] = v or nil end return base end
local function cu(on, o) o = o or {} o.on = on return o end
local function ab(p, l, fov, p2, l2) return { p = p, l = l, fov = fov, p2 = p2, l2 = l2 } end
M.shots = {}
local function S(line, set, cam, A, opt)
  opt = opt or {}
  local a, b = END[line - 1] or 0, END[line]
  local f = opt.f or { 0, 1 }
  table.insert(M.shots, { line = line, set = set, cam = cam, a = A, t0 = a + (b - a) * f[1], t1 = a + (b - a) * f[2], P = opt.P })
end
local function home(over) return with({
  Dad = { at = { 16, 9, -18.4 }, pose = "sit", face = "neutral" }, Mom = { at = { 6, 0.36, -13 }, pose = "balance", face = "neutral", pans = true },
  Grandpa = { at = { -2, 11, -20.1 }, pose = "hug", face = "neutral" }, Max = { at = { -3.6, 1.7, -3 }, pose = "flamingo", face = "neutral" },
  Emily = { at = { -16, 1.5, -5 } } }, over) end
local function dinner(over) return with({
  Dad = { at = { -0.5, 1.7, -6.5 }, pose = "sitf", face = "happy" }, Emily = { at = { 2, 1.7, -6.5 }, anim = "sit" }, Mom = { at = { 4.5, 1.7, -6.5 }, pose = "sitf", face = "happy" },
  Grandpa = { at = { -3.5, 1.7, -3 }, ry = 90, pose = "sitf", face = "happy" }, Max = { at = { 7.5, 1.7, -3 }, ry = -90, pose = "sitf", face = "smile" } }, over) end
local function street(over) return with({
  Mailman = { at = { -4, 6, -6 }, pose = "balance", face = "nervous" }, N1 = { at = { 6, 3.3, -8 }, pose = "balance", face = "neutral" }, N2 = { at = { 11, 4.5, -7 }, pose = "balance", face = "smile" },
  N3 = { at = { -12, 1.6, -8 }, pose = "balance", face = "neutral" }, N4 = { at = { 19, 4.9, 0.5 }, pose = "balance", face = "nervous" }, Dog = { at = { 0, 0, -5.5 }, ry = 20, face = "happy" } }, over) end
local SLOTS = {}
for _, z in { 16, 11, 6, 1 } do for _, x in { -25, -21, -17, -13, -9, -5, 5, 9, 13, 17, 21, 25 } do table.insert(SLOTS, { x, z }) end end
local CF = { "nervous", "neutral", "teeth", "focus", "smile", "o" }
local function gym(mode, over)
  local t = {}
  for i, sl in SLOTS do
    local x, z = sl[1], sl[2]
    if not (z == 16 and math.abs(x) == 5) and not (x == 17 and z == 6) then
      if mode == "chairs" then t["C" .. i] = { at = { x, 1.7, z }, ry = 180, pose = "balance", face = CF[i % 6 + 1] }
      elseif mode == "frozen" then t["C" .. i] = { at = { x, 1.7, z }, ry = 180 + (i % 3 - 1) * 25, pose = "stand", face = i % 2 == 0 and "shock" or "o", still = true }
      else t["C" .. i] = { at = { x * 0.82 + (i % 5 - 2) * 0.9, 0, z * 0.75 - 9 + (i % 4) * 0.8 }, ry = (i * 67) % 360, anim = i % 3 == 0 and "run" or "cheer", face = i % 2 == 0 and "happy" or "laugh" } end
    end
  end
  local fz = mode == "frozen"
  t.Mom = { at = { -5, 1.7, 16 }, ry = 180, anim = mode == "floor" and "cheer" or nil, pose = "balance", face = mode == "floor" and "happy" or "focus", still = fz }
  t.Max = { at = { 5, 1.7, 16 }, ry = 180, anim = mode == "floor" and "cheer" or nil, pose = "balance", face = "smile", still = fz }
  t.Mailman = { at = { 17, 6, 6 }, ry = 180, pose = "balance", face = fz and "shock" or "nervous", still = fz }
  t.Principal = { at = { 0, 3.18, -26.6 }, pose = "stand", face = fz and "shock" or "smile", still = fz }
  t.Mayor = { at = { 0, 1.7, -1 }, ry = 180, pose = "sit", face = fz and "shock" or "neutral", still = fz }
  t.Dad = { at = { 28, 20, -34.2 }, pose = "hug", face = "nervous", still = fz }
  t.Cat = { at = { 4, 0, -13 }, ry = -30, face = "half", still = true }
  t.Emily = { at = { 0, 1.7, 19 }, ry = 180 }
  if mode == "floor" then t.Mom.at = { -6, 0, 2 } t.Max.at = { 5, 0, 3 } t.Mayor = { at = { 3, 0, -3 }, ry = 200, anim = "cheer", face = "laugh" } t.Dad = { at = { 20, 0, -12.8 }, ry = -43, anim = "cheer", face = "cry" }
    t.Emily = { at = { 0, 0, -9 }, ry = 0, anim = "cheer" } t.Principal = { at = { -8, 0, -14 }, anim = "cheer", face = "laugh" } t.Mailman = { at = { 8, 0, -9 }, ry = 180, pose = "flat", face = "happy" } end
  return with(t, over)
end
local EC = { at = { 0, 1.7, -6 }, ry = 180 }

S(1, "home", cu("Emily", { d = 4.2, yaw = -15 }), home({ Emily = { at = { -16, 1.5, -5 }, anim = "point" }, Dad = { at = { -11, 0, -8 }, ry = -40, pose = "stand", face = "smile" }, Mom = { at = { -7, 0, -11 }, pose = "stand", face = "smile" }, Grandpa = false, Max = false }), { f = { 0, 0.5 } })
S(1, "home", ab({ -7, 5, 9 }, { -13, 2.6, -9 }, 52), home({ Emily = { at = { -16, 1.5, -5 }, anim = "point" }, Dad = { at = { -11, 0, -8 }, ry = -40, anim = "laugh", face = "laugh" }, Mom = { at = { -7, 0, -11 }, ry = -30, pose = "stand", face = "smile" }, Grandpa = false, Max = false }), { f = { 0.5, 1 } })
S(2, "home", cu("Emily", { d = 3.4, yaw = 12 }), home({ Emily = { at = { -16, 1.5, -5 } } }))
S(3, "home", ab({ 10.5, 10.4, -8 }, { 16, 10.6, -18.4 }, 40), home({ Dad = { at = { 16, 9, -18.4 }, pose = "sit", face = "tired" } }))
S(4, "home", ab({ -8.5, 3.6, -2 }, { -16, 4.4, -10.5 }, 50), home({ Dad = { at = { -15, 0, -7.5 }, to = { -16, 1.6, -11.6 }, arc = 3, pose = "jump", face = "laugh" }, Emily = { at = { -18.2, 1.5, -5 }, ry = 160, anim = "laugh" }, Mom = false, Grandpa = false, Max = false }), { f = { 0, 0.55 } })
S(4, "home", cu("Dad"), home({ Dad = { at = { -16, 1.6, -11.6 }, anim = "laugh", face = "laugh" }, Mom = false, Grandpa = false, Max = false }), { f = { 0.55, 1 } })
S(5, "home", cu("Dad", { d = 3, yaw = 10 }), home({ Dad = { at = { -16, 1.6, -11.6 }, pose = "stand", face = "shock", still = true }, Mom = false, Grandpa = false, Max = false }))
S(6, "home", cu("Mom"), home({ Mom = { at = { 6, 0.36, -13 }, anim = "point", face = "angry", pans = true } }), { f = { 0, 0.5 } })
S(6, "home", cu("Grandpa"), home({ Grandpa = { at = { -2, 11, -20.1 }, pose = "hug", face = "stern", nod = true } }), { f = { 0.5, 1 } })
S(7, "home", ab({ 9.5, 9.6, -7 }, { 16, 9.2, -18.6 }, 50), home({ Dad = { at = { 16, 9, -18.4 }, pose = "eat", face = "neutral" } }), { f = { 0, 0.5 } })
S(7, "home", cu("Dad", { d = 3.4, yaw = -15 }), home({ Dad = { at = { 16, 9, -18.4 }, pose = "eat", face = "o" } }), { f = { 0.5, 1 } })
S(8, "home", cu("Dad", { yaw = 20 }), home({ Dad = { at = { 16, 9, -18.4 }, pose = "wave", face = "smile" } }))
S(9, "home", ab({ 16, 11.3, -18.3 }, { 16, 12.4, -21.8 }, 34), home({ Dad = false }))
S(10, "home", ab({ 8, 6.8, -0.5 }, { 8, 2.6, -13 }, 50), home({ Mom = { at = { 2, 0.36, -13 }, to = { 13, 0.36, -13 }, ry = 40, pose = "skate", face = "focus", pans = true } }), { f = { 0, 0.5 } })
S(10, "home", ab({ 8, 0.9, -9.4 }, { 8, 0.5, -13 }, 32), home({ Mom = { at = { 4.5, 0.36, -13 }, to = { 11.5, 0.36, -13 }, ry = 90, pose = "skate", face = "focus", pans = true } }), { f = { 0.5, 1 } })
S(11, "home", cu("Mom", { d = 4.2, yaw = -12 }), home({ Mom = { at = { 2, 0.36, -13 }, to = { 13, 0.36, -13 }, ry = 90, pose = "skate", face = "grin", pans = true } }))
S(12, "home", cu("Max", { d = 3.2 }), home({ Max = { at = { -3.6, 1.7, -3 }, pose = "flamingo", face = "shock" } }))
S(13, "home", ab({ -5, 9, -8.5 }, { -2, 10.8, -20 }, 50), home({ Grandpa = { at = { -2, 11, -20.1 }, pose = "hug", face = "sad" } }), { f = { 0, 0.5 } })
S(13, "home", cu("Grandpa", { d = 3.4, yaw = -12 }), home({ Grandpa = { at = { -2, 11, -20.1 }, pose = "hug", face = "sad" } }), { f = { 0.5, 1 } })
S(14, "home", ab({ -5.8, 8.4, -8.6 }, { -5.8, 8.2, -18.5 }, 56), home({ Mom = { at = { -9, 0.36, -16.5 }, ry = 15, pose = "lift", face = "focus", pans = true }, Grandpa = { at = { -2, 11, -20.1 }, ry = -20, pose = "sit", face = "happy" } }))
S(15, "home", cu("Grandpa", { d = 3.4 }), home({ Grandpa = { at = { -2, 11, -20.1 }, pose = "hug", face = "teeth" } }))
S(16, "home", cu("Grandpa", { d = 2.7 }), home({ Grandpa = { at = { -2, 11, -20.1 }, pose = "hug", face = "scream", shake = true } }))
S(17, "home", cu("Max", { d = 3.4, yaw = 15 }), home({ Max = { at = { -3.6, 1.7, -3 }, pose = "flamingo", face = "smug" } }), { f = { 0, 0.5 } })
S(17, "home", ab({ -2.9, 3, 2.6 }, { -2.75, 2.2, -3 }, 40), home({ Max = { at = { -2.75, 1.25, -3 }, ry = 90, pose = "dip", face = "o" } }), { f = { 0.5, 1 } })
S(18, "home", ab({ -2.2, 0.45, 0.4 }, { -2.75, 0.3, -3 }, 24), home({ Max = { at = { -2.75, 1.25, -3 }, ry = 90, pose = "dip", face = "o" } }))
S(19, "home", cu("Mom", { d = 3.2 }), home({ Mom = { at = { 6, 0.36, -13 }, pose = "balance", face = "shock", pans = true, still = true } }), { f = { 0, 0.5 } })
S(19, "home", cu("Dad", { d = 3.2 }), home({ Dad = { at = { 16, 9, -18.4 }, pose = "sit", face = "cry" } }), { f = { 0.5, 1 } })
S(20, "street", cu("N1", { yaw = -20 }), street({ N1 = { at = { 6, 3.3, -8 }, pose = "balance", face = "squint" } }))
S(21, "street", cu("N2", { d = 3.3, yaw = 15 }), street({ N2 = { at = { 11, 4.5, -7 }, pose = "balance", face = "angry" } }))
S(22, "street", ab({ 3, 7, 17 }, { 3, 4, -8 }, 62), street({ Cat = { at = { -10, 0, 3 }, ry = 60, face = "half" } }))
S(23, "street", ab({ -1.5, 1, 0.5 }, { -4, 7, -6 }, 52), street(), { f = { 0, 0.5 } })
S(23, "street", cu("Mailman", { d = 3.4 }), street({ Mailman = { at = { -4, 6, -6 }, pose = "balance", face = "nervous" } }), { f = { 0.5, 1 } })
S(24, "street", ab({ -1.2, 2.4, -1.5 }, { -3.6, 0.6, -6.4 }, 36), street(), { f = { 0, 0.5 } })
S(24, "street", cu("Mailman", { d = 3.2, yaw = 15 }), street({ Mailman = { at = { -4, 6, -6 }, pose = "balance", face = "cry" } }), { f = { 0.5, 1 } })
S(25, "street", ab({ 0, 3.6, 16 }, { 0, 4.2, 5 }, 58), street(), { P = { Bus = { { -36, 0, 5 }, { 36, 0, 5 } } } })
S(26, "street", cu("Jumper", { d = 5.2, yaw = 30, fov = 42 }), street({ Jumper = { at = { -12, 1.6, -8 }, to = { -3, 5.5, 2 }, arc = 3, ry = 40, pose = "jump", face = "scream" }, N3 = false }), { P = { Bus = { { -22, 0, 5 }, { 8, 0, 5 } } } })
S(27, "street", ab({ 5.5, 6.5, -1.5 }, { 2, 8.4, -6.6 }, 42), street({ Jumper = { at = { 2, 4.7, -6.6 }, pose = "hang", face = "cry" }, N3 = false }))
S(28, "street", cu("Dog", { d = 3, yaw = -20, h = 0.2 }), street({ Dog = { at = { 0, 0, -5.5 }, ry = 20, face = "happy" } }), { f = { 0, 0.5 } })
S(28, "street", ab({ 2.2, 0.7, -3 }, { 0.2, 0.35, -5.8 }, 26), street(), { f = { 0.5, 1 } })
S(29, "street", cu("N3", { d = 3.4 }), street({ N3 = { at = { -12, 1.6, -8 }, pose = "shrug", face = "half" } }))
S(30, "street", ab({ -1, 0.9, 9 }, { -1, 0.8, 3 }, 42), street({ Cat = { at = { 0, 0, 3 }, ry = 20, face = "half" } }))
S(31, "street", cu("Cat", { d = 2.6, yaw = 35, h = 0.1 }), street({ Cat = { at = { 0, 0, 3 }, ry = 20, face = "half" } }))
S(32, "street", cu("Cat", { d = 3.2, yaw = -30, h = -0.5, fov = 44 }), street({ Cat = { at = { 0, 0, 3 }, ry = 20, face = "half" } }))
S(33, "street", cu("Cat", { d = 1.9 }), street({ Cat = { at = { 0, 0, 3 }, ry = 20, face = "catstare", still = true } }), { f = { 0, 0.5 } })
S(33, "street", cu("Mailman", { d = 3.2 }), street({ Mailman = { at = { -4, 6, -6 }, pose = "cover", face = "nervous" } }), { f = { 0.5, 1 } })
S(34, "gym", ab({ 0, 10, 37 }, { 0, 7, -28 }, 60), gym("chairs"))
S(35, "gym", ab({ 0, 7.5, -19 }, { 0, 3.8, 8 }, 64), gym("chairs"), { f = { 0, 0.55 } })
S(35, "gym", cu("C17", { d = 3.3, yaw = 15 }), gym("chairs", { C17 = { at = { -9, 1.7, 11 }, ry = 180, pose = "balance", face = "nervous" } }), { f = { 0.55, 1 } })
S(36, "gym", ab({ 1.6, 7.9, -20.2 }, { 0, 7.1, -24.4 }, 30), gym("chairs"))
S(37, "gym", ab({ 1.6, 6.3, 23.5 }, { 0, 5.5, -24 }, 48), gym("chairs"))
S(38, "gym", ab({ 2.8, 0.55, -7.5 }, { 1.5, 0.3, -22 }, 50), gym("chairs"))
S(39, "gym", cu("Principal", { d = 3.5, yaw = 10 }), gym("chairs", { Principal = { at = { 0, 3.18, -26.6 }, anim = "point", face = "o" } }))
S(40, "gym", cu("Emily", { d = 3.4 }), gym("chairs", { Emily = { at = { 0, 1.7, 19 }, ry = 180 } }), { f = { 0, 0.4 } })
S(40, "gym", cu("Mom", { d = 3.3 }), gym("chairs", { Mom = { at = { -5, 1.7, 16 }, ry = 30, pose = "balance", face = "stern", shake = true } }), { f = { 0.4, 1 } })
S(41, "gym", cu("Emily", { d = 3.4, yaw = -25 }), gym("chairs", { Emily = { at = { 0, 1.7, 19 }, ry = 180 } }), { f = { 0, 0.35 } })
S(41, "gym", ab({ 20, 11, -14 }, { 28, 20.8, -34 }, 40), gym("chairs", { Dad = { at = { 28, 20, -34.2 }, pose = "wave", face = "nervous" } }), { f = { 0.35, 1 } })
S(42, "gym", cu("Dad", { d = 3.3 }), gym("chairs", { Dad = { at = { 28, 20, -34.2 }, pose = "hug", face = "teeth" } }))
S(43, "gym", ab({ 1.8, 4.8, 8.5 }, { 0, 5, 16.5 }, 50), gym("chairs", { Emily = { at = { 0, 1.7, 19 }, to = { 0, 1.7, 14 }, arc = 2.2, ry = 180, anim = "jump" } }))
S(44, "gym", ab({ -1.8, 4, 3.5 }, { 0, 5, 11.5 }, 50), gym("chairs", { Emily = { at = { 0, 1.7, 14 }, to = { 0, 1.7, 9 }, arc = 2, ry = 180, anim = "jump" } }))
S(45, "gym", ab({ 1.6, 6, 14 }, { 0, 4.6, 6 }, 50), gym("chairs", { Emily = { at = { 0, 1.7, 9 }, to = { 0, 1.7, 4 }, arc = 2, ry = 180, anim = "jump" } }))
S(46, "gym", ab({ 1.3, 6, -6.8 }, { 0, 6.6, -1 }, 52), gym("chairs", { Emily = { at = { 0, 1.7, 4 }, to = { 0, 6.5, -1 }, arc = 1.5, ry = 180, anim = "jump" }, Mayor = { at = { 0, 1.7, -1 }, ry = 180, pose = "sit", face = "squint" } }), { f = { 0, 0.5 } })
S(46, "gym", cu("Mayor", { d = 3.4 }), gym("chairs", { Emily = { at = { 0, 6.5, -1 }, ry = 180 }, Mayor = { at = { 0, 1.7, -1 }, ry = 180, pose = "sit", face = "angry" } }), { f = { 0.5, 1 } })
S(47, "gym", ab({ 4, 5.4, -10.5 }, { 0, 6.2, -3.5 }, 54), gym("chairs", { Emily = { at = { 0, 6.5, -1 }, to = { 0, 1.7, -6 }, arc = 1.5, ry = 180, anim = "jump" }, Mayor = { at = { 0, 1.7, -1 }, ry = 180, pose = "sit", face = "angry" } }))
S(48, "gym", cu("Emily", { d = 3.4 }), gym("chairs", { Emily = EC }))
S(49, "gym", ab({ 2.2, 5.5, -7.5 }, { 2, 0, -16 }, 56), gym("chairs", { Emily = EC }))
S(50, "gym", ab({ -8, 5.2, -11 }, { -9, 3.9, 6 }, 46), gym("frozen", { Emily = EC }))
S(51, "gym", cu("Cat", { d = 2.3 }), gym("frozen", { Emily = EC, Cat = { at = { 4, 0, -13 }, ry = -30, face = "catstare", still = true } }))
S(52, "gym", cu("Emily", { d = 3 }), gym("frozen", { Emily = EC }))
S(53, "gym", cu("Emily", { d = 2.5, yaw = -10 }), gym("frozen", { Emily = EC }))
S(54, "gym", cu("Emily", { d = 3.2, yaw = 10 }), gym("frozen", { Emily = with({ anim = "point" }, EC) }), { f = { 0, 0.45 } })
S(54, "gym", cu("Principal", { d = 3.2 }), gym("frozen", { Emily = EC }), { f = { 0.45, 0.72 } })
S(54, "gym", cu("Mom", { d = 3 }), gym("frozen", { Emily = EC, Mom = { at = { -5, 1.7, 16 }, ry = 180, pose = "balance", face = "shock", still = true } }), { f = { 0.72, 1 } })
S(55, "gym", ab({ 0, 11, 32 }, { 0, 4, -10 }, 60), gym("frozen", { Emily = EC }))
S(56, "gym", ab({ 17.2, 0.7, -9.8 }, { 20, 0.7, -12.6 }, 30), gym("frozen", { Emily = EC, Dad = { at = { 20, 0, -12.8 }, ry = -43, pose = "stride", face = "nervous" } }))
S(57, "gym", cu("Dad", { d = 3.3 }), gym("frozen", { Emily = EC, Dad = { at = { 20, 0, -12.8 }, ry = -43, pose = "stand", face = "o", still = true } }))
S(58, "gym", cu("Dad", { d = 3, yaw = -12 }), gym("frozen", { Emily = EC, Dad = { at = { 20, 0, -12.8 }, ry = -43, pose = "up", face = "cry" } }))
S(59, "gym", ab({ 0, 8.5, 27 }, { 0, 3, -8 }, 64), gym("floor"))
S(60, "gym", cu("Mailman", { d = 6.5, yaw = 55, h = 3.4, lo = -0.6, fov = 46 }), gym("floor", { Mailman = { at = { 8, 0, -9 }, ry = 180, pose = "flat", face = "happy" } }))
S(61, "gym", ab({ -6, 4.6, -21.5 }, { -6, 3, -12 }, 52), gym("floor", { Principal = { at = { -11, 0, -12 }, to = { -1, 0, -12 }, pose = "cartwheel", face = "laugh" } }))
S(62, "gym", ab({ 8.5, 3.4, -14 }, { 0, 3.2, -14.5 }, 48), gym("floor", { Emily = { at = { 0, 0, -9 }, to = { 0, 0, -20 }, ry = 180, anim = "walk" } }), { f = { 0, 0.55 } })
S(62, "gym", cu("Emily"), gym("floor", { Emily = { at = { 0, 0, -20.5 }, anim = "cheer" } }), { f = { 0.55, 1 } })
S(63, "gym", ab({ 3.2, 0.7, -12 }, { 0, 0.5, -14.5 }, 30), gym("floor", { Emily = { at = { 0, 0, -10 }, to = { 0, 0, -17 }, ry = 180, anim = "walk" } }))
local function dinner2(over) local t = dinner() for _, s in t do if s.face == "happy" then s.face = "smile" end end return with(t, over) end
local NOTE = { Dad = { at = { 13.4, 0, -15.2 }, ry = -25, pose = "hold", face = "sad" }, Emily = { at = { 11, 0, -12.6 }, ry = 55 } }
S(64, "home", cu("Dad", { d = 3.6, yaw = -15 }), NOTE)
S(65, "home", ab({ 16, 6.5, -9.8 }, { 16, 6.4, -17.4 }, 30), { Dad = { at = { 19.4, 0, -15 }, ry = -40, pose = "stand", face = "sad" } })
S(66, "home", ab({ -12.6, 4.4, 4.5 }, { -12.6, 3.8, -8 }, 60), { Grandma = { at = { -8.5, 0, -9 }, ry = -70, anim = "wave", face = "smile" }, Emily = { at = { -16, 1.5, -5 }, ry = 75, anim = "wave" } }, { f = { 0, 0.55 } })
S(66, "home", cu("Grandma", { d = 3.4 }), { Grandma = { at = { -8.5, 0, -9 }, ry = -70, anim = "wave", face = "smile" }, Emily = { at = { -16, 1.5, -5 }, ry = 75, anim = "wave" } }, { f = { 0.55, 1 } })
S(67, "home", cu("Emily", { d = 3.4, yaw = 10 }), { Grandma = { at = { -8.5, 0, -9 }, ry = -70, anim = "wave", face = "smile" }, Emily = { at = { -16, 1.5, -5 }, ry = 75, anim = "wave" } })
S(68, "home", ab({ -17, 5.4, -7 }, { -5, 3.2, -2 }, 52), { Grandma = { at = { -8.5, 0, -8 }, to = { -2.5, 0, 1 }, ry = 35, anim = "walk", face = "smile" }, Emily = { at = { -16, 1.5, -5 }, ry = 50 } })
S(69, "home", ab({ -1.6, 3.6, 4.4 }, { 2, 2.2, 0.4 }, 40), {})
S(70, "home", cu("Dad", { d = 3.2 }), { Dad = { at = { 13.4, 0, -15.2 }, ry = -25, pose = "hold", face = "cry" }, Emily = { at = { 11, 0, -12.6 }, ry = 55 } })
S(71, "home", ab({ 2, 5, 5 }, { 2, 3.9, -6.5 }, 48), dinner2(), { f = { 0, 0.5 } })
S(71, "home", ab({ 2.4, 5, -3.6 }, { 2, 2.5, 0.8 }, 44), dinner2(), { f = { 0.5, 1 } })
S(72, "home", ab({ -0.6, 0.7, 1.5 }, { 2, 0.7, -6 }, 42), dinner2())
S(73, "home", cu("Emily", { d = 3 }), dinner2({ Emily = { at = { 2, 1.7, -6.5 }, anim = "sit" } }))
S(74, "home", cu("Cat", { d = 2.6, yaw = 14, h = 0.5 }), dinner2({ Cat = { at = { 2, 3, -2.2 }, ry = 180, face = "catstare", still = true } }), { f = { 0, 0.55 } })
S(74, "home", cu("Cat", { d = 2, h = 0.4 }), dinner2({ Cat = { at = { 2, 3, -2.2 }, ry = 180, face = "closed", still = true } }), { f = { 0.55, 1 } })

function M.at(t)
  for i, s in M.shots do if t < s.t1 then return i, math.clamp((t - s.t0) / (s.t1 - s.t0), 0, 1) end end
  return #M.shots, 1
end

-- arm/leg = {pitch°, roll°} (pitch + = forward/up, roll + = outwards); le/re/lk/rk = elbow/knee bend°
local POSE = {
  hi = { ra = { 175, 25 }, wave = 1 }, lift = { la = { 128, 4 }, ra = { 128, 4 }, le = 12, re = 12, lean = -6 }, walk = { run = 0.45 }, hold = { la = { 62, -6 }, ra = { 62, -6 }, le = 35, re = 35 },
  stand = {}, balance = { la = { 0, 78 }, ra = { 0, 78 }, wob = 1 }, up = { la = { 172, 12 }, ra = { 172, 12 } }, point = { ra = { 92, 0 } },
  sit = { ll = { 88, 4 }, rl = { 88, 4 }, lk = -85, rk = -85, hip = true, la = { 25, 8 }, ra = { 25, 8 } }, sitf = { ll = { 88, 3 }, rl = { 88, 3 }, lk = -88, rk = -88, hip = true, la = { 40, 5 }, ra = { 40, 5 }, le = 45, re = 45 },
  hug = { ll = { 112, 4 }, rl = { 112, 4 }, lk = -115, rk = -115, hip = true, la = { 70, -8 }, ra = { 70, -8 }, le = 40, re = 40, wob = 0.4 },
  eat = { ll = { 88, 4 }, rl = { 88, 4 }, lk = -85, rk = -85, hip = true, la = { 45, -5 }, le = 60, ra = { 55, -10 }, re = 95, eat = 1 },
  wave = { ll = { 88, 4 }, rl = { 88, 4 }, lk = -85, rk = -85, hip = true, la = { 20, 10 }, ra = { 175, 25 }, wave = 1 },
  dip = { ll = { 88, 4 }, lk = -85, rl = { 12, 0 }, hip = true, la = { 0, 50 }, ra = { 0, 50 }, wob = 0.5 },
  cover = { la = { 70, -18 }, ra = { 70, -18 }, le = 118, re = 118 }, flamingo = { rl = { 25, 0 }, rk = -100, la = { 0, 70 }, ra = { 0, 70 }, wob = 1.2 },
  stride = { ll = { -28, 0 }, rl = { 32, 0 }, la = { 20, 25 }, ra = { -20, 25 } }, jump = { la = { 165, 28 }, ra = { 165, 28 }, ll = { -25, 0 }, lk = -45, rl = { 50, 0 }, rk = -70 },
  hang = { la = { 178, 6 }, ra = { 178, 6 }, sway = 1 }, flat = { tilt = 88, la = { 175, 25 }, ra = { 175, 25 } },
  cartwheel = { spin = 1, la = { 0, 165 }, ra = { 0, 165 }, ll = { 0, 28 }, rl = { 0, 28 } }, cheer = { la = { 168, 18 }, ra = { 168, 18 }, hop = 1 }, run = { run = 1, le = 70, re = 70 },
  skate = { la = { 0, 70 }, ra = { 0, 70 }, run = 0.35, lean = 12 }, shrug = { la = { 10, 30 }, ra = { 10, 30 }, le = 95, re = 95 },
}
-- facial expressions of the avatars (FaceControls); "B" keys are applied to Left and Right
local FKEYS = { "LipCornerPuller", "CheekRaiser", "InnerBrowRaiser", "OuterBrowRaiser", "LipCornerDown", "UpperLidRaiser", "LipStretcher", "BrowLowerer", "EyeClosed" }
local FC = {
  neutral = {}, smile = { LipCornerPuller = 0.8, CheekRaiser = 0.3 }, happy = { LipCornerPuller = 1, CheekRaiser = 1, JawDrop = 0.4 },
  laugh = { LipCornerPuller = 1, CheekRaiser = 1, JawDrop = 0.9, EyeClosed = 0.85 }, grin = { LipCornerPuller = 1, JawDrop = 0.35, BrowLowerer = 0.9 },
  shock = { JawDrop = 1, UpperLidRaiser = 1, OuterBrowRaiser = 1, InnerBrowRaiser = 1 }, scream = { JawDrop = 1, UpperLidRaiser = 1, OuterBrowRaiser = 1, InnerBrowRaiser = 1, LipStretcher = 1 },
  o = { JawDrop = 0.6, UpperLidRaiser = 0.5, InnerBrowRaiser = 0.5 }, sad = { InnerBrowRaiser = 1, LipCornerDown = 1 }, cry = { InnerBrowRaiser = 1, LipCornerDown = 1, EyeClosed = 0.9, JawDrop = 0.6 },
  tired = { EyeClosed = 0.55, LipCornerDown = 0.7, InnerBrowRaiser = 0.4 }, angry = { BrowLowerer = 1, LipCornerDown = 0.8, LipStretcher = 0.7, JawDrop = 0.3 }, stern = { BrowLowerer = 1, LipCornerDown = 0.5 },
  focus = { BrowLowerer = 0.8, LipStretcher = 0.3 }, smug = { LeftLipCornerPuller = 1, LeftCheekRaiser = 0.5, EyeClosed = 0.4 }, half = { EyeClosed = 0.5, LipCornerDown = 0.3 },
  nervous = { InnerBrowRaiser = 1, LipStretcher = 0.9, UpperLidRaiser = 0.7 }, teeth = { LipStretcher = 1, InnerBrowRaiser = 0.7, JawDrop = 0.2 }, squint = { EyeClosed = 0.85, LipStretcher = 0.6, BrowLowerer = 0.6 },
  stare = { UpperLidRaiser = 1, OuterBrowRaiser = 0.7, LipStretcher = 0.6 }, dry = { UpperLidRaiser = 1, InnerBrowRaiser = 1, LipCornerDown = 0.9 },
}
local function setFace(fc, name)
  local f = FC[name] or FC.neutral
  for _, k in FKEYS do pcall(function() fc["Left" .. k] = f["Left" .. k] or f[k] or 0 fc["Right" .. k] = f["Right" .. k] or f[k] or 0 end) end
  pcall(function() fc.JawDrop = f.JawDrop or 0 end)
end
local reg
local function register()
  reg = {}
  -- nome do personagem nunca aparece em cima da cabeça (com a câmera rolada ele sai em pé); só placa/texto da história mostra nome
  for _, h in workspace:GetDescendants() do if h:IsA("Humanoid") then h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None h.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff end end
  for _, m in Cast:GetChildren() do
    if not m:IsA("Model") then continue end
    local kind = m:GetAttribute("Kind")
    local d = { kind = kind, model = m, name = m.Name, seed = (#m.Name * 13 + m.Name:byte(-1) * 7) % 100 / 10, parked = false, face = nil, skin = m:GetAttribute("Skin"), style = m:GetAttribute("Style") or "" }
    if kind == "rigid" then d.head = m.Head d.gui = m.Head:FindFirstChild("Face")
    else
      d.hrp = m.HumanoidRootPart d.rootH = m:GetAttribute("RootH") d.headOff = m:GetAttribute("HeadOff") d.sc = m:GetScale()
      if kind == "rig" then
        d.j = {} d.fc = m:FindFirstChildWhichIsA("FaceControls", true) d.gui = m.Head:FindFirstChild("Face") d.skin = m.Head.Color
        for _, c in m:GetDescendants() do if c:IsA("AnimationConstraint") then d.j[c.Name] = c c.Transform = CFrame.identity end end
      end
    end
    reg[m.Name] = d
  end
end
local function reseat(d)  -- Edit only: constraint rigs do not follow the root without physics
  if not d.adj then
    d.adj = {}
    for _, c in d.model:GetDescendants() do
      if (c:IsA("AnimationConstraint") or c:IsA("RigidConstraint")) and c.Attachment0 and c.Attachment1 then
        local p0, p1 = c.Attachment0.Parent, c.Attachment1.Parent
        local anim = c:IsA("AnimationConstraint") and c or nil
        d.adj[p0] = d.adj[p0] or {} table.insert(d.adj[p0], { p1, c.Attachment0, c.Attachment1, anim, false })
        d.adj[p1] = d.adj[p1] or {} table.insert(d.adj[p1], { p0, c.Attachment1, c.Attachment0, anim, true })
      end
    end
  end
  if not d.loose then d.loose = true for _, c in d.model:GetDescendants() do if c:IsA("AnimationConstraint") or c:IsA("RigidConstraint") then c.Enabled = false end end end
  local seen, q = { [d.hrp] = true }, { d.hrp }
  while #q > 0 do
    local p = table.remove(q, 1)
    for _, e in d.adj[p] or {} do
      if not seen[e[1]] then
        seen[e[1]] = true
        local T = e[4] and e[4].Transform or CFrame.identity
        if e[5] then T = T:Inverse() end
        e[1].CFrame = p.CFrame * e[2].CFrame * T * e[3].CFrame:Inverse() table.insert(q, e[1])
      end
    end
  end
end
local function rootOf(s, sp, a)
  local p = V(sp.at[1], sp.at[2], sp.at[3])
  if sp.to then p = p:Lerp(V(sp.to[1], sp.to[2], sp.to[3]), a) end
  if sp.arc then p += V(0, sp.arc * 4 * a * (1 - a), 0) end
  return CFrame.new(O[s.set] + p) * CFrame.Angles(0, math.rad(180 + (sp.ry or 0)), 0)
end
local rad, sin = math.rad, math.sin
local function A2(p, r, side) return CFrame.Angles(rad(p), 0, 0) * CFrame.Angles(0, 0, rad(r * side)) end
local function poseRig(d, sp, root, t, lt)
  local sc, ps, seed, j = d.sc, POSE[sp.pose or "stand"] or POSE.stand, d.seed, d.j
  local w = sp.still and 0 or 1
  local wob = (ps.wob or 0) * w
  local f = sp.face or "neutral"
  local rc = w * math.exp(-math.max(lt, 0) * 6)
  local headP, headY, bounce, lean2, trem, flinch = 0, 0, 0, 0, 0, 0
  if f == "shock" or f == "scream" or f == "o" or f == "stare" then headP = 16 * rc flinch = 30 * rc bounce = 0.35 * rc
  elseif f == "laugh" or f == "happy" or f == "grin" then bounce = math.abs(sin(t * 11 + seed)) * 0.13 * w headP = 8
  elseif f == "cry" or f == "sad" or f == "tired" or f == "dry" then headP = -14 headY = sin(t * 3 + seed) * 5 * w
  elseif f == "angry" or f == "stern" then lean2 = 7 headP = -6 headY = f == "angry" and sin(t * 24) * 3 * w or 0
  elseif f == "nervous" or f == "teeth" or f == "squint" then trem = sin(t * 31 + seed) * 1.6 * w end
  root *= CFrame.new(0, ((ps.hop and math.abs(sin(t * 7 + seed)) * 0.6 or 0) + sin(t * 2 + seed) * 0.03 * w + bounce) * (ps.hop and w or 1) * sc, 0)
  if ps.tilt then root = root * CFrame.new(0, 0.6 * sc, 0) * CFrame.Angles(-rad(ps.tilt), 0, 0) end
  if ps.spin then root = root * CFrame.new(0, 2.8 * sc, 0) * CFrame.Angles(0, 0, -t * 7) * CFrame.new(0, -2.8 * sc, 0) end
  local hrp = root * CFrame.new(0, ps.hip and 1.35 * sc or d.rootH, 0) * CFrame.Angles(-rad((ps.lean or 0) + lean2), 0, ps.sway and sin(t * 2.2 + seed) * rad(8) or 0)
  d.hrp.CFrame = hrp
  local run = ps.run and sin(t * (ps.run < 1 and 8 or 14) + seed) * 42 * ps.run or 0
  local function arm(side, a, e, sh, el)
    local p, r, eb = a and a[1] or 0, a and a[2] or 5, e or 8
    p -= run * side
    r += sin(t * 2.3 + seed) * 20 * wob * side + flinch
    if side == 1 and ps.eat then eb += sin(t * 6) * 25 end
    if side == 1 and ps.wave then r += sin(t * 9) * 18 end
    sh.Transform = A2(p, r, side) el.Transform = CFrame.Angles(rad(eb), 0, 0)
  end
  arm(-1, ps.la, ps.le, j.LeftShoulder, j.LeftElbow) arm(1, ps.ra, ps.re, j.RightShoulder, j.RightElbow)
  local function leg(side, a, k, hip, knee)
    local p, r = a and a[1] or 0, a and a[2] or 0
    p += run * side
    hip.Transform = A2(p, r, side) knee.Transform = CFrame.Angles(rad((k or 0) - (ps.run and math.max(0, -run * side) * 0.9 or 0)), 0, 0)
  end
  leg(-1, ps.ll, ps.lk, j.LeftHip, j.LeftKnee) leg(1, ps.rl, ps.rk, j.RightHip, j.RightKnee)
  j.Waist.Transform = CFrame.Angles(sin(t * 1.6 + seed) * rad(1.5) * w, 0, sin(t * 2.3 + seed) * rad(9) * wob + rad(trem))
  j.Neck.Transform = CFrame.Angles(0, rad((sp.hy or 0) + headY) + (sp.shake and sin(t * 11) * rad(24) or 0) - sin(t * 2.3 + seed) * rad(5) * wob, 0) * CFrame.Angles(rad(headP) + (sp.nod and sin(t * 9) * rad(11) or 0), 0, sin(t * 1.7 + seed) * rad(3) * w)
  return hrp
end
-- Edit only: put every avatar back in its rest pose with the joints switched on (call before Play and before saving)
function M.finalize()
  if not reg then register() end
  for _, d in reg do
    if d.kind ~= "rigid" then
      for _, c in d.model:GetDescendants() do if c:IsA("AnimationConstraint") then c.Transform = CFrame.identity end end
      d.hrp.CFrame = PARK d.loose = true reseat(d) d.parked = true d.face = nil
      for _, c in d.model:GetDescendants() do if c:IsA("AnimationConstraint") or c:IsA("RigidConstraint") then c.Enabled = true end end
      d.loose = false
    end
  end
end
local env
local function setup()
  register()
  env = { stilts = { Props.StiltL, Props.StiltR }, pans = { Props.PanL, Props.PanR }, bus = Props.Bus, dof = Lighting:FindFirstChildOfClass("DepthOfFieldEffect"), last = 0, running = RunService:IsRunning() }
  env.glow = {} for _, g in Props:GetChildren() do if g.Name == "LavaGlow" then table.insert(env.glow, g) end end
end
function M.light()
  local want = { ClockTime = 14.5, GeographicLatitude = 60, Brightness = 2, Ambient = Color3.fromRGB(120, 120, 130), OutdoorAmbient = Color3.fromRGB(170, 172, 185), ExposureCompensation = -0.3, ShadowSoftness = 0.4 }
  local old = {}
  for k, v in want do old[k] = Lighting[k] Lighting[k] = v end
  local cc, atm = Lighting:FindFirstChildOfClass("ColorCorrectionEffect"), Lighting:FindFirstChildOfClass("Atmosphere")
  local oc = cc and { cc.Saturation, cc.Contrast } local oa = atm and { atm.Density, atm.Haze }
  if cc then cc.Saturation = 0.3 cc.Contrast = 0.1 end
  if atm then atm.Density = 0.12 atm.Haze = 0.4 end
  return function() for k, v in old do Lighting[k] = v end if cc then cc.Saturation = oc[1] cc.Contrast = oc[2] end if atm then atm.Density = oa[1] atm.Haze = oa[2] end end
end

function M.pose(i, a, t, cam)
  if not env then setup() end
  local s = M.shots[i]
  local o = O[s.set]
  local parts, cfs, heads, roots, stilts = {}, {}, {}, {}, false
  local newShot = env.last ~= i
  env.last = i
  for name, d in reg do
    local sp = s.a[name]
    if not sp then
      if not d.parked then
        d.parked = true
        if d.kind == "rigid" then d.model:PivotTo(PARK) else d.hrp.CFrame = PARK if not env.running then reseat(d) end end
      end
    else
      d.parked = false
      local root = rootOf(s, sp, a)
      if d.kind == "rigid" then
        local moving = sp.to and not sp.still
        d.model:PivotTo(root * CFrame.new(0, moving and math.abs(sin(t * 12)) * 0.07 or 0, 0) * CFrame.Angles(0, 0, moving and sin(t * 12) * rad(3) or 0))
        heads[name] = d.head.Position
        local want = sp.face or "neutral"
        if d.gui and d.face ~= want then d.face = want drawFace(d.gui, want, d.style, d.skin) end
      else
        local hrp
        if d.kind == "rig" then
          if sp.anim then hrp = root * CFrame.new(0, d.rootH, 0) d.hrp.CFrame = hrp else hrp = poseRig(d, sp, root, t, t - s.t0) end
          local want = sp.face or "neutral"
          if d.face ~= want then d.face = want if d.gui then drawFace(d.gui, want, d.style, d.skin) elseif d.fc then setFace(d.fc, want) end end
          if sp.pans then for k, pan in env.pans do pan:PivotTo(root * CFrame.new((k * 2 - 3) * 0.62, -0.34, 0.1)) end end
          if name == "Mailman" then stilts = sp.pose ~= "flat" and root or false end
        else
          hrp = root * CFrame.new(0, sp.anim == "sit" and 1.4 or d.rootH, 0)
          d.hrp.CFrame = hrp
        end
        if not env.running then reseat(d) end
        heads[name] = (hrp * CFrame.new(d.headOff)).Position
      end
      roots[name] = root
    end
  end
  for k, st in env.stilts do st.CFrame = stilts and stilts * CFrame.new((k * 2 - 3) * 0.5, -3, 0) or PARK end
  if not (s.a.Mom and s.a.Mom.pans) then for _, pan in env.pans do pan:PivotTo(PARK) end end
  workspace:BulkMoveTo(parts, cfs, Enum.BulkMoveMode.FireCFrameChanged)
  local hot = s.line < 55
  if env.hot ~= hot then env.hot = hot for _, g in env.glow do g.Transparency = hot and 0.62 or 1 for _, pe in g:GetChildren() do if pe:IsA("ParticleEmitter") then pe.Enabled = hot end end end end
  local bus = s.P and s.P.Bus
  env.bus:PivotTo(bus and CFrame.new(o + V(bus[1][1], bus[1][2], bus[1][3]):Lerp(V(bus[2][1], bus[2][2], bus[2][3]), a)) or PARK)
  local c = s.cam
  local pos, look
  if c.on then
    local h, r = heads[c.on], roots[c.on]
    local sc = reg[c.on].sc or 1
    local dir = CFrame.Angles(0, rad(c.yaw or 0), 0):VectorToWorldSpace(r.LookVector)
    pos = h + dir * (c.d or 3.6) * 1.35 * sc * (1 - 0.07 * a) + V(0, c.h or 0, 0)
    -- R1 the caption sits in the middle of the tall picture: by default the camera aims below the head, so the face
    -- is framed about 30 % from the top (0.19 x the distance) and never behind the caption; c.lo overrides it
    look = h + V(0, c.lo or -0.19 * (c.d or 3.6) * 1.35 * sc, 0)
  else
    pos = o + V(c.p[1], c.p[2], c.p[3]) look = o + V(c.l[1], c.l[2], c.l[3])
    if c.p2 then pos = pos:Lerp(o + V(c.p2[1], c.p2[2], c.p2[3]), a) else pos = pos:Lerp(look, 0.06 * a) end
  end
  local kick = 0
  local tb = BOOM[s.line]
  if tb and t >= tb then kick = math.exp(-(t - tb) * 5) end
  local flat = CFrame.lookAt(pos, look)
  local hx = math.noise(t * 0.8, i * 7.1) * 0.012 + kick * sin(t * 61) * 0.02
  local hyy = math.noise(t * 0.8, i * 3.3 + 50) * 0.012 + kick * math.cos(t * 53) * 0.02
  if cam then
    cam.CameraType = Enum.CameraType.Scriptable
    cam.FieldOfView = (c.fov or 36) * (1 - 0.15 * kick)
    cam.CFrame = flat * CFrame.Angles(hx, hyy, 0) * CFrame.Angles(0, 0, rad(90 + ((i * 37) % 9 - 4)))
    if env.dof then
      local fd = (pos - look).Magnitude
      env.dof.FocusDistance = fd env.dof.InFocusRadius = math.max(5, fd * 0.45) env.dof.FarIntensity = fd < 45 and 0.45 or 0.1 env.dof.NearIntensity = fd < 45 and 0.2 or 0
    end
  end
end
return M
