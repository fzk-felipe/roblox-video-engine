# Confere a voz do vídeo pronto contra o roteiro (não dá para ouvir: o Whisper ouve). Diferença que não seja número
# escrito em algarismo ou troca de transcrição é erro de voz: gerar a fala de novo.
# Uso: python vozcheck.py emily_final.mp4 emily_roteiro.json
import difflib, json, re, sys
sys.stdout.reconfigure(encoding='utf-8')
from faster_whisper import WhisperModel
vid, rot = sys.argv[1], sys.argv[2]
want = re.findall(r"[a-z0-9']+", ' '.join(s['line'] for s in json.load(open(rot, encoding='utf-8'))).lower())
segs, _ = WhisperModel('medium.en', device='cpu', compute_type='int8').transcribe(vid, beam_size=5)
got = re.findall(r"[a-z0-9']+", ' '.join(s.text for s in segs).lower())
sm = difflib.SequenceMatcher(None, want, got, autojunk=False)
print('palavras do roteiro', len(want), 'ouvidas', len(got), 'semelhança', round(sm.ratio(), 3))
for tag, i1, i2, j1, j2 in sm.get_opcodes():
    if tag != 'equal':
        print(tag, want[max(0, i1 - 2):i2 + 2], '->', got[max(0, j1 - 2):j2 + 2])
