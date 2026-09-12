"""Prepare generated 16-frame energy loop, retaining common scale and full tips."""
from pathlib import Path
import hashlib,json
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'art_source/generated/characters/disciples/examiner/firmament_2026_09_12'
OUT=ROOT/'assets/vfx/divine_order/examiner/sun_loop.png'

def main():
    image=Image.open(SOURCE/'sun_loop_source.png').convert('RGBA')
    a=np.array(image);rgb=a[:,:,:3].astype(int)
    if a[:,:,3].min()==255:
        matte=(rgb.max(2)-rgb.min(2)<20)&(rgb.min(2)>85)&(rgb.max(2)<225)
        a[matte]=0
    a[:,:,3]=np.where(a[:,:,3]>=210,255,0);a[a[:,:,3]==0]=0
    image=Image.fromarray(a);atlas=Image.new('RGBA',(768,768));bounds=[];hashes=[]
    for i in range(16):
        x,y=i%4,i//4
        cell=image.crop((round(x*image.width/4),round(y*image.height/4),round((x+1)*image.width/4),round((y+1)*image.height/4)))
        cell=cell.resize((176,176),Image.Resampling.NEAREST)
        packed=Image.new('RGBA',(192,192));packed.paste(cell,(8,8))
        box=packed.getbbox();assert box and min(box[0],box[1],192-box[2],192-box[3])>=8,(i,box)
        bounds.append(box);hashes.append(hashlib.sha256(packed.tobytes()).hexdigest())
        atlas.paste(packed,(x*192,y*192))
    assert len(set(hashes))==16
    atlas.save(OUT)
    body={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT/'assets/characters/enemies/examiner').glob('*.png')}
    (SOURCE/'import_report.json').write_text(json.dumps({'frames':16,'cell':[192,192],'bounds':bounds,'distinct_frames':len(set(hashes)),'body_hashes':body},indent=2)+'\n',encoding='utf-8')
    print('16 distinct padded energy frames packed; approved body hashes recorded.')

if __name__=='__main__': main()
