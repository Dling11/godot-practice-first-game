"""Recover whole connected actors before any cell crop can sever a weapon."""
import numpy as np
from PIL import Image


def extract_cells(image, columns=8, rows=4):
    rgba = np.array(image)
    occupied = rgba[:, :, 3] > 0
    h, w = occupied.shape
    labels = np.zeros((h, w), dtype=np.int32)
    components = []
    for sy, sx in zip(*np.where(occupied)):
        if labels[sy, sx]:
            continue
        label = len(components) + 1
        todo = [(int(sx), int(sy))]
        labels[sy, sx] = label
        xx, yy = [], []
        while todo:
            x, y = todo.pop()
            xx.append(x); yy.append(y)
            for nx, ny in ((x-1,y),(x+1,y),(x,y-1),(x,y+1),(x-1,y-1),(x+1,y+1),(x-1,y+1),(x+1,y-1)):
                if 0 <= nx < w and 0 <= ny < h and occupied[ny,nx] and labels[ny,nx] == 0:
                    labels[ny,nx] = label
                    todo.append((nx,ny))
        components.append((min(xx), min(yy), max(xx)+1, max(yy)+1, len(xx)))
    result = []
    used = set()
    for row in range(rows):
        out = []
        for col in range(columns):
            region = labels[round(row*h/rows):round((row+1)*h/rows), round(col*w/columns):round((col+1)*w/columns)]
            counts = np.bincount(region.ravel(), minlength=len(components)+1)
            counts[0] = 0
            chosen = int(counts.argmax())
            if chosen == 0 or chosen in used:
                raise ValueError(f"Missing or merged actor at {row}/{col}")
            used.add(chosen)
            x0,y0,x1,y1,count = components[chosen-1]
            if x0 == 0 or y0 == 0 or x1 == w or y1 == h:
                raise ValueError(f"Source itself clips actor at {row}/{col}: {(x0,y0,x1,y1)}")
            crop = rgba[y0:y1,x0:x1].copy()
            crop[labels[y0:y1,x0:x1] != chosen] = 0
            assert int((crop[:,:,3]>0).sum()) == count
            # Margin is added AFTER complete extraction, never a search limit.
            pose = Image.new('RGBA',(x1-x0+8,y1-y0+8))
            pose.paste(Image.fromarray(crop),(4,4))
            out.append(pose)
        result.append(out)
    return result
