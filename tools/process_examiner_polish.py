"""Pack reviewed gait and effect art; keep full figures and stable origins."""
import json
from pathlib import Path
import numpy as np
from PIL import Image, ImageOps
from process_examiner_rework import clean_source, ROOT, CELL, BASELINE
from examiner_source_components import extract_cells

SOURCE = ROOT / 'art_source/generated/characters/disciples/examiner/polish_2026_09_12'
FX = ROOT / 'assets/vfx/divine_order/examiner'
REVIEW = ROOT / 'art_source/review/characters/disciples/examiner/polish_2026_09_12'


def grid(image, columns, rows):
    return [image.crop((round(c*image.width/columns), round(r*image.height/rows),
                        round((c+1)*image.width/columns), round((r+1)*image.height/rows)))
            for r in range(rows) for c in range(columns)]


def main():
    report = {'walk': {}, 'effects': {}}
    from process_examiner_identity import main as import_identity, SOURCE as identity_source
    import_identity()
    report['walk'] = json.loads((identity_source / 'import_report.json').read_text(encoding='utf-8'))
    for name,cell in [('energy',(256,128)),('sweep',(192,192)),('impact',(256,256))]:
        image=clean_source(SOURCE/(name+'.png'))
        poses=grid(image,4,2)
        atlas=Image.new('RGBA',(cell[0]*4,cell[1]*2))
        bounds=[]
        for i,pose in enumerate(poses):
            box=pose.getbbox()
            assert box and min(box[0],box[1],pose.width-box[2],pose.height-box[3])>1,(name,i,box)
            # Uniform grid resize retains chronological shape growth; no per-frame fit.
            pose=pose.resize(cell,Image.Resampling.NEAREST)
            if name == 'impact':
                # Reviewed contact cores from the source board, in 256px space.
                # Translation aligns eruption and settled crater; scale never changes.
                core=[(129,208),(133,211),(126,214),(117,204),(129,170),(129,171),(129,175),(117,179)][i]
                aligned=Image.new('RGBA',cell)
                aligned.paste(pose,(128-core[0],192-core[1]))
                assert (np.array(aligned)[:,:,3]>0).sum()==(np.array(pose)[:,:,3]>0).sum(), ('impact translation clipped',i)
                pose=aligned
            atlas.paste(pose,((i%4)*cell[0],(i//4)*cell[1]))
            bounds.append(pose.getbbox())
        atlas.save(FX/(name+'.png'))
        report['effects'][name]={'cell':cell,'frames':8,'bounds':bounds}
    beam_rows=extract_cells(clean_source(SOURCE/'axiom_beam.png'),2,4)
    beams=[pose for row in beam_rows for pose in row]
    beam_scale=min(232/max(p.width for p in beams),112/max(p.height for p in beams))
    beam_atlas=Image.new('RGBA',(1024,256))
    for i,pose in enumerate(beams):
        pose=pose.resize((round(pose.width*beam_scale),round(pose.height*beam_scale)),Image.Resampling.NEAREST)
        beam_atlas.paste(pose,((i%4)*256+(256-pose.width)//2,(i//4)*128+(128-pose.height)//2))
    beam_atlas.save(FX/'axiom_beam.png')
    report['effects']['axiom_beam']={'cell':[256,128],'frames':8,'scale':beam_scale,'source_grid':[2,4]}
    markers=grid(clean_source(SOURCE/'telegraphs.png'),2,1)
    for name,pose,size in zip(['danger_circle','danger_lane'],markers,[(256,256),(256,64)]):
        pose=pose.crop(pose.getbbox()).resize(size,Image.Resampling.NEAREST)
        # Decorative spikes must stay inside the same circular hazard footprint.
        if name=='danger_circle':
            a=np.array(pose);yy,xx=np.indices((256,256))
            a[(xx-127.5)**2+(yy-127.5)**2>128**2]=0
            pose=Image.fromarray(a)
        pose.save(FX/(name+'.png'))
    (SOURCE/'import_report.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Packed 16 alternating gait poses, 32 effect frames, and two bounded telegraphs.')


if __name__=='__main__': main()
