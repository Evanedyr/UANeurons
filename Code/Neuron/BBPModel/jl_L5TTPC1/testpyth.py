#!/usr/bin/env python

from neuron import h, gui
import numpy
from math import sin, cos, pi
import multiprocessing
import itertools as it
import time
import MCMClass_c as Mcm2

initValues = [-0.15, 1.05, 0.003]
mode = 1
nbins = 30
fRange = [0.001, 0.002, 0.003]
std = 1.
Mcm2.realmain(2, initValues, fRange, mode, std)
