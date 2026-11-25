-- Conferência automática do filme (Edit): posa cada plano em 3 instantes e mede o quadro FINAL (vertical, já girado e
-- recortado). ERRO bloqueia a gravação; AVISO pede um olhar na captura. Sempre termina com F.finalize().
-- Uso (Edit):
--   local F = require(game.ReplicatedStorage.Film.<Modulo>:Clone())
--   local Check = require(game.ReplicatedStorage.Film.Check:Clone())
--   return Check.run(F, { cast = workspace.EpN.Cast })
-- opt: cast (obrigatório); x0, w = recorte da gravação em fração da largura (padrão 174/1920 e 1572/1920);
--      band = meia altura da legenda (0.03); only = { [n] = true } para conferir só alguns planos;
--      obj[planoN] = nome de uma peça de workspace que TEM de aparecer inteira no plano (bilhete, placa...).
local C = {}
local MOMENTS = { 0.1, 0.5, 0.9 }
local KEEP = 1080 / (1080 * 1920 / 1572)   -- fração da altura da tela que sobra depois de escalar para 1920 e cortar 1080

local function headOf(model) return model:FindFirstChild("Head") end

function C.run(F, opt)
  opt = opt or {}
  local cast = assert(opt.cast, "Check.run: passe opt.cast (o Model/Folder com os avatares)")
  local x0, w, band = opt.x0 or 174 / 1920, opt.w or 1572 / 1920, opt.band or 0.03
  local cam = workspace.CurrentCamera
  local RunService = game:GetService("RunService")
  local running = RunService:IsRunning()
  local errs, warns, seen = {}, {}, {}
  local function say(list, i, s, code, msg)
    local key = i .. code .. msg
    if seen[key] then return end
    seen[key] = true
    table.insert(list, string.format("plano %d (fala %d, %.1f s) %s: %s", i, s.line, s.t0, code, msg))
  end
  -- ponto do mundo -> quadro final: v = 0 em cima, 1 embaixo; h = 0 esquerda, 1 direita; r = raio da cabeça em fração da altura
  local function project(pos, size)
    local p = cam.CFrame:PointToObjectSpace(pos)
    local depth = -p.Z
    if depth <= 0.05 then return nil end
    local tanV = math.tan(math.rad(cam.FieldOfView) / 2)
    local tanH = tanV * 16 / 9                                  -- a gravação é 16:9, seja qual for a janela do Edit
    local sx = 0.5 + p.X / depth / (2 * tanH)                   -- tela deitada: 0 esquerda, 1 direita
    local sy = 0.5 - p.Y / depth / (2 * tanV)                   -- 0 em cima, 1 embaixo
    local v = 1 - (sx - x0) / w                                 -- tela-direita = cima do vídeo
    local h = (sy - 0.5) / KEEP + 0.5
    local r = (size / 2) / depth / (2 * tanH * w)
    return v, h, r, depth
  end
  local prev
  for _, h in workspace:GetDescendants() do if h:IsA("Humanoid") and (h.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None or h.HealthDisplayType ~= Enum.HumanoidHealthDisplayType.AlwaysOff) then table.insert(errs, "R59 etiqueta de nome/vida visível em " .. h.Parent:GetFullName()) end end
  for i, s in F.shots do
    if opt.only and not opt.only[i] then continue end
    local dur = s.t1 - s.t0
    if dur < 0.45 then say(warns, i, s, "R7", string.format("plano de %.2f s: curto demais para ler o rosto", dur)) end
    if dur > 2.6 then say(warns, i, s, "R7", string.format("plano de %.2f s: dividir em 2-3 planos (f = {0, 0.5})", dur)) end
    if prev and prev.cam.on and prev.cam.on == s.cam.on and math.abs((prev.cam.yaw or 0) - (s.cam.yaw or 0)) < 20
      and math.abs((prev.cam.d or 3.6) - (s.cam.d or 3.6)) < 0.25 * (s.cam.d or 3.6) then
      say(warns, i, s, "R8", "mesmo enquadramento do plano anterior em " .. s.cam.on .. " (corte que parece defeito): mudar ângulo (30 graus) ou distância")
    end
    prev = s
    for _, a in MOMENTS do
      local ok, err = pcall(F.pose, i, a, s.t0 + dur * a, cam)
      if not ok then say(errs, i, s, "R0", "pose falhou: " .. tostring(err)) break end
      if running then RunService.Heartbeat:Wait() RunService.Heartbeat:Wait() end   -- no Play as juntas só seguem a raiz depois de um passo de física
      local camPos = cam.CFrame.Position
      local faces, roots, front = 0, {}, 0
      for name, sp in s.a do
        local model = sp and cast:FindFirstChild(name)
        local head = model and headOf(model)
        if not head then continue end
        local root = model:FindFirstChild("HumanoidRootPart") or head
        table.insert(roots, { name, root.Position })
        local v, h, r, depth = project(head.Position, head.Size.Y)
        if not v then continue end
        local inside = v > -r and v < 1 + r and h > -r and h < 1 + r
        local whole = v > 0.7 * r and v < 1 - 0.7 * r and h > 0.7 * r and h < 1 - 0.7 * r
        local big = r > 0.035                                    -- rosto que o olho lê (mais de 7 % da altura)
        if inside and whole and r > 0.02 then faces += 1 if head.CFrame.LookVector:Dot((camPos - head.Position).Unit) > 0.25 then front += 1 end end
        if sp.bub then -- R62: speech bubble (BillboardGui 2.4 x 4.6 studs, 2.6 above the head) over the caption line
          local sc = model:GetScale() local P = head.Position + Vector3.new(0, 2.6 * sc, 0)
          local tanV = math.tan(math.rad(cam.FieldOfView) / 2) local tanH = tanV * 16 / 9
          local vmin, vmax, hmin, hmax = 9, -9, 9, -9
          for _, a1 in { -1.35, 1.35 } do for _, a2 in { -2.3, 2.3 } do
            local q = cam.CFrame:PointToObjectSpace(P + cam.CFrame.RightVector * a1 * sc + cam.CFrame.UpVector * a2 * sc)
            if -q.Z > 0.05 then
              local sx = 0.5 + q.X / -q.Z / (2 * tanH) local sy = 0.5 - q.Y / -q.Z / (2 * tanV)
              local bv, bh = 1 - (sx - x0) / w, (sy - 0.5) / KEEP + 0.5
              vmin, vmax, hmin, hmax = math.min(vmin, bv), math.max(vmax, bv), math.min(hmin, bh), math.max(hmax, bh)
            end
          end end
          local cv = opt.capV or 0.5   -- caption centre (0.5 = middle of the frame)
          if vmax > cv - 0.06 and vmin < cv + 0.06 and hmax > 0.15 and hmin < 0.85 then say(errs, i, s, "R62", string.format("balão de %s em cima da legenda (%.0f-%.0f %% do topo): subir/descer o rosto no quadro", name, vmin * 100, vmax * 100)) end
        end
        if big and inside and not whole and (s.cam.on == name or r > 0.06) then   -- figurante pequeno na borda de um plano geral não conta
          say(errs, i, s, "R2", string.format("rosto de %s cortado pela borda (a %.0f %% do topo, %.0f %% da esquerda)", name, v * 100, h * 100))
        end
        if big and whole and math.abs(v - 0.5) < band + 0.8 * r then
          say(errs, i, s, "R1", string.format("rosto de %s atrás da legenda (centro a %.0f %% do topo; a legenda ocupa o meio): subir o rosto para ~30 %% (lo negativo) ou descer abaixo de 65 %%", name, v * 100))
        end
        if big and whole then
          if head.CFrame.LookVector:Dot((camPos - head.Position).Unit) < 0 and (s.cam.on == name or r > 0.08) then
            say(errs, i, s, "R3", name .. " de costas ou de nuca para a câmera")
          end
          local rp = RaycastParams.new()
          rp.FilterType = Enum.RaycastFilterType.Exclude
          rp.FilterDescendantsInstances = { model }
          local hit = workspace:Raycast(camPos, head.Position - camPos, rp)
          if (s.cam.on == name or r > 0.06) and hit and hit.Instance.Transparency < 0.5 and (hit.Position - camPos).Magnitude < depth - 0.6 then   -- rosto de fundo atrás do protagonista não conta
            say(errs, i, s, "R4", "rosto de " .. name .. " escondido por " .. hit.Instance:GetFullName())
          end
        end
      end
      if a == 0.5 and faces == 0 and not (opt.obj and opt.obj[i]) then
        say(warns, i, s, "R5", "nenhum rosto inteiro no quadro (só pernas, nuca ou cenário): conferir na captura se o objeto da fala aparece")
      end
      if a == 0.5 and faces > 0 and front == 0 and not (opt.obj and opt.obj[i]) then   -- R63: every visible face is turned away (hugs in profile, walking away)
        say(errs, i, s, "R63", "nenhum rosto virado para a câmera (só nuca ou perfil de costas): girar a câmera para o lado do rosto")
      end
      for x = 1, #roots do
        for y = x + 1, #roots do
          local d = roots[x][2] - roots[y][2]
          if Vector3.new(d.X, 0, d.Z).Magnitude < 1.4 and math.abs(d.Y) < 4 then
            say(errs, i, s, "R6", roots[x][1] .. " e " .. roots[y][1] .. " ocupam o mesmo lugar (um atravessa o outro)")
          end
        end
      end
      local op = OverlapParams.new()
      for _, part in workspace:GetPartBoundsInRadius(camPos, 0.4, op) do
        if part.Transparency < 1 and not part:IsDescendantOf(cast) then
          say(errs, i, s, "R9", "câmera dentro de " .. part:GetFullName())
          break
        end
      end
      local crowd = #workspace:GetPartBoundsInRadius(camPos, 1.6)   -- R21 conta também o elenco: braço de figurante na lente não aparece no raio até o rosto
      if crowd >= 4 then say(warns, i, s, "R21", crowd .. " peças a menos de 1,6 stud da câmera (figurante, cabelo ou móvel pode tapar o quadro): conferir na captura") end
      local near = workspace:Raycast(camPos, cam.CFrame.LookVector * 1.5)
      if near and near.Instance.Transparency < 0.5 then
        say(errs, i, s, "R18", "lente colada em " .. near.Instance:GetFullName() .. " (o quadro vira uma mancha): afastar a câmera ou tirar a peça da frente")
      end
      do -- R60: grade 5x7 de raios no quadro FINAL; metade ou mais batendo em algo a < 2,5 studs = quadro tapado
        local tanV = math.tan(math.rad(cam.FieldOfView) / 2) local tanH = tanV * 16 / 9
        local close, tot, what, av = 0, 0, {}, 0
        for gv = 1, 5 do for gh = 1, 7 do
          local sx = x0 + (1 - gv / 6) * w local sy = (gh / 8 - 0.5) * KEEP + 0.5
          local d = cam.CFrame:VectorToWorldSpace(Vector3.new((sx - 0.5) * 2 * tanH, -(sy - 0.5) * 2 * tanV, -1).Unit)
          local hit = workspace:Raycast(camPos, d * 2.5) tot += 1
          if hit and hit.Instance.Transparency < 0.5 then close += 1 what[hit.Instance.Name] = true if hit.Instance:IsDescendantOf(cast) then av += 1 end end
        end end
        if close / tot >= 0.5 then -- corpo/cabelo de avatar = ERRO; objeto (carta, prato) = AVISO, olhar se é inserto legível
          local l = {} for k in what do table.insert(l, k) end
          say(av * 2 >= close and errs or warns, i, s, "R60", string.format("%d%% do quadro tapado de perto (%s)", math.floor(100 * close / tot), table.concat(l, ",")))
        end
      end
      for _, part in workspace:GetPartBoundsInRadius(camPos, 0.25) do -- R61: câmera dentro de um avatar (o R9 ignora o elenco)
        if part.Transparency < 1 and part:IsDescendantOf(cast) and part.Name ~= "HumanoidRootPart" then say(errs, i, s, "R61", "câmera dentro do avatar " .. part.Parent.Name) break end
      end
      local want = opt.obj and opt.obj[i]
      local part = want and workspace:FindFirstChild(want, true)
      if want and a == 0.5 then
        if not part then say(errs, i, s, "R10", "objeto da fala '" .. want .. "' não existe")
        else
          local pos = part:IsA("Model") and part:GetPivot().Position or part.Position
          local size = part:IsA("Model") and part:GetExtentsSize().Magnitude or part.Size.Magnitude
          local v, h, r = project(pos, size)
          if not v or v < r or v > 1 - r or h < r or h > 1 - r then
            say(errs, i, s, "R10", "objeto da fala '" .. want .. "' fora do quadro ou cortado")
          elseif math.abs(v - 0.5) < band + 0.5 * r then
            say(errs, i, s, "R19", "objeto da fala '" .. want .. "' atrás da legenda (texto de bilhete ou placa fica ilegível): enquadrar acima ou abaixo do meio")
          end
        end
      end
    end
    if i % 10 == 0 then task.wait() end
  end
  if not running then F.finalize() end
  local out = { string.format("CHECK %s: %d erros, %d avisos em %d planos", #errs == 0 and "OK" or "FAILED", #errs, #warns, #F.shots) }
  for _, e in errs do table.insert(out, "ERRO  " .. e) end
  for _, e in warns do table.insert(out, "AVISO " .. e) end
  return table.concat(out, "\n")
end

return C
