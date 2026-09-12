"""Pack the generated VFX only; never alter the approved Examiner body art."""
from pathlib import Path
import hashlib
import json
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'art_source/generated/characters/disciples/examiner/ascendant_2026_09_12'
OUT = ROOT / 'assets/vfx/divine_order/examiner/sun.png'


def main():
    image = Image.open(SOURCE / 'sun_source.png').convert('RGBA')
    a = np.array(image)
    rgb = a[:, :, :3].astype(int)
    # This VFX board has a baked neutral checker matte, including inside arcs.
    # Remove neutral grey only; preserve ivory highlights and navy smoke.
    matte = (rgb.max(2)-rgb.min(2) < 20) & (rgb.min(2) > 85) & (rgb.max(2) < 225)
    a[matte] = 0
    a[:, :, 3] = np.where(a[:, :, 3] >= 210, 255, 0)
    a[a[:, :, 3] == 0] = 0
    image = Image.fromarray(a)
    atlas = Image.new('RGBA', (768,384))
    bounds = []
    for i in range(8):
        x,y=i%4,i//4
        pose=image.crop((round(x*image.width/4),round(y*image.height/2),round((x+1)*image.width/4),round((y+1)*image.height/2)))
        # One fixed grid scale, no per-frame fitting or growth normalization.
        pose=pose.resize((160,160),Image.Resampling.NEAREST)
        cell=Image.new('RGBA',(192,192))
        # Source cores lie at 59% down in row 1 and 52% down in row 2.
        cell.paste(pose,(16,2 if y==0 else 13))
        assert np.count_nonzero(np.array(cell)[:,:,3])==np.count_nonzero(np.array(pose)[:,:,3]), ('clipped',i)
        box=cell.getbbox()
        assert box and min(box[0],box[1],192-box[2],192-box[3])>=3,(i,box)
        atlas.paste(cell,(x*192,y*192))
        bounds.append(box)
    atlas.save(OUT)
    body={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT/'assets/characters/enemies/examiner').glob('*.png')}
    (SOURCE/'import_report.json').write_text(json.dumps({'frames':8,'cell':[192,192],'bounds':bounds,'body_hashes':body},indent=2)+'\n',encoding='utf-8')
    print('Packed eight Sun VFX frames; all padding and clipping checks passed.')


if __name__=='__main__': main()
