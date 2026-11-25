# Motor do filme no Studio (`assets/Lava.luau`, `assets/LavaPlayer.luau`)

Os dois arquivos são o episódio 2 inteiro e servem de molde: trocar `END`, `BOOM`, origens `O`, os presets de cena (`home`, `street`, `gym`…) e as linhas `S(...)`; manter rosto, poses, `reseat`, `finalize`, `M.pose`. Renomear `Ep2`/`Lava`/`LavaPlayer` para o episódio novo. Desabilitar (não apagar) o player do episódio anterior em `StarterPlayerScripts`.

## Hierarquia

```
workspace.EpN
  Cast   (Model)   avatares; atributos por avatar: Kind, RootH, HeadOff, Style, Skin
  World  (Folder)  um Folder por cenário + Props (peças que o motor move: PARK quando fora de cena)
  Ink    (Highlight, Adornee = Cast, FillTransparency 1, contorno escuro)
ReplicatedStorage.Film.<Modulo>          lista de planos + poser
StarterPlayerScripts.<Modulo>Player      relógio, câmera, animações Roblox
```

Cada cenário fica longe um do outro (ex.: origens x=-3000, z=0/300/600). `PARK = CFrame.new(-3000,-300,0)` guarda quem não está no plano.

## Elenco

- Clonar rigs de `workspace.Cast` (não mexer nos originais). `Kind="rig"`: R15 com `AnimationConstraint`; `RootH` = altura do HumanoidRootPart sobre o chão; `HeadOff` = Vector3 do root até a cabeça.
- Rosto: limpar `Head.TextureID` (guardar em atributo `FaceTex`), criar `SurfaceGui` "Face" na frente da cabeça; `drawFace` desenha com Frames. `Style` é texto livre com palavras: `glasses`, `mustache`, `wmustache`, `wbrow`, `lashes`, `freckles`, `cat`, `dog`. A protagonista Emily fica com o rosto original (sem gui → usa `FaceControls`).
- Bichos da Toolbox: `Kind="rigid"`, Part invisível "Head", sem scripts.
- Figurantes: clones dos mesmos avatares com roupa tingida; o player espera `#Cast:GetChildren() >= N` — atualizar N.

## Lista de planos

`S(fala, cenario, camera, atores, opt)` — vários `S` com a mesma fala dividem o tempo dela com `opt.f = {inicio, fim}` (frações). `opt.P` move props (ex.: `Bus = {{de}, {para}}`).

Câmera:
- `cu("Nome", { d = distância (3.6), yaw = graus, h = sobe a câmera, lo = desce o alvo, fov = 36 })` — close no rosto, segue o ator.
- `ab({pos}, {alvo}, fov, pos2)` — absoluta, relativa à origem do cenário.

Ator (`atores[Nome] = {...}`; `false` remove do preset):
- `at = {x,y,z}`, `to = {x,y,z}` (desloca ao longo do plano), `arc` (altura do pulo), `ry` (giro; 0 = de frente para +Z do cenário após o 180 interno).
- `pose` = chave de `POSE` (pose por código) **ou** `anim` = chave de `M.ANIMS` (animação Roblox; só toca no Play).
- `face` = chave de `EXPR`; a expressão também aciona atuação (recuo no susto, pulinho na risada, cabeça baixa no choro, tremor no nervoso).
- `still` congela, `shake`/`nod` mexem a cabeça, `hy` vira a cabeça.

Poses existentes: stand, balance, up, point, sit, sitf, hug, eat, wave, dip, cover, flamingo, stride, jump, hang, flat, cartwheel, cheer, run, skate, shrug, hi, walk, hold, lift. Nova pose = uma linha em `POSE` (`la/ra/ll/rl = {pitch, roll}`, `le/re/lk/rk` = cotovelo/joelho, `hip` = sentado, `lean`, `tilt`, `wob`).

