# R64 (2026-11-20): rosto escuro demais no celular. Mede o brilho médio (Y 0-255) do miolo do quadro final
# (faixa onde ficam os rostos: 15-85 % da largura, 45-90 % da altura, abaixo da legenda) a 2 quadros por segundo.
# Trecho de 1 s ou mais com média < LIMITE = ERRO (follower-mayor v2: 86-120 s a ~25-40 ficou ilegível; legível >= 55).
# Uso: python ../escuro.py emily_final.mp4 [limite=50]
import re, subprocess, sys
vid = sys.argv[1]; lim = float(sys.argv[2]) if len(sys.argv) > 2 else 50
r = subprocess.run(['ffmpeg', '-hide_banner', '-nostats', '-i', vid, '-vf',
                    'fps=2,crop=iw*0.7:ih*0.45:iw*0.15:ih*0.45,signalstats,metadata=print:key=lavfi.signalstats.YAVG:file=-',
                    '-an', '-f', 'null', '-'], capture_output=True, text=True).stdout
ys = [float(x) for x in re.findall(r'YAVG=([\d.]+)', r)]
runs, cur = [], None
for k, y in enumerate(ys):
    if y < lim: cur = [k, k] if cur is None else [cur[0], k]
    elif cur: runs.append(cur); cur = None
if cur: runs.append(cur)
bad = [(a / 2, (b + 1) / 2, min(ys[a:b + 1])) for a, b in runs if b - a >= 1]
print(f'escuro (< {lim:.0f}, >= 1 s): ' + (', '.join(f'{a:.1f}-{b:.1f} s (min {m:.0f})' for a, b, m in bad) if bad else 'nenhum'))
sys.exit(1 if bad else 0)
