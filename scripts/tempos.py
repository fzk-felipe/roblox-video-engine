# Depois do mixar.py: imprime as tabelas END e BOOM em Luau, prontas para colar no módulo do filme.
# Uso: python tempos.py [emily_roteiro.json]   (padrão: o roteiro da pasta atual)
import json, sys
sys.stdout.reconfigure(encoding='utf-8')
shots = json.load(open(sys.argv[1] if len(sys.argv) > 1 else 'emily_roteiro.json', encoding='utf-8'))
assert all('end' in s for s in shots), 'rode audio/mixar.py antes: o roteiro ainda não tem os tempos'
assert [s['n'] for s in shots] == list(range(1, len(shots) + 1)), 'falas fora de ordem ou com número pulado'
durs = [round(s['end'] - s['start'], 2) for s in shots]
print('local END = {' + ', '.join(f"{s['end']:g}" for s in shots) + '}')
print('local BOOM = {' + ', '.join(f"[{s['n']}] = {s['sfx_t']:g}" for s in shots if s.get('sfx') == 'boom') + '}')
long = [(s['n'], d) for s, d in zip(shots, durs) if d > 2.6 and s['line']]
print(f"-- {len(shots)} falas, {shots[-1]['end']:g} s, média {sum(durs) / len(durs):.2f} s por fala")
if long: print('-- falas com mais de 2,6 s (dividir em 2-3 planos com f = {0, 0.5}):', long)
