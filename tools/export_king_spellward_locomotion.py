"""Encode and verify the actual Godot locomotion correction capture."""
import argparse
import json
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--ffmpeg', required=True)
args = parser.parse_args()
out = Path(__file__).resolve().parents[1] / 'art_source/review/characters/king/spellward_locomotion_2026_09_14'
source = out / 'capture_verified.avi'

def run(*params):
    subprocess.run([args.ffmpeg, '-y', '-v', 'error', *map(str, params)], check=True)

run('-i', source, '-vf', 'fps=30', '-c:v', 'libx264', '-crf', '19', '-pix_fmt', 'yuv420p',
    '-c:a', 'aac', '-b:a', '160k', '-movflags', '+faststart', out / 'king_c_locomotion.mp4')
segments = json.loads((out / 'segments.json').read_text(encoding='utf-8'))
for part in segments:
    filters = ('fps=30,crop=960:600:480:230,scale=768:480:flags=neighbor,split[a][b];'
               '[a]palettegen=max_colors=192:stats_mode=diff[p];[b][p]paletteuse=dither=none')
    run('-ss', part['start'], '-t', part['end']-part['start'], '-i', source,
        '-filter_complex', filters, '-loop', '0', out / (part['id'] + '.gif'))
    run('-i', out / (part['id'] + '.gif'), '-f', 'null', '-')
run('-i', out / 'king_c_locomotion.mp4', '-f', 'null', '-')
(out / 'index.html').write_text('''<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>King C locomotion correction</title>
<style>body{font:16px/1.5 system-ui;background:#101920;color:#e2e8ea;max-width:1100px;margin:24px auto;padding:0 20px}h1{font-size:24px}h2{font-size:18px}video,img{max-width:100%;display:block}a{color:#b6def1}</style>
<h1>King C — locomotion correction</h1><p>Actual Godot Lab recording. Open F7 → KING REVIEW in a fresh game session. Character size and movement speed retain their existing rules.</p>
<video controls src="king_c_locomotion.mp4" poster="playable_lab.png"></video>
<h2>Planted idle — four directions</h2><img src="idle.gif" alt="Four-direction idle">
<h2>Shoulder-carry walking — four directions</h2><img src="walk.gif" alt="Four-direction walking">
<h2>Preserved attacks with the same outline</h2><img src="combo.gif" alt="Approved three-cut attacks">
<p>The source blade sits below the rear hairline. A one-source-pixel charcoal outline applies consistently to every C body animation. Original comparison restores its previous material.</p>
<p><a href="README.md">Scope and validation</a> · <a href="prompts.txt">Built-in imagegen prompts</a></p></html>''', encoding='utf-8')
print('SPELLWARD_LOCOMOTION_EXPORTED: video and three GIFs decode cleanly')
