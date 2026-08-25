import math
import random
import struct
import wave
import os

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sounds')
os.makedirs(OUT, exist_ok=True)
SR = 44100


def envelope(i, n, attack=0.02, release=0.4):
    t = i / n
    a = min(1.0, t / max(attack, 1e-6))
    r = min(1.0, (1.0 - t) / max(release, 1e-6))
    return min(a, r)


def save(name, samples):
    path = os.path.join(OUT, name)
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = b''.join(struct.pack('<h', int(max(-1, min(1, s)) * 32767)) for s in samples)
        w.writeframes(frames)
    print(name, len(samples) / SR, 'sec')


def tone(freq, dur, vol=0.5, attack=0.01, release=0.5, shape='sine', sweep=None):
    n = int(SR * dur)
    out = []
    phase = 0.0
    for i in range(n):
        f = freq if sweep is None else freq + (sweep - freq) * (i / n)
        phase += 2 * math.pi * f / SR
        if shape == 'sine':
            v = math.sin(phase)
        elif shape == 'tri':
            v = 2 / math.pi * math.asin(math.sin(phase))
        else:
            v = math.copysign(1.0, math.sin(phase))
        out.append(v * vol * envelope(i, n, attack, release))
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    out = [0.0] * n
    for t in tracks:
        for i, v in enumerate(t):
            out[i] += v
    peak = max(abs(v) for v in out) or 1.0
    if peak > 0.95:
        k = 0.95 / peak
        out = [v * k for v in out]
    return out


def delay(track, sec):
    return [0.0] * int(SR * sec) + track


rng = random.Random(7)

save('tap.wav', mix(tone(1900, 0.05, 0.35, 0.005, 0.6), tone(950, 0.04, 0.18, 0.005, 0.7)))

whoosh_n = int(SR * 0.22)
whoosh = []
lp = 0.0
for i in range(whoosh_n):
    t = i / whoosh_n
    raw = rng.uniform(-1, 1)
    lp = lp * 0.86 + raw * 0.14
    body = lp * (math.sin(math.pi * t) ** 1.5)
    airy = raw * 0.08 * (1 - t)
    whoosh.append((body * 1.6 + airy) * envelope(i, whoosh_n, 0.15, 0.45) * 0.8)
save('move.wav', whoosh)

save('exit.wav', mix(
    tone(660, 0.10, 0.30, 0.005, 0.6),
    delay(tone(990, 0.12, 0.28, 0.005, 0.7), 0.06),
))

save('blocked.wav', mix(
    tone(150, 0.16, 0.55, 0.004, 0.5, shape='tri'),
    tone(96, 0.18, 0.35, 0.004, 0.6),
))

save('button.wav', mix(tone(1300, 0.03, 0.28, 0.002, 0.7)))

save('hint.wav', mix(
    tone(880, 0.22, 0.22, 0.01, 0.7),
    delay(tone(1318, 0.26, 0.20, 0.01, 0.8), 0.10),
))

save('level_complete.wav', mix(
    tone(523, 0.16, 0.26, 0.01, 0.7),
    delay(tone(659, 0.16, 0.26, 0.01, 0.7), 0.11),
    delay(tone(784, 0.16, 0.26, 0.01, 0.7), 0.22),
    delay(tone(1046, 0.34, 0.30, 0.01, 0.85), 0.33),
))

save('restart.wav', mix(
    tone(900, 0.09, 0.24, 0.004, 0.6, sweep=500),
    delay(tone(700, 0.10, 0.22, 0.004, 0.7, sweep=420), 0.07),
))
