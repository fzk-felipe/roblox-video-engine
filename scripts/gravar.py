# Grava SÓ o viewport do jogo no Studio a 60 fps, sem ninguém apertar nada: substitui a gravação manual do usuário.
# Traz o Studio para a frente e maximiza; espera o Play começar, acha o viewport pela borda azul e grava só ele.
# (F11 não esconde os painéis do Studio: testado. Fechar os painéis laterais deixa o viewport maior e o vídeo mais nítido.)
# Uso: python gravar.py <saida.mp4> <segundos> [crop=auto|largura:altura:x:y] [espera=6]
#   Rodar com run_in_background e dar Play pelo MCP logo em seguida; "espera" = segundos até o Play aparecer na tela.
#   segundos = prewarm (~85 s) + duração do filme + ~15 s de folga.
#   Depois: python inicio.py <saida.mp4> 150 e python montar.py <saida.mp4> <início> - <largura:altura:0:0> 0.68 (já vem recortada)
import os
import ctypes, subprocess, sys, time
import numpy as np
out, secs = sys.argv[1], float(sys.argv[2])
crop = sys.argv[3] if len(sys.argv) > 3 else 'auto'
u = ctypes.windll.user32
hits = []
def cb(hw, _):
    b = ctypes.create_unicode_buffer(512); u.GetWindowTextW(hw, b, 512)
    if u.IsWindowVisible(hw) and (b.value.startswith(os.environ['STUDIO_PLACE'] + ' - Roblox Studio') if os.environ.get('STUDIO_PLACE') else 'Roblox Studio' in b.value): hits.append(hw)  # STUDIO_PLACE = nome do place (vídeo / video1 / video2) quando há vários Studios
    return True
u.EnumWindows(ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)(cb), 0)
if not hits:
    raise SystemExit('janela do Roblox Studio não encontrada')
u.ShowWindow(hits[0], 9); u.SetWindowPos(hits[0], 0, 100, 100, 1200, 800, 0x0004); u.ShowWindow(hits[0], 3)  # leva ao monitor PRINCIPAL antes de maximizar (com 2 monitores a captura só vê o principal)
import ctypes.wintypes as _wt
_r = _wt.RECT(); u.GetWindowRect(hits[0], ctypes.byref(_r))
if not (-20 <= _r.left <= 20 and -20 <= _r.top <= 20): raise SystemExit(f'Studio fora do monitor principal ({_r.left},{_r.top}): abortado para não capturar outra janela')
u.keybd_event(0x12, 0, 0, 0); u.SetForegroundWindow(hits[0]); u.keybd_event(0x12, 0, 2, 0)  # Alt libera o SetForegroundWindow
time.sleep(float(sys.argv[4]) if len(sys.argv) > 4 else 6)
if crop == 'auto':  # borda azul de 2 px em volta do viewport do Play
    raw = subprocess.check_output(['ffmpeg', '-v', 'error', '-f', 'lavfi', '-i', 'ddagrab=output_idx=0:framerate=10,hwdownload,format=bgra',
                                   '-frames:v', '1', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'])
    img = np.frombuffer(raw, np.uint8).reshape(1080, 1920, 3).astype(int)
    r, g, b = img[..., 0], img[..., 1], img[..., 2]
    blue = (b > 150) & (b - r > 60) & (b - g > 30)
    cols, rows = np.where(blue.sum(0) > 500)[0], np.where(blue.sum(1) > 800)[0]
    if len(cols) < 2 or len(rows) < 2:
        raise SystemExit('borda azul do viewport não encontrada: o Play começou? passe o crop à mão')
    x, y = cols.min() + 2, rows.min() + 2
    w, h = (cols.max() - 1 - x) // 2 * 2, (rows.max() - 1 - y) // 2 * 2
    crop = f'{w}:{h}:{x}:{y}'
w, h, x, y = crop.split(':')
print('viewport', crop, flush=True)
# a janela que vier por cima (o app do Claude ao chegar mensagem) sai no vídeo: trazer o Studio de volta a cada 0,5 s e contar
import threading, atexit
u.SetWindowPos(hits[0], -1, 0, 0, 0, 0, 0x0003)  # HWND_TOPMOST: nenhuma janela passa por cima durante a gravação
atexit.register(lambda: u.SetWindowPos(hits[0], -2, 0, 0, 0, 0, 0x0003))  # volta ao normal no fim
lost = [0]
def guard():
    end = time.time() + secs
    while time.time() < end:
        if u.GetForegroundWindow() != hits[0]:
            lost[0] += 1
            u.keybd_event(0x12, 0, 0, 0); u.SetForegroundWindow(hits[0]); u.keybd_event(0x12, 0, 2, 0)
        time.sleep(0.5)
threading.Thread(target=guard, daemon=True).start()
dda = f'ddagrab=output_idx=0:framerate=60:video_size={w}x{h}:offset_x={x}:offset_y={y}'  # Desktop Duplication (58-60 fps)
r = subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-f', 'lavfi', '-i', dda, '-t', str(secs),
                    '-c:v', 'h264_nvenc', '-preset', 'p5', '-cq', '18', out])  # GPU: não rouba CPU do Studio
if r.returncode:  # sem NVENC: CPU no modo mais leve
    subprocess.check_call(['ffmpeg', '-y', '-loglevel', 'error', '-f', 'lavfi', '-i', dda + ',hwdownload,format=bgra', '-t', str(secs),
                           '-c:v', 'libx264', '-preset', 'ultrafast', '-crf', '18', '-pix_fmt', 'yuv420p', out])
d = subprocess.check_output(['ffprobe', '-v', 'error', '-count_frames', '-show_entries', 'stream=nb_read_frames',
                             '-show_entries', 'format=duration', '-of', 'csv=p=0', out]).decode().split()
fps = int(d[0]) / float(d[-1])
print(f'ok {out} {float(d[-1]):.1f} s, {fps:.1f} fps efetivos, crop {w}:{h}:0:0 para montar.py' + ('' if fps > 55 else '  <- quadros perdidos: fechar programas pesados e regravar'))
print(f'Studio perdeu a frente {lost[0]} vez(es)' + ('' if lost[0] == 0 else '  <- conferir na revisão se outra janela apareceu no vídeo'))
