# Roblox Studio Video Engine

Motor que produz vídeos verticais narrados (1080x1920, 60 fps) **filmados dentro do Roblox Studio** e montados por scripts em Python e FFmpeg.

## Como funciona

1. **Roteiro** em JSON, uma fala por item.
2. **Voz** por API de TTS (`gerar_voz_fish.py` ou `gerar_voz.py`), com o tempo de cada palavra.
3. **Tempos**: `tempos.py` converte a voz na tabela de tempos que o motor Luau lê.
4. **Filme**: `luau/Lava.luau` é um episódio completo que serve de molde (câmeras, poses, rostos desenhados, lista de planos); `luau/LavaPlayer.luau` toca o filme.
5. **Conferência automática**: `luau/Check.luau` posa cada plano em 10 %, 50 % e 90 % e mede o enquadramento antes de gravar.
6. **Gravação**: `gravar.py` acha o viewport do Studio na tela e grava só ele.
7. **Montagem**: `montar.py` acha o início pela claquete branca, gira, recorta e queima a legenda palavra por palavra; `musica.py` põe a trilha e ajusta a -14 LUFS.
8. **Revisão**: `revisar.py` (quadros pretos e congelados), `vozcheck.py` (fala x roteiro) e `escuro.py` (brilho).

O guia do motor está em [docs/motor.md](docs/motor.md).

## Requisitos

Windows, Roblox Studio, FFmpeg com `ddagrab`, Python 3.10+, `numpy` e `faster-whisper`.

| Variável | Uso |
|---|---|
| `FISH_API_KEY` / `ELEVENLABS_API_KEY` | voz |
| `SFX_DIR` | pasta dos efeitos sonoros citados em `mixar.py` |
| `MUSIC_DIR` | pasta com as faixas `.mp3` (uma por vídeo, em rodízio) |
| `STUDIO_PLACE` | opcional: nome do place, se houver mais de um Studio aberto |

Áudios, músicas, avatares e o place do Roblox não fazem parte do repositório.

## Tecnologias

Luau, Roblox Studio, Python, FFmpeg, Whisper, APIs REST.
