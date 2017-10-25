#!/usr/bin/python2 -utt
# -*- coding: utf-8 -*-
import sys
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import Variable
import torch.backends.cudnn as cudnn
import time
import os
import cv2
import math
import numpy as np

import os
import errno
import numpy as np
from PIL import Image

import sys
from copy import deepcopy
import argparse
import torch.utils.data as data
import torch
import torch.nn.init
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F

import torchvision.transforms as transforms
from torch.autograd import Variable
import torch.backends.cudnn as cudnn
from tqdm import tqdm
import random
import cv2
import copy
from Utils import L2Norm, cv2_scale, np_reshape
from pytorch_sift import SIFTNet

HARDCODED_SCALE_IDX = 15
HARDCODED_SCALE = 5 + 2*HARDCODED_SCALE_IDX;

rgb2gray = lambda x: x.float().mean(dim = 0, keepdim = True).byte()

def np2torch(npr):
    if len(npr.shape) == 4:
        return torch.from_numpy(np.rollaxis(npr, 3, 1))
    elif len(npr.shape) == 3:
        torch.from_numpy(np.rollaxis(npr, 2, 0))
    else:
        return torch.from_numpy(npr)
def read_patch_file(fname, patch_w = 64, patch_h = 64, start_patch_idx = 0):
    img = Image.open(fname).convert('RGB')
    width, height = img.size
    assert ((height % patch_h == 0) and (width % patch_w == 0))
    patch_idxs = []
    patches = []
    current_patch_idx = start_patch_idx
    for y in range(0, height, patch_h):
        patch_idxs.append([])
        for x in range(0, width, patch_w):
            patch = np.array(img.crop((x, y, x + patch_w, y + patch_h))).astype(np.uint8)
            patches.append(patch)
            patch_idxs[-1].append(current_patch_idx)
            current_patch_idx+=1
    return np2torch(np.array(patches)), patch_idxs, patch_idxs[-1][-1]

model = SIFTNet(patch_size = 41)
model.cuda()
model.eval()

try:
    input_img_fname = sys.argv[1]
    output_fname = sys.argv[2]
except:
    print "Wrong input format. Try ./rank_scale_patches.py imgs/ref.png out.txt"
    sys.exit(1)

patches, idxs, max_idx = read_patch_file(input_img_fname, patch_w = 73, patch_h = 41)
bw_patches = patches.float().mean(dim=1, keepdim = True);
print bw_patches.shape
n_patches = bw_patches.size(0)

bs = 128;
outs = []
n_batches = n_patches / bs + 1
t = time.time()

patches_saliency = np.zeros(n_patches)
num_scales = len(patches) / len(idxs)
num_patches = len(patches)  / num_scales;
indexes = np.zeros(num_patches);

for i in range(num_patches):
    indexes[i] = i*num_scales + HARDCODED_SCALE_IDX;


patches_for_desc = bw_patches[torch.from_numpy(indexes.astype(np.float32)).long(), :,:,:]
num_for_desc = len(patches_for_desc)
descriptors_for_net = np.zeros((num_for_desc,128))

n_batches = num_for_desc / bs + 1
t = time.time()

for batch_idx in range(n_batches):
    if batch_idx == n_batches - 1:
        if (batch_idx + 1) * bs > num_for_desc:
            end = num_for_desc
        else:
            end = (batch_idx + 1) * bs
    else:
        end = (batch_idx + 1) * bs
    if batch_idx * bs == end:
        break
    data_a = patches_for_desc[batch_idx * bs: end, :, :, :]
    #print data_a.shape
    data_a = data_a.unfold(3, 41, 7);
    #print data_a.shape
    data_a = data_a.cuda()
    data_a = Variable(data_a, volatile=True)
    for i in range(data_a.size(3)):
        if i == 0:
            current_descs = model(data_a[:,:,:,i,:])
        else:
            current_descs += model(data_a[:,:,:,i,:])
    current_descs = current_descs / float(data_a.size(3));
    descriptors_for_net[batch_idx * bs: end,:] = current_descs.data.cpu().numpy().reshape(-1, 128)
#np.savetxt(output_fname + '_scales', 5. + 2*am, delimiter=' ', fmt='%10.5f')    
np.savetxt(output_fname, descriptors_for_net, delimiter=' ', fmt='%10.5f')    