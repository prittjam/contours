#!/usr/bin/python2 -utt
# -*- coding: utf-8 -*-
import sys
import os

import subprocess

SCRIPT_NAME = 'extract_sifts_with_fixed_scale.py'
try:
    patches_dir = sys.argv[1]
    out_dir = sys.argv[2]
except:
    print "Wrong input format. Try ./extract_descriptors_from_hpathes_cont.py /home/old-ufo/datasets/HP_p /home/old-ufo/datasets/HP_c_p_sifts_scale35"
    sys.exit(1)
    
for root, dirs,files in os.walk(patches_dir, topdown=True):
    for name in files:
        if '_to_' in name:
            continue
        out_dir_cur = root.replace(patches_dir, out_dir);
        if not os.path.isdir(out_dir_cur):
            os.makedirs(out_dir_cur)
        out_fname = os.path.join(out_dir_cur, name.replace('.png', '.txt'))
        img_fname = os.path.join(root, name)
        cmd = 'python ' + SCRIPT_NAME + ' ' + img_fname + ' ' + out_fname
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
        out, err = p.communicate() 
        print (out_fname)
