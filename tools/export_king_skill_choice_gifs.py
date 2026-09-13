"""Export real-time GIF comparisons from the review-only Godot capture."""
import argparse
import html
import json
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--ffmpeg", required=True)
parser.add_argument("--body-only", action="store_true")
parser.add_argument("--gallery-only", action="store_true")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
out = root / "art_source/review/characters/king/skill_choices_2026_09_13"
segments = json.loads((out / ("body_segments.json" if args.body_only else "segments.json")).read_text(encoding="utf-8"))
cards = []
for segment in segments:
    target = out / (segment["id"] + ("_clean.gif" if segment["group"]=="Body reference" else ".gif"))
    duration = segment["end"] - segment["start"]
    filters = "fps=24,scale=640:360:flags=neighbor,split[a][b];[a]palettegen=max_colors=192:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=3"
    if not args.gallery_only:
        subprocess.run([args.ffmpeg, "-y", "-v", "error", "-ss", str(segment["start"]),
                        "-t", str(duration), "-i", str(out / ("body_capture.avi" if args.body_only else "capture.avi")),
                        "-filter_complex", filters, "-loop", "0", str(target)], check=True)
    subprocess.run([args.ffmpeg,"-v","error","-i",str(target),"-f","null","-"],check=True)
    name = html.escape(segment["name"])
    group = html.escape(segment["group"])
    tiers = '<option value="">Tier undecided</option>' + ''.join(f'<option>Tier {i}</option>' for i in range(1,11))
    cards.append(f'''<article data-name="{name}"><div class="heading"><h2>{name}</h2><span>{group}</span></div>
    <img src="{target.name}" alt="{name} current game animation" width="640" height="360">
    <div class="choices"><select class="verdict" aria-label="Decision for {name}"><option>Undecided</option><option>Keep as reference</option><option>Rework</option><option>Replace</option></select>
    <select class="tier" aria-label="Tier for {name}">{tiers}</select></div></article>''')
    print(f'{target.name}: {duration:.2f}s, {target.stat().st_size:,} bytes')
if args.body_only:
    print("Body-only GIFs updated; existing full gallery retained.")
    raise SystemExit(0)
page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>King — skill animation review</title><style>
*{box-sizing:border-box}body{margin:0;background:#0c121b;color:#e7edf4;font:16px system-ui,sans-serif}main{max-width:1340px;margin:auto;padding:28px 20px}h1{font-size:26px;margin:0 0 10px}p{line-height:1.5;color:#b6c4d3;max-width:880px}section{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px;margin-top:24px}article{border:1px solid #334251;background:#15212e;border-radius:8px;overflow:hidden}.heading{padding:12px 16px;display:flex;align-items:center;justify-content:space-between;gap:8px}h2{font-size:16px;margin:0}.heading span{font-size:12px;color:#aacbda}img{display:block;width:100%;height:auto;image-rendering:pixelated}.choices{display:flex;gap:12px;padding:12px 16px}select,button,textarea{font:inherit;color:#e7edf4;background:#0c1824;border:1px solid #476277;border-radius:5px;padding:9px}select{min-width:0;width:50%}button{cursor:pointer;margin-top:22px}textarea{display:block;width:100%;min-height:160px;margin:14px 0}small{color:#9cabb8}@media(max-width:720px){section{grid-template-columns:1fr}.heading{align-items:flex-start}}
</style><main><h1>King — compare the current animations</h1>
<p>Eight currently installed skills, followed by basic attacks and walking. Original and latest versions are shown separately so you can choose which ideas deserve a place in the tier progression. No final tier assignments are implied.</p>
<p>These are captures of the actual game at normal speed. Latest skills use their Mortal form. Targets are stationary for readability. Worldsplitter uses a wider camera to fit its full sword. GIFs are silent; Breakstep's loop shows movement, without triggering its conditional riposte.</p>
<section>''' + '\n'.join(cards) + '''</section>
<button id="summary">Build my review notes</button><textarea id="notes" aria-label="Your review notes" placeholder="Choose Keep / Rework / Replace and any tier above, then build your notes here."></textarea>
<small>Your choices stay on this page. Copy the notes into our conversation; this page does not modify the game.</small>
<script>document.querySelector('#summary').onclick=()=>{document.querySelector('#notes').value=[...document.querySelectorAll('article')].map(c=>`${c.dataset.name}: ${c.querySelector('.verdict').value}${c.querySelector('.tier').value?' — '+c.querySelector('.tier').value:''}`).join('\n');document.querySelector('#notes').focus();document.querySelector('#notes').select();};</script></main></html>'''
(out / "index.html").write_text(page,encoding="utf-8")
print("Review gallery exported; every GIF decoded successfully.")
