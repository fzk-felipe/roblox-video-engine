# Gravação de lado -> vertical 1080x1920 a 60 fps com legenda estilo "In This World": 1 palavra minúscula, Lilita One, no terço de cima e áudio.
# Uso: python montar.py "gravacao.mp4" [inicio_s|auto] [sufixo|-] [crop|-] [altura_da_legenda]
#   inicio: "auto" (padrão) acha a claquete branca do player com inicio.py; ou o tempo em segundos do primeiro quadro do filme
#   crop:   recorte da gravação antes de girar; conferir com cropdetect (padrão: 1572:1080:174:0, gravação 1920x1080)
#   altura: centro da legenda em fração da altura (0.5 = meio); uma fala pode ter a sua com "leg_y" no roteiro. Gravação antiga com rosto no meio do quadro: 0.76
import json, subprocess, sys, pathlib
here = pathlib.Path(__file__).parent
rec = sys.argv[1]
arg = sys.argv[2] if len(sys.argv) > 2 else 'auto'
if arg == 'auto':
    sys.path.insert(0, str(here)); sys.path.insert(0, str(here / 'scripts'))
    from inicio import inicio
    START = inicio(rec)
    print('início do filme na gravação:', round(START, 3), 's')
else:
    START = float(arg)
CROP = sys.argv[4] if len(sys.argv) > 4 and sys.argv[4] != '-' else '1572:1080:174:0'
LEG_Y = 0.30  # terço de cima, acima dos personagens (estilo In This World; ignora o 5º argumento antigo)
SUF = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '-' else ''  # '' = português, '_en' = inglês
# Fonte da legenda por canal (youtube.json da pasta); fontes em ../../fonts
CANAL = json.load(open(here / 'youtube.json', encoding='utf-8'))['canal'] if (here / 'youtube.json').exists() else 'default'
STYLE = {  # nome da fonte, tamanho, negrito, cor (ASS &HBBGGRR), contorno; acrescente um por canal
    'default': ('Lilita One', 140, 0, '&H00FFFFFF', 7),
}[CANAL]
shots = json.load(open(here / f'emily_roteiro{SUF}.json', encoding='utf-8'))
TOTAL, SKIP = shots[-1]['end'], 0.0

def chunks(words):  # pedaços de 1 a 3 palavras, quebrando na pontuação; cada palavra traz o seu tempo falado
    out, cur = [], []
    for w in words:
        if cur:  # uma palavra por vez
            out.append(cur); cur = []
        cur.append(w)
    return out + [cur]

def ts(t): return f'{int(t // 3600)}:{int(t // 60) % 60:02d}:{t % 60:05.2f}'

ev, cues = [], []
for s in shots:
    if s['line']: cues += [(' '.join(w[0] for w in c).strip('.,:;!?"').lower(), c[0][1], c[-1][2], s.get('leg_y', LEG_Y)) for c in chunks(s['words'])]
for i, (text, c0, t1, ly) in enumerate(cues):  # cada trecho fica na tela até o próximo começar (no máximo 0,35 s depois da fala)
    end = min(t1 + 0.35, cues[i + 1][1]) if i + 1 < len(cues) else t1 + 0.35
    ev.append(f"Dialogue: 0,{ts(c0)},{ts(end)},L,,0,0,0,,{{\\an5\\pos(540,{round(1920 * ly)})}}{text}")
assert all(a.split(',')[2] <= b.split(',')[1] for a, b in zip(ev, ev[1:])), 'legendas sobrepostas'
(here / 'legendas.ass').write_text(f"""[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
WrapStyle: 2

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: L,{STYLE[0]},{STYLE[1]},{STYLE[3]},&H00FFFFFF,&H00000000,&H80000000,{-STYLE[2]},0,0,0,100,100,0,0,1,{STYLE[4]},0,5,60,60,0,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
""" + chr(10).join(ev) + chr(10), encoding='utf-8')

vf = (f'crop={CROP},transpose=2,'
      'scale=-2:1920,crop=1080:1920,ass=legendas.ass:fontsdir=../../fonts')
subprocess.check_call(['ffmpeg', '-y', '-loglevel', 'error', '-ss', str(START + SKIP), '-i', rec, '-i', f'emily_audio{SUF}.mp3',
                       '-vf', vf, '-map', '0:v', '-map', '1:a', '-t', str(TOTAL), '-r', '60',
                       '-c:v', 'libx264', '-crf', '18', '-preset', 'medium', '-pix_fmt', 'yuv420p',
                       '-c:a', 'aac', '-b:a', '192k', '-movflags', '+faststart', f'emily_final{SUF}.mp4'], cwd=here)
print('ok', len(ev), 'legendas')
