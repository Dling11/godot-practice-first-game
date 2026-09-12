"""Prepare identity-referenced gait art; no pose synthesis or per-frame fitting."""
import json
import numpy as np
from PIL import Image, ImageOps, ImageDraw
from process_examiner_rework import ROOT, CELL, BASELINE, clean_source

SOURCE = ROOT / 'art_source/generated/characters/disciples/examiner/identity_2026_09_12'
REVIEW = ROOT / 'art_source/review/characters/disciples/examiner/identity_2026_09_12'
ASSETS = ROOT / 'assets/characters/enemies/examiner'
# Reviewed helmet-to-ground measurements exclude the weapon. One scale per
# direction matches the accepted idle body, irrespective of raised blade length.
STUDIES = {
    'down': (64 / 533, [(304,696),(242,694),(300,697),(236,687)]),
    'right': (65 / 486, [(300,596),(300,600),(303,598),(305,606)]),
    'up': (69 / 523, [(297,651),(244,649),(297,652),(244,649)]),
}


def main():
    REVIEW.mkdir(parents=True, exist_ok=True)
    rows = []
    report = {}
    for direction, (scale, anchors) in STUDIES.items():
        path = SOURCE / f'walk_{direction}.png'
        if direction == 'down':
            source = clean_source(path)
        else:
            a = np.array(Image.open(path).convert('RGBA'))
            rgb = a[:,:,:3].astype(int)
            matte = (rgb[:,:,0] > rgb[:,:,1] + 60) & (rgb[:,:,2] > rgb[:,:,1] + 60)
            a[matte] = 0
            a[:,:,3] = np.where(a[:,:,3] >= 210,255,0)
            source = Image.fromarray(a)
        poses=[]
        for i, (x,y) in enumerate(anchors):
            c,r = i%2,i//2
            pose = source.crop((round(c*source.width/2),round(r*source.height/2),
                                round((c+1)*source.width/2),round((r+1)*source.height/2)))
            bbox=pose.getbbox()
            assert bbox and min(bbox[0],bbox[1],pose.width-bbox[2],pose.height-bbox[3])>1, (direction,i,bbox)
            pose=pose.resize((round(pose.width*scale),round(pose.height*scale)),Image.Resampling.NEAREST)
            target=Image.new('RGBA',CELL)
            target.paste(pose,(round(96-x*scale),round(BASELINE-y*scale)))
            assert np.count_nonzero(np.array(target)[:,:,3]) == np.count_nonzero(np.array(pose)[:,:,3]), (direction,i,'clipped')
            poses.append(target)
        rows.append(poses)
        report[direction]={'scale':scale,'anchors':anchors,'source':path.name,'bounds':[p.getbbox() for p in poses]}
    rows=[rows[0],rows[1],[ImageOps.mirror(p) for p in rows[1]],rows[2]]
    walk=Image.new('RGBA',(CELL[0]*4,CELL[1]*4))
    for r,row in enumerate(rows):
        for c,pose in enumerate(row): walk.paste(pose,(c*CELL[0],r*CELL[1]))
    walk.save(ASSETS/'examiner_walk_sheet_192x160.png')
    comparison=Image.new('RGBA',(192*6,160*4),(28,35,45,255))
    idle=Image.open(ASSETS/'examiner_locomotion_sheet_192x160.png').convert('RGBA')
    attack=Image.open(ASSETS/'examiner_thrust_sheet_192x160.png').convert('RGBA')
    draw=ImageDraw.Draw(comparison)
    for r,direction in enumerate(['down','right','left','up']):
        poses=[idle.crop((0,r*160,192,(r+1)*160))]+rows[r]+[attack.crop((0,r*160,192,(r+1)*160))]
        for c,pose in enumerate(poses):
            comparison.alpha_composite(pose,(c*192,r*160))
            draw.text((c*192+12,r*160+10),f'{direction} / '+(['idle','step 1','pass 1','step 2','pass 2','wind-up'][c]),fill='white')
    comparison.convert('RGB').save(REVIEW/'identity_comparison.png')
    (SOURCE/'import_report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('Packed 16 identity-referenced gait frames, stable body scale and foot anchors.')


if __name__ == '__main__': main()
