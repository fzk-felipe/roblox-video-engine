# Ep. 2: narração contínua. Calcula o tempo de cada plano pela voz, mixa voz + efeitos e grava os tempos no roteiro.
import json, os, subprocess, pathlib
here = pathlib.Path(__file__).parent
rot = here.parent / 'emily_roteiro.json'
shots = json.load(open(rot, encoding='utf-8'))
FX = pathlib.Path(os.environ['SFX_DIR'])
SFX = {'ding': ('ding-sound-effect_1_CVUaI0C.mp3', 0.30), 'boom': ('vine-boom (4).mp3', 0.50), 'pop': ('pop-sound-effect_AsEdnw2.mp3', 0.55),
       'whoosh': ('whoosh-wind.mp3', 0.45), 'meow': ('meow-1 (1).mp3', 0.6), 'yay': ('yay-roblox (2).mp3', 0.4), 'bonk': ('bonk_7zPAD7C (1).mp3', 0.5),
       'cricket': ('awkward-cricket-sound-effect_YK6dDJG.mp3', 0.5), 'huh': ('huh-roblox (1).mp3', 0.5), 'riser': ('popular-riser-metallic-sound-effect (1).mp3', 0.3)}
# fala -> (efeito, 's' no começo da fala | 'e' no fim da voz)
CUES = {n: ('boom', 'e') for n in (7, 9, 14, 17, 38, 40, 52, 59, 64, 71)}  # só vine boom, nas piadas (trocar os números a cada episódio)
SCENE = set()  # regra da skill: nenhum whoosh
LEAD, PAD, PAD_BOOM, SILENT, TEMPO = 0.03, 0.02, 0.3, 1.6, 1.11  # ep. 4: almost no breath between lines
PITCH = 1.0  # narrador aprovado (2026-11-17): voz "Roblox" do Fish Audio (gerar_voz_fish.py), só acelerada 1,11x
def dur(p): return float(subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', str(p)]).decode())
cmd, flt, labels, t = ['ffmpeg', '-y', '-loglevel', 'error'], [], [], 0.0
def add(f, at, chain):
    i = len(labels); cmd.extend(['-i', str(f)])
    flt.append(f'[{i}]aresample=44100,aformat=channel_layouts=stereo,{chain}adelay={int(at*1000)}:all=1[a{i}]'); labels.append(f'[a{i}]')
for s in shots:
    cue = CUES.get(s['n']); v = 0
    if s['line']:
        f = here / 'linhas2' / f"{s['n']:02d}.mp3"; v = dur(f) / TEMPO
        add(f, t + LEAD, f'asetrate=44100*{PITCH},aresample=44100,atempo={TEMPO / PITCH:.4f},')
    d = round(LEAD + v + (PAD_BOOM if cue and cue[1] == 'e' else PAD) + s.get('pausa', 0), 2) if s['line'] else SILENT   # pausa = silêncio planejado depois da fala (skill historias.md §9)
    s['start'], s['end'], s['voice'] = round(t, 2), round(t + d, 2), round(v, 2)
    s.pop('sfx', None); s.pop('sfx_t', None); s.pop('words', None)
    if s['line']:  # tempo de cada palavra no filme (para a legenda)
        al = json.load(open(here / 'linhas2' / f"{s['n']:02d}.json", encoding='utf-8'))
        words, cur = [], None
        for ch, a, b in zip(al['chars'], al['start'], al['end']):
            if ch.isspace(): cur = None; continue
            if cur is None: cur = [ch, a, b]; words.append(cur)
            else: cur[0] += ch; cur[2] = b
        s['words'] = [[w, round(t + LEAD + a / TEMPO, 2), round(t + LEAD + b / TEMPO, 2)] for w, a, b in words]
    if cue and cue[0] == 'boom':  # só o vine boom toca; os outros cues só seguram o tempo do plano
        name, vol = SFX[cue[0]]; at = t if cue[1] == 's' else t + LEAD + v + 0.03
        s['sfx'], s['sfx_t'] = cue[0], round(at, 2)
        add(FX / name, at, f'atrim=0:1.6,afade=t=out:st=1.2:d=0.4,volume={vol},')
    if s['n'] in SCENE and s['line']:  # ep. 4: soft whoosh on every change of place
        add(FX / SFX['whoosh'][0], max(0, t - 0.08), 'atrim=0:0.9,afade=t=out:st=0.6:d=0.3,volume=0.22,')
    t += d
total = round(t, 2)
flt.append(''.join(labels) + f'amix=inputs={len(labels)}:normalize=0,apad,atrim=0:{total},alimiter=limit=0.95[out]')
script = here / '_mix.txt'; script.write_text(';'.join(flt))
subprocess.check_call(cmd + ['-/filter_complex', str(script), '-map', '[out]', '-b:a', '192k', str(here.parent / 'emily_audio.mp3')])
json.dump(shots, open(rot, 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
print('total', total, 'media por fala', round(total / len(shots), 2))



