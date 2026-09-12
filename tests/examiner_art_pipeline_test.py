"""Regression: complete weapon silhouettes must survive source-cell extraction."""
import sys
import unittest
from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from examiner_source_components import extract_cells


class CompleteWeaponTest(unittest.TestCase):
    def test_weapon_crossing_gutter_keeps_every_pixel(self):
        image = Image.new('RGBA',(600,200))
        draw = ImageDraw.Draw(image)
        draw.rectangle((90,70,145,180),fill='white')
        # Tip extends far beyond the former 46px search margin, above neighbor.
        draw.rectangle((140,70,405,74),fill='gold')
        draw.rectangle((430,90,490,180),fill='white')
        expected = int((np.array(image)[:,:,3]>0).sum())
        cells = extract_cells(image,2,1)[0]
        actual = sum(int((np.array(cell)[:,:,3]>0).sum()) for cell in cells)
        self.assertEqual(expected,actual)
        self.assertGreater(cells[0].width,300)

    def test_source_edge_is_rejected_before_padding(self):
        image=Image.new('RGBA',(200,200))
        ImageDraw.Draw(image).rectangle((70,0,120,180),fill='white')
        with self.assertRaisesRegex(ValueError,'Source itself clips'):
            extract_cells(image,1,1)


if __name__=='__main__': unittest.main()
