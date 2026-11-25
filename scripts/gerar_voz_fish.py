# Narrador aprovado (2026-11-17): voz pública "Roblox" do Fish Audio. Uma fala por arquivo; o tempo de cada palavra
# vem do Whisper (o Fish não devolve alinhamento) e é gravado no mesmo formato do ElevenLabs, então mixar.py não muda.
# A chave vem de $FISH_API_KEY e nunca é impressa. Uso: python gerar_voz_fish.py [reference_id]
import json, os, sys, urllib.request, pathlib
from faster_whisper import WhisperModel
here = pathlib.Path(__file__).parent
shots = json.load(open(here.parent / 'emily_roteiro.json', encoding='utf-8'))
voice = sys.argv[1] if len(sys.argv) > 1 else 'eb4bcc6dbb634e9eaee239c94266935e'
key = os.environ['FISH_API_KEY']
out_dir = here / 'linhas2'; out_dir.mkdir(exist_ok=True)
wm = WhisperModel('small.en', device='cpu', compute_type='int8')
for s in [s for s in shots if s['line']]:
    mp3, js = out_dir / f"{s['n']:02d}.mp3", out_dir / f"{s['n']:02d}.json"
    if mp3.exists() and js.exists() and json.load(open(js, encoding='utf-8')).get('text') == s['line']: continue
    r = urllib.request.Request('https://api.fish.audio/v1/tts', data=json.dumps({'text': s['line'], 'reference_id': voice, 'format': 'mp3', 'latency': 'normal'}).encode(),
                               headers={'Authorization': 'Bearer ' + key, 'Content-Type': 'application/json', 'model': os.environ.get('FISH_MODEL', 's2.1-pro-free')})
    try: mp3.write_bytes(urllib.request.urlopen(r, timeout=180).read())
    except urllib.error.HTTPError as e: print('ERR', s['n'], e.code, e.read()[:300]); sys.exit(1)
    words = [w for seg in wm.transcribe(str(mp3), word_timestamps=True)[0] for w in seg.words]
    # as palavras do roteiro recebem, em ordem, os tempos das palavras ouvidas (o texto da legenda é sempre o do roteiro)
    script = s['line'].split()
    chars, st, en = [], [], []
    for i, w in enumerate(script):
        h = words[min(i, len(words) - 1)] if words else None
        a, b = (h.start, h.end) if h else (0, 0)
        if i >= len(words) and words: a = b = words[-1].end
        for c in w: chars.append(c); st.append(a); en.append(b)
        if i < len(script) - 1: chars.append(' '); st.append(b); en.append(b)
    json.dump({'text': s['line'], 'chars': chars, 'start': st, 'end': en}, open(js, 'w', encoding='utf-8'), ensure_ascii=False)
    print(s['n'], len(script), 'palavras /', len(words), 'ouvidas')
print('ok', len(list(out_dir.glob('*.mp3'))), 'falas')
