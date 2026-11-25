# Revisão densa do vídeo pronto: folhas com 2 quadros por segundo do filme INTEIRO (com o tempo escrito) e contagem de
# quadros pretos e congelados. Ver TODAS as folhas, não uma amostra. Pasta nova a cada rodada (nunca reaproveitar folha velha).
# Uso: python revisar.py emily_final.mp4 [pasta_de_saida]
import pathlib, re, subprocess, sys, time
sys.stdout.reconfigure(encoding='utf-8')
vid = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else vid.parent / '_rev' / time.strftime('%m%d-%H%M%S')
out.mkdir(parents=True, exist_ok=False)
dur = float(subprocess.check_output(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', str(vid)]).decode())
vf = r"fps=2,scale=216:-1,drawtext=fontfile='C\:/Windows/Fonts/arial.ttf':text='%{pts\:flt}':x=4:y=h-22:fontsize=18:fontcolor=yellow:box=1:boxcolor=black,tile=10x3"
subprocess.check_call(['ffmpeg', '-v', 'error', '-y', '-i', vid.as_posix(), '-vf', vf, (out / 'v%02d.jpg').as_posix()])
r = subprocess.run(['ffmpeg', '-hide_banner', '-nostats', '-i', str(vid), '-vf', 'blackdetect=d=0.05:pix_th=0.08,freezedetect=n=0.001:d=0.75',
                    '-an', '-f', 'null', '-'], capture_output=True, text=True).stderr
black = re.findall(r'black_start:([\d.]+) black_end:([\d.]+)', r)
frozen = re.findall(r'freeze_start: ([\d.]+)', r)
sheets = sorted(out.glob('v*.jpg'))
print(f'{vid.name}: {dur:.1f} s, {len(sheets)} folhas em {out}')
print('quadros pretos:', black or 'nenhum')
print('congelado por 0,75 s ou mais (inícios):', frozen or 'nenhum')
for s in sheets:
    print(s)
