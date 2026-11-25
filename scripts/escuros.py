# Acha inícios de plano escuros: brilho médio dos primeiros quadros bem abaixo do brilho do plano assentado.
# Uso: python escuros.py emily_final.mp4  -> imprime pares a:b para patch_escuro.py
import subprocess, sys
import numpy as np
T0 = [float(x) for x in open('t0.txt').read().split(',')]
W, H = 96, 170
raw = subprocess.check_output(['ffmpeg', '-v', 'error', '-i', sys.argv[1], '-vf', f'scale={W}:{H},format=gray', '-f', 'rawvideo', '-'])
fr = np.frombuffer(raw, np.uint8).reshape(-1, H, W)[:, :int(H * 0.45)]   # top part (no captions)
lum = fr.reshape(len(fr), -1).mean(1)
out = []
for k, t in enumerate(T0):
    a = round(t * 60)
    end = round(T0[k + 1] * 60) if k + 1 < len(T0) else len(lum)
    if end - a < 20: continue
    ref = np.median(lum[a + int((end - a) * 0.7):end])
    b = a
    while b < a + int((end - a) * 0.75) and lum[b] < ref * 0.85: b += 1
    if b - a >= 3: out.append(f'{a}:{b}'); print(f'plano {k + 1} t={t:.2f} escuro {b - a} quadros ({lum[a]:.0f} vs {ref:.0f})', file=sys.stderr)
print(' '.join(out))
