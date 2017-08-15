#!/usr/bin/env python

import glob
import re
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import csv
from os.path import splitext

variances = {'rate': [], 'variance': []}
for path in glob.glob('*.csv'):
    df = pd.read_csv(path)
    var = df.var()['rate_Mbps']
    pattern = re.compile('T\d+')
    pacing = pattern.search(path)
    if pacing and var:
        pacing = int(pacing.group(0)[1:])
        if pacing in variances['rate']:
            variances['variance'][variances['rate'].index(pacing)] += var
        else:
            variances['rate'].append(pacing)
            variances['variance'].append(var)

df = pd.DataFrame(data=variances).sort_values('rate')
fig, ax = plt.subplots()
ax = df.plot(x='rate', y='variance')
plt.savefig('variances.pdf', format='pdf')
