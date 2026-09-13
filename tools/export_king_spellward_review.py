"""Package the actual Godot capture, keeping the full video at native 1080p."""
import argparse
import json
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--ffmpeg', required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
out = root / 'art_source/review/characters/king/spellward_lab_2026_09_14'
source = out / 'capture.avi'

def run(*params):
    subprocess.run([args.ffmpeg, '-y', '-v', 'error', *map(str, params)], check=True)

run('-i', source, '-vf', 'fps=30', '-c:v', 'libx264', '-crf', '19', '-pix_fmt', 'yuv420p',
    '-c:a', 'aac', '-b:a', '160k', '-movflags', '+faststart', out / 'king_c_lab_review.mp4')
segments = json.loads((out / 'segments.json').read_text(encoding='utf-8'))
for part in segments:
    if part['id'] == 'playable_lab':
        continue
    filters = ('fps=30,crop=1120:660:400:230,scale=784:462:flags=neighbor,split[a][b];'
               '[a]palettegen=max_colors=192:stats_mode=diff[p];[b][p]paletteuse=dither=none')
    run('-ss', part['start'], '-t', part['end']-part['start'], '-i', source,
        '-filter_complex', filters, '-loop', '0', out / (part['id'] + '.gif'))
    run('-i', out / (part['id'] + '.gif'), '-f', 'null', '-')
run('-i', out / 'king_c_lab_review.mp4', '-f', 'null', '-')
combo = next(p for p in segments if p['id']=='combo')
run('-ss', combo['start']+.25, '-i', source, '-frames:v', '1', out / 'contact_check.png')
page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>King C — playable Lab review</title>
<style>body{font:16px/1.5 system-ui;background:#101920;color:#e2e8ea;margin:0}main{max-width:1120px;margin:auto;padding:24px}h1{font-size:25px}h2{font-size:19px}p{color:#b9c9cf}video,img{max-width:100%;height:auto;display:block;margin:16px 0}a{color:#b6def1}section{margin:30px 0}code{color:#dbe7c4}</style><main>
<h1>King C — actual Godot Combat Lab review</h1><p>Open the game, press <b>F7</b>, then <b>KING REVIEW</b>. LOOK switches C / original. SPEED cycles real gear, base, and equipment caps. VIEW toggles close-up; HIT / STUN use actual damage and control signals with health restored. REACH displays the real basic contact shape.</p>
<video controls preload="metadata" src="king_c_lab_review.mp4" poster="playable_lab.png"></video>
<p>Video preserves the native 1920×1080 render and game audio. The GIFs below are cropped close-ups of the same capture, not a different animation simulation. AI is paused and King is invincible in the opening contact comparison. Later sections isolate his movement and actions.</p>
'''
for key,title in [('locomotion','Idle and four-direction walk'),('combo','Three physical cuts and white trails'),('reactions','Hit reaction, stun and dash'),('speed_caps','Equipment speed caps'),('defeat','Defeat')]:
    page += f'<section><h2>{title}</h2><img src="{key}.gif" alt="Actual Godot capture: {title}" loading="lazy"></section>'
page += '<p>Skills keep their current rules and effects with temporary C body-pose mappings. This preview does not finalize the skill redesign or replace King throughout the campaign.</p><p><a href="README.md">Scope, limitations and validation</a> · <a href="prompts.txt">Image generation prompts</a></p></main></html>'
(out / 'index.html').write_text(page, encoding='utf-8')
print('SPELLWARD_REVIEW_EXPORTED: native video and five GIFs decoded successfully')
