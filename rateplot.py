#!/usr/bin/env python

import glob
import re
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import csv
from os.path import splitext

rates = {}
for path in glob.glob('*.txt'):
    with open(path, 'r') as infile:
        pattern = re.compile('T\d+')
        pacing = pattern.search(path)
        rate_Mbps = 0
        for line in infile:
            if 'nuttcp-r' in line:
                pattern = re.compile('rate_Mbps=\d+.\d+')
                rate_Mbps = pattern.search(line)
                if pacing and rate_Mbps:
                    pacing = int(pacing.group(0)[1:])
                    rate_Mbps = float(rate_Mbps.group(0)[10:])
                    print pacing, rate_Mbps
                    if rates.get(pacing) is not None:
                        rates[pacing] += rate_Mbps
                    else:
                        rates[pacing] = rate_Mbps

print rates
lists = sorted(rates.items()) # sorted by key, return a list of tuples

x, y = zip(*lists) # unpack a list of pairs into two tuples

plt.plot(x, y)
plt.show()
