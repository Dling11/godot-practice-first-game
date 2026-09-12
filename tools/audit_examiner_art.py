"""Review every runtime body cell and export directional contact boards."""
from pathlib import Path
import json
import numpy as np
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'assets/characters/enemies/examiner'
OUT=ROOT/'art_source/review/characters/disciples/examiner/polish_2026_09_12'
report={}
files=sorted(BASE.glob('*_sheet_192x160.png'))
for path in files:
    image=Image.open(path).convert('RGBA')
    margins=[]
    for row in range(4):
        for col in range(image.width//192):
            cell=image.crop((col*192,row*160,(col+1)*192,(row+1)*160))
            box=cell.getbbox()
            assert box and min(box[0],box[1],192-box[2],160-box[3])>=1,(path,row,col,box)
            assert set(np.unique(np.array(cell)[:,:,3]))<={0,255}
            margins.append(min(box[0],box[1],192-box[2],160-box[3]))
    report[path.name]={'cells':len(margins),'minimum_padding':min(margins),'binary_alpha':True}
for page in range(2):
    selected=[p for p in files if 'walk_' not in p.name][page*5:(page+1)*5]
    board=Image.new('RGB',(4*192,5*180),(36,45,57))
    draw=ImageDraw.Draw(board)
    for row,path in enumerate(selected):
        image=Image.open(path).convert('RGBA')
        draw.text((5,row*180+3),path.stem.replace('examiner_',''),fill='white')
        for direction in range(4):
            pose=image.crop((3*192,direction*160,4*192,(direction+1)*160))
            board.paste(pose,(direction*192,row*180+20),pose)
    board.resize((1536,1800),Image.Resampling.NEAREST).save(OUT/f'attack_audit_{page+1}.png')
(OUT/'frame_audit.json').write_text(json.dumps(report,indent=2)+'\n')
print(sum(x['cells'] for x in report.values()),'body cells audited; transparent padding and binary alpha passed.')
