# Põe a música de fundo no vídeo pronto, na mesma receita do Emily/shk/blender/episodio.py:
# voz+efeitos comprimidos e levados a -14 LUFS (como os reels de referência); música constante em -38 LUFS. O vídeo não é recodificado.
# Uso: python musica.py _en
import json, os, re, subprocess, sys, pathlib
here = pathlib.Path(__file__).parent; SUF = sys.argv[1] if len(sys.argv) > 1 else ''
MUS_DIR = pathlib.Path(os.environ['MUSIC_DIR']); TARGET = -14.0
FAIXAS = sorted(p.name for p in MUS_DIR.glob('*.mp3'))  # um short com cada, alternando
fixa, ult = here / 'musica.txt', MUS_DIR / '_ultima.txt'  # a escolha fica no episódio (rodar de novo não troca); _ultima.txt vale para todas as skills
if fixa.exists(): nome = fixa.read_text(encoding='utf-8').strip()
else:
    prev = ult.read_text(encoding='utf-8').strip() if ult.exists() else FAIXAS[-1]
    nome = FAIXAS[(FAIXAS.index(prev) + 1) % len(FAIXAS)] if prev in FAIXAS else FAIXAS[0]
    fixa.write_text(nome, encoding='utf-8'); ult.write_text(nome, encoding='utf-8')
mus = MUS_DIR / nome
voz, vid = here / f'emily_audio{SUF}.mp3', here / f'emily_final{SUF}.mp4'
BUS = '[0:a]aresample=48000,acompressor=threshold=-28dB:ratio=6:attack=3:release=90,alimiter=limit=0.9,apad[bus]'
def lufs(args):
    r = subprocess.run(['ffmpeg', '-hide_banner', '-nostats', *args, '-f', 'null', '-'], capture_output=True, text=True)
    return float(re.findall(r'I:\s+(-?[\d.]+) LUFS', r.stderr)[-1])
DUR = subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', str(vid)]).decode().strip()
base = lufs(['-i', str(voz), '-filter_complex', BUS + ';[bus]ebur128[a]', '-map', '[a]', '-t', DUR])
trim, tmp = 3.2, here / '_mus_tmp.mp4'
for _ in range(6):  # o limitador come um pouco de volume: ajusta o ganho até o resultado medido bater no alvo
    fc = (BUS + f';[bus]volume={TARGET - base + trim:.2f}dB,alimiter=limit=0.8:attack=2:release=60:level=disabled[bl]'
          ';[1:a]aresample=48000,aformat=channel_layouts=stereo,loudnorm=I=-38:TP=-9:LRA=7,aresample=48000[m]'
          ';[bl][m]amix=inputs=2:duration=first:normalize=0,alimiter=limit=0.8:level=disabled[a]')
    subprocess.check_call(['ffmpeg', '-y', '-loglevel', 'error', '-i', str(voz), '-stream_loop', '-1', '-i', str(mus), '-i', str(vid),
                           '-filter_complex', fc, '-map', '2:v', '-map', '[a]', '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k',
                           '-t', DUR, '-movflags', '+faststart', str(tmp)])
    got = lufs(['-i', str(tmp), '-vn', '-af', 'ebur128'])
    print(f'trim {trim:.1f} dB -> {got} LUFS')
    if abs(got - TARGET) <= 0.3: break
    trim += TARGET - got
os.replace(tmp, vid)
print('ok', vid.name, 'musica:', mus.name)
