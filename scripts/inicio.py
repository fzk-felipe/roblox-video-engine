# Acha o começo do filme na gravação: o player pisca a tela de branco (claquete) logo antes do primeiro quadro.
# Uso: python inicio.py "gravacao.mp4" [segundos_a_olhar=90]  -> imprime o tempo, em segundos, do primeiro quadro do filme.
import re, subprocess, sys


def inicio(rec, olhar=90):
    r = subprocess.run(['ffmpeg', '-hide_banner', '-nostats', '-t', str(olhar), '-i', rec, '-vf',
                        'crop=iw/2:ih/2,scale=160:90,signalstats,metadata=print:key=lavfi.signalstats.YAVG:file=-', '-an', '-f', 'null', '-'],
                       capture_output=True, text=True)
    t, runs, cur = None, [], None
    for ln in r.stdout.splitlines():
        m = re.search(r'pts_time:([\d.]+)', ln)
        if m:
            t = float(m.group(1))
            continue
        m = re.search(r'YAVG=([\d.]+)', ln)
        if not m or t is None:
            continue
        if float(m.group(1)) > 225:  # tela inteira branca
            cur = [t, t] if cur is None else [cur[0], t]
        elif cur is not None:
            runs.append((cur[0], cur[1], t))
            cur = None
    runs = [x for x in runs if 0.05 <= x[1] - x[0] <= 1.0]  # a claquete dura ~0,2 s; tela de carregamento branca dura mais
    if not runs:
        raise SystemExit('claquete branca não encontrada: confira se o player novo está no place ou passe o início à mão')
    return runs[-1][2]  # primeiro quadro depois do último piscar


if __name__ == '__main__':
    print(f"{inicio(sys.argv[1], float(sys.argv[2]) if len(sys.argv) > 2 else 90):.3f}")
