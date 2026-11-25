# Uma fala por arquivo no ElevenLabs, com o tempo de cada letra (para a legenda seguir a palavra falada).
# A chave vem de $ELEVENLABS_API_KEY e nunca é impressa. Uso: python gerar_voz.py <voice_id>
import base64, json, os, sys, urllib.request, pathlib
here = pathlib.Path(__file__).parent
shots = json.load(open(here.parent / 'emily_roteiro.json', encoding='utf-8'))
voice, key = sys.argv[1], os.environ['ELEVENLABS_API_KEY']
out_dir = here / 'linhas2'; out_dir.mkdir(exist_ok=True)
lines = [s for s in shots if s['line']]
for i, s in enumerate(lines):
    mp3, js = out_dir / f"{s['n']:02d}.mp3", out_dir / f"{s['n']:02d}.json"
    if mp3.exists() and js.exists() and json.load(open(js, encoding='utf-8')).get('text') == s['line']: continue
    body = {'text': s['line'], 'model_id': 'eleven_turbo_v2_5',
            'previous_text': ' '.join(x['line'] for x in lines[max(0, i - 2):i]) or None,
            'next_text': ' '.join(x['line'] for x in lines[i + 1:i + 3]) or None,
            'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75}}
    body = {k: v for k, v in body.items() if v is not None}
    r = urllib.request.Request(f'https://api.elevenlabs.io/v1/text-to-speech/{voice}/with-timestamps?output_format=mp3_44100_128',
                               data=json.dumps(body).encode(), headers={'xi-api-key': key, 'Content-Type': 'application/json'})
    try:
        d = json.loads(urllib.request.urlopen(r, timeout=120).read())
    except urllib.error.HTTPError as e:
        print('ERR', s['n'], e.code, e.read()[:300]); sys.exit(1)
    mp3.write_bytes(base64.b64decode(d['audio_base64']))
    al = d['alignment']
    json.dump({'text': s['line'], 'chars': al['characters'], 'start': al['character_start_times_seconds'], 'end': al['character_end_times_seconds']}, open(js, 'w', encoding='utf-8'), ensure_ascii=False)
print('ok', len(list(out_dir.glob('*.mp3'))), 'falas')

