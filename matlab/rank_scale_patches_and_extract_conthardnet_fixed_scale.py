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
from Utils import str2bool

try:
    input_img_fname = sys.argv[1]
    output_fname = sys.argv[2]
except:
    print "Wrong input format. Try ./rank_scale_patches.py imgs/ref.png out.txt"
    sys.exit(1)
if os.path.isfile(output_fname):
    sys.exit(0)

rgb2gray = lambda x: x.float().mean(dim = 0, keepdim = True).byte()
HARDCODED_SCALE_IDX = 15
HARDCODED_SCALE = 5 + 2*HARDCODED_SCALE_IDX;

class NMS1d(nn.Module):
    def __init__(self, kernel_size = 3, threshold = 0):
        super(NMS1d, self).__init__()
        self.MP = nn.MaxPool1d(kernel_size, stride=1, return_indices=False, padding = kernel_size/2)
        self.eps = 1e-5
        self.th = threshold
        return
    def forward(self, x):
        #local_maxima = self.MP(x)
        if self.th > self.eps:
            return  x * (x > self.th).float() * ((x + self.eps - self.MP(x)) > 0).float()
        else:
            return ((torch.abs(x) - self.MP(torch.abs(x)) + self.eps) > 0).float() * x
nms = NMS1d()

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
    #print (img.size, patch_w, patch_h)
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

class ScaleNet(nn.Module):
    """ScaleNet model definition
    """
    def __init__(self):
        super(ScaleNet, self).__init__()
        self.column = nn.Sequential(
            nn.Conv2d(1, 32, kernel_size=(3,1), padding=(1,0), bias = False),
            nn.BatchNorm2d(32, affine=False),
            nn.ReLU(),
            nn.Conv2d(32, 32, kernel_size=(3,1), padding=(1,0), bias = False),
            nn.BatchNorm2d(32, affine=False),
            nn.ReLU(),
            nn.Conv2d(32, 64, kernel_size=(3,1), padding=(1,0), stride = (2,1), bias = False),
            nn.BatchNorm2d(64, affine=False),
            nn.ReLU(),
            nn.Conv2d(64, 64, kernel_size=(3,1), padding=(1,0), stride = (1,1), bias = False),
            nn.BatchNorm2d(64, affine=False),
            nn.ReLU(),
            nn.Conv2d(64, 64, kernel_size=(3,1), padding=(1,0), stride = (1,1), bias = False),
            nn.BatchNorm2d(64, affine=False),
            nn.ReLU(),
        )
        self.horizontal_merge = nn.Sequential(
            nn.Conv2d(64, 64, kernel_size=(1,3), padding=(0,1), stride = (1,2), bias = False),
            nn.BatchNorm2d(64, affine=False),
            nn.ReLU(),
            nn.Conv2d(64, 128, kernel_size=(1,3), padding=(0,1), stride = (1,2), bias = False),
            nn.BatchNorm2d(128, affine=False),
            nn.ReLU(),
        )
        self.features = nn.Sequential(
            self.column,
            self.horizontal_merge,
            nn.Conv2d(128, 128, kernel_size=(3,1), padding=(1,0), stride = (2,1), bias = False),
            nn.BatchNorm2d(128, affine=False),
            nn.ReLU(),
            nn.Conv2d(128, 128, kernel_size=(3,1), padding=(1,0), stride = (2,1), bias = False),
            nn.BatchNorm2d(128, affine=False),
            nn.ReLU(),
            nn.Dropout(0.25))
        self.descriptor = nn.Sequential(
            nn.Conv2d(128, 128, kernel_size=(5,5), bias = True),
            nn.BatchNorm2d(128, affine=False),
            nn.AdaptiveAvgPool2d(1))
        self.scale = nn.Sequential(
            nn.Conv2d(128, 1, kernel_size=(5,1), bias = True),
            nn.Dropout(0.1),
            nn.Tanh(),
            nn.Conv2d(1, 1, kernel_size=(1,5), bias = True),
            nn.Sigmoid(),
            nn.AdaptiveAvgPool2d(1))
        return
    def input_norm(self,x):
        flat = x.view(x.size(0), -1)
        mp = torch.mean(flat, dim=1)
        sp = torch.std(flat, dim=1) + 1e-7
        return (x - mp.unsqueeze(-1).unsqueeze(-1).unsqueeze(-1).expand_as(x)) / sp.unsqueeze(-1).unsqueeze(-1).unsqueeze(1).expand_as(x)

    def forward(self, input):
        x_features = self.features(self.input_norm(input))
        scale = self.scale(x_features).view(x_features.size(0), -1)
        desc = L2Norm()(self.descriptor(x_features).view(x_features.size(0), -1))
        #print( x_features.shape)
        #sys.exit(0)
        return scale,desc




model_weights = 'discriminative_scale_desc_crafted_checkpoint_5_14.pth'

model = ScaleNet()
model.cuda()

checkpoint = torch.load(model_weights)
model.load_state_dict(checkpoint['state_dict'])
model.eval()

patches, idxs,max_idx = read_patch_file(input_img_fname, patch_w = 73, patch_h = 41)
bw_patches = patches.float().mean(dim=1, keepdim = True);
print bw_patches.shape
n_patches = bw_patches.size(0)

bs = 128;
outs = []
n_batches = n_patches / bs + 1
t = time.time()

patches_saliency = np.zeros(n_patches)
num_scales = len(patches) / len(idxs)
num_patches = len(patches) / num_scales
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
    data_a = data_a.cuda()
    data_a = Variable(data_a, volatile=True)
    scale_a, current_descs = model(data_a)
    descriptors_for_net[batch_idx * bs: end,:] = current_descs.data.cpu().numpy().reshape(-1, 128)

np.savetxt(output_fname, descriptors_for_net, delimiter=' ', fmt='%10.5f')    