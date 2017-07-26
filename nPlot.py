#!/usr/bin/env python

import glob
import re
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import csv
from os.path import splitext

for path in glob.glob('*.txt'):
    with open(path, 'r') as infile, open(splitext(path)[0]+'.csv', 'w') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(['megabytes','real_sec','rate_Mbps','retrans','cwnd'])
        for line in infile:
            if 'nuttcp' not in line:
                pattern = re.compile('megabytes=\d+.\d+')
                megabytes = pattern.search(line)
                pattern = re.compile('real_sec=\d+.\d+')
                real_sec = pattern.search(line)
                pattern = re.compile('rate_Mbps=\d+.\d+')
                rate_Mbps = pattern.search(line)
                pattern = re.compile('retrans=\d+')
                retrans = pattern.search(line)
                pattern = re.compile('cwnd=\d+')
                cwnd = pattern.search(line)
                if megabytes and real_sec and rate_Mbps and retrans and cwnd:
                    megabytes = megabytes.group(0)
                    pattern = re.compile('megabytes=')
                    megabytes = pattern.sub('',megabytes)
                    real_sec = real_sec.group(0)
                    pattern = re.compile('real_sec=')
                    real_sec = pattern.sub('',real_sec)
                    rate_Mbps = rate_Mbps.group(0)
                    pattern = re.compile('rate_Mbps=')
                    rate_Mbps = pattern.sub('',rate_Mbps)
                    retrans = retrans.group(0)
                    pattern = re.compile('retrans=')
                    retrans = pattern.sub('',retrans)
                    cwnd = cwnd.group(0)
                    pattern = re.compile('cwnd=')
                    cwnd = pattern.sub('',cwnd)
                    writer.writerow([megabytes, real_sec, rate_Mbps, retrans, cwnd])

for path in glob.glob('*.csv'):
    df = pd.read_csv(path)
    fig, ax = plt.subplots()
    df['time'] = df.index / float(10)
    ax = df.plot(x='time', y='rate_Mbps')
    ax2 = df.plot(x='time', y='retrans', secondary_y=True, ax=ax)
    ax.set_xlabel('time (s)')
    ax.set_ylabel('throughput (Mbps)')
    ax2.set_ylabel('Retransmissions')
    ax.set_title('Achieved throughput')
    
    
    #ax.legend().set_visible(False)
    plt.tight_layout()
    plt.savefig(splitext(path)[0]+'.pdf',format='pdf')
    plt.close()
    