Rostos: neutral, smile, happy, laugh, shock, scream, sad, cry, angry, stern, smug, nervous, half, tired, focus, o, teeth, grin, squint, stare, dry, closed, catstare.

## Trabalhar no Edit

```lua
_G.F = require(game.ReplicatedStorage.Film.Lava:Clone())
_G.shot = function(i, a) local s = _G.F.shots[i] a = a or 0.5 _G.F.pose(i, a, s.t0 + (s.t1 - s.t0) * a, workspace.CurrentCamera) return "shot " .. i .. " line " .. s.line end
-- varredura: todos os planos sem erro
local errs = 0 for i = 1, #_G.F.shots do if not pcall(_G.shot, i) then errs += 1 end end
_G.F.finalize()   -- sempre por último; conferir que nenhuma constraint ficou Enabled=false
```

Editar o código: `local m = game.ReplicatedStorage.Film.Lava; local src = m.Source; local i, j = src:find(antigo, 1, true); m.Source = src:sub(1, i-1) .. novo .. src:sub(j+1)`. Depois de mudar no Studio, atualizar a cópia em disco do projeto.

Objetos de cena específicos de uma fala (vassoura com sopa, bilhete, placa) são Parts fixas no cenário, posicionadas para o enquadramento daquele plano; conferir na captura que o objeto da fala aparece inteiro e de frente.

## Luz e look (igual ao ep. 1)

Sol forte com sombra, `DepthOfFieldEffect` (o motor ajusta o foco por plano), contorno escuro pelo `Ink`, materiais texturizados (WoodPlanks, Brick, Fabric, Concrete), luz de dia. Efeitos de regra mágica (lava) = Parts neon + `ParticleEmitter` em `Props`, ligados pelo motor conforme a fala.

## Novidades da v2 (em relação ao motor do ep. 2)

- **Rosto fora da legenda por padrão**: em `cu(...)` sem `lo`, a câmera mira `0,19 × distância` abaixo da cabeça, então o rosto fica a ~30 % do topo do quadro vertical e a legenda (meio da tela) cai no peito. `lo` explícito continua valendo; plano `ab(...)` precisa enquadrar o rosto acima de 40 % ou abaixo de 65 % à mão.
- **Claquete**: `LavaPlayer.luau` pisca a tela de branco por 0,2 s antes do primeiro quadro; `scripts/inicio.py` acha esse piscar na gravação e `montar.py` usa o resultado (`auto`). Não remover.
- **Conferência** (`assets/Check.luau`): colocar como `ReplicatedStorage.Film.Check` e rodar no Edit:

```lua
local F = require(game.ReplicatedStorage.Film.Lava:Clone())
local Check = require(game.ReplicatedStorage.Film.Check:Clone())
return Check.run(F, { cast = workspace.Ep2.Cast, obj = { [57] = "Note" } })   -- obj: peça que a fala mostra, por número de PLANO
```

Posa cada plano em 10 %, 50 % e 90 %, projeta no quadro final (girado, recorte `x0`/`w` da gravação, 16:9) e devolve `CHECK OK` ou `CHECK FAILED` com uma linha por problema; chama `finalize()` no fim. Códigos `R1`–`R10`, `R18` e `R19` = regras de [regras.md](regras.md). Se o recorte da gravação mudar (cropdetect), passar `x0` e `w` novos. A conferência mede caixas e pontos, não a malha: mão atravessando objeto e roupa atravessando roupa só aparecem na captura.

A conferência também roda **dentro do Play** (`execute_luau` no DataModel `Client`, depois do `LAVA_DONE`): nada do que ela mexe é salvo, então serve para medir um filme sem sair do Play. Testada assim no ep. 2 (2026-11-15): 96 planos, acusou os mesmos erros vistos nas folhas (rosto a 50 % do topo em quase todo close, lente na cabeça da Emily em 107,2 s, mesa tapando os rostos em 121,2 s, Emily de costas em 75,9 s). Corrigir os planos continua exigindo o modo de edição.
