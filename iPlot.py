#!/usr/bin/env python

import glob
import json
import pandas as pd
import matplotlib.pyplot as plt
from os.path import splitext

for path in glob.glob('*.json'):
    with open(path,'r') as fp:
        data = json.load(fp)
        myDict = {}
        for i in range(len(data['intervals'])):
            myDict[i]=data['intervals'][i]['streams'][0]
        df = pd.DataFrame.from_dict(myDict, orient='index')
        df['gigs'] = df['bits_per_second']/float(1000000000)
        fig, ax = plt.subplots()
        ax = df.plot(x='end', y='gigs', color='k')
        ax.set_ylim(ymin=0)
        ax.set_xlabel('time (s)')
        ax.set_ylabel('throughput (Gbps)')
        ax.set_title('Achieved throughput')
        ax.legend().set_visible(False)
        fig = plt.gcf()
        fig.set_size_inches(4,3,forward=True)
        plt.tight_layout()
        plt.savefig(splitext(path)[0]+'.pdf',format='pdf')
        plt.close()
