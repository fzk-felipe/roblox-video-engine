# Captura em sequência os planos que o Studio posa no Edit (o Luau posa o plano k no instante start + k*step).
# Uso: python capseq.py <start_epoch_s> <n> <step_s> <pasta> [primeiro=1]
import os
import ctypes, subprocess, sys, time, pathlib
import numpy as np
start, n, step, out = float(sys.argv[1]), int(sys.argv[2]), float(sys.argv[3]), pathlib.Path(sys.argv[4])
first = int(sys.argv[5]) if len(sys.argv) > 5 else 1
out.mkdir(exist_ok=True)
u = ctypes.windll.user32
hits = []
def cb(hw, _):
    b = ctypes.create_unicode_buffer(512); u.GetWindowTextW(hw, b, 512)
    if u.IsWindowVisible(hw) and (b.value.startswith(os.environ['STUDIO_PLACE'] + ' - Roblox Studio') if os.environ.get('STUDIO_PLACE') else 'Roblox Studio' in b.value): hits.append(hw)  # STUDIO_PLACE = nome do place (vídeo / video1 / video2) quando há vários Studios
    return True
u.EnumWindows(ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)(cb), 0)
u.ShowWindow(hits[0], 9); u.SetWindowPos(hits[0], 0, 100, 100, 1200, 800, 0x0004); u.ShowWindow(hits[0], 3)  # leva ao monitor PRINCIPAL antes de maximizar (com 2 monitores a captura só vê o principal)
import ctypes.wintypes as _wt
_r = _wt.RECT(); u.GetWindowRect(hits[0], ctypes.byref(_r))
if not (-20 <= _r.left <= 20 and -20 <= _r.top <= 20): raise SystemExit(f'Studio fora do monitor principal ({_r.left},{_r.top}): abortado para não capturar outra janela')
u.keybd_event(0x12, 0, 0, 0); u.SetForegroundWindow(hits[0]); u.keybd_event(0x12, 0, 2, 0)
x0, y0, x1, y1 = 286, 145, 1442, 1010
u.SetWindowPos(hits[0], -1, 0, 0, 0, 0, 0x0003)   # HWND_TOPMOST: other windows cannot cover the viewport
for k in range(n):
    t = start + k * step + step * 0.7   # pose happens at start + k*step; grab late in the slot
    while time.time() < t - 0.4: time.sleep(0.02)
    u.keybd_event(0x12, 0, 0, 0); u.SetForegroundWindow(hits[0]); u.keybd_event(0x12, 0, 2, 0)
    while time.time() < t: time.sleep(0.02)
    raw = subprocess.check_output(['ffmpeg', '-v', 'error', '-f', 'lavfi', '-i', 'ddagrab=output_idx=0:framerate=10,hwdownload,format=bgra',
                                   '-frames:v', '1', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'])
    img = np.frombuffer(raw, np.uint8).reshape(1080, 1920, 3)[y0:y1, x0:x1]
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', f'{x1-x0}x{y1-y0}', '-i', '-',
                    '-vf', 'transpose=2,crop=iw*0.82:ih,scale=-2:420', str(out / f'{first + k:03d}.png')], input=img.tobytes(), check=True)
u.SetWindowPos(hits[0], -2, 0, 0, 0, 0, 0x0003)
print('ok', n)
