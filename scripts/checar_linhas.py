# Transcreve cada fala gerada (whisper medium.en) e lista as que não batem com o roteiro.
import json, pathlib, re, difflib
from faster_whisper import WhisperModel
here = pathlib.Path(__file__).parent
shots = json.load(open(here.parent / 'emily_roteiro.json', encoding='utf-8'))
wm = WhisperModel('medium.en', device='cpu', compute_type='int8')
norm = lambda s: re.sub(r'[^a-z0-9 ]', '', s.lower().replace('-', ' ')).split()
for s in [s for s in shots if s['line']]:
    heard = ' '.join(seg.text for seg in wm.transcribe(str(here / 'linhas2' / f"{s['n']:02d}.mp3"))[0])
    r = difflib.SequenceMatcher(None, norm(s['line']), norm(heard)).ratio()
    if r < 0.9: print(f"{s['n']:2d} {r:.2f} | {s['line']} | {heard.strip()}")
print('fim')
