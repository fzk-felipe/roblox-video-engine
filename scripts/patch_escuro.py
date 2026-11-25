# Tapa inícios escuros de plano (a luz do set demora ~0,5 s para assentar ao trocar de cenário):
# os quadros [a, b) viram cópias do quadro b. O número de quadros não muda; o áudio é copiado.
# Uso: python patch_escuro.py entrada.mp4 saida.mp4 a1:b1 a2:b2 ...
import subprocess, sys
src, dst, cuts = sys.argv[1], sys.argv[2], [tuple(map(int, c.split(':'))) for c in sys.argv[3:]]
parts, last, fc = [], 0, []
for k, (a, b) in enumerate(sorted(cuts)):
    fc.append(f'[0:v]trim=start_frame={last}:end_frame={a},setpts=PTS-STARTPTS[s{k}]')
    fc.append(f'[0:v]trim=start_frame={b}:end_frame={b + 1},setpts=PTS-STARTPTS,loop=loop={b - a - 1}:size=1:start=0,setpts=N/60/TB[f{k}]')
    parts += [f'[s{k}]', f'[f{k}]']
    last = b
fc.append(f'[0:v]trim=start_frame={last},setpts=PTS-STARTPTS[e]')
parts.append('[e]')
fc.append(''.join(parts) + f'concat=n={len(parts)}:v=1:a=0[v]')
subprocess.check_call(['ffmpeg', '-y', '-v', 'error', '-i', src, '-filter_complex', ';'.join(fc), '-map', '[v]', '-map', '0:a?', '-c:a', 'copy',
                       '-c:v', 'libx264', '-crf', '16', '-preset', 'medium', '-pix_fmt', 'yuv420p', '-r', '60', dst])
n = subprocess.check_output(['ffprobe', '-v', 'error', '-count_frames', '-select_streams', 'v:0', '-show_entries', 'stream=nb_read_frames', '-of', 'csv=p=0', dst]).decode().strip()
print('ok', dst, n, 'quadros')
