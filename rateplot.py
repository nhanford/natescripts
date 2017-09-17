#!/usr/bin/env python

import glob
import re
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import csv
from os.path import splitext

rates = {}
retrans = {}
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
                    if rates.get(pacing) is not None:
                        rates[pacing] += rate_Mbps
                    else:
                        rates[pacing] = rate_Mbps
            elif 'nuttcp-t' in line:
                pattern = re.compile('retrans=\d+')
                retransmits = pattern.search(line)
                if pacing and retransmits:
                    retransmits = int(retransmits.group(0)[8:])
                    if retrans.get(pacing) is not None:
                        retrans[pacing] += retransmits
                    else:
                        retrans[pacing] = retransmits

lists = sorted(rates.items())
pacing, throughput = zip(*lists)
lists = sorted(retrans.items())
pacing, retrans = zip(*lists)
fig, ax = plt.subplots()
ax = plt.plot(pacing, throughput, color='b')
ax = plt.gca()
ax.set_title('Throughput and retransmissions vs pacing rate')
ax.set_xlabel('pacing rate (Mbps)')
ax.set_ylabel('throughput (Mbps)', color='b')
ax2 = ax.twinx()
ax2 = plt.plot(pacing, retrans, color='g')
ax2 = plt.gca()
ax2.set_ylabel('retransmissions', color='g')
plt.tight_layout()
plt.savefig('rates.pdf', format='pdf')

variances = {'rate': [], 'variance': []}
for path in glob.glob('*.csv'):
    df = pd.read_csv(path)
    var = df.var()['rate_Mbps']
    pattern = re.compile('T\d+')
    pacing = pattern.search(path)
    if pacing and var:
        pacing = int(pacing.group(0)[1:])
        if pacing in variances['rate']:
            variances['variance'][variances['rate'].index(pacing)] += (var/3000)
        else:
            variances['rate'].append(pacing)
            variances['variance'].append(var)

df = pd.DataFrame(data=variances).sort_values('rate')
fig, ax = plt.subplots()
ax = df.plot(x='rate', y='variance')
ax.set_title('Variance of throughput vs. pacing rate')
ax.set_xlabel('Pacing rate (Mbps)')
ax.set_ylabel('Throughput variance (Mbps)')
plt.tight_layout()
plt.savefig('variances.pdf', format='pdf')

