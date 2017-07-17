#!/usr/bin/env python

import json
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
from os.path import splitext
from glob import glob

for path in glob('*.json'):
    with open(path) as fp:
        data = json.load(fp)
    newpath = splitext(path)[0]+'.csv'
    with open(newpath, 'wb') as ofp:
        writer = csv.writer(ofp)
        title = data['intervals'][0]['streams'][0].keys()
        if 'omitted' in title: title.remove('omitted')
        writer.writerow(title)
        for interval in data['intervals']:
            del interval['streams'][0]['omitted']
            vals = interval['streams'][0].values()
            writer.writerow(vals)

for path in glob('*.csv'):
    try:
        df = pd.read_json(path)
        df['gigs'] = df['bits_per_second'] / float(1000000000)
        ax = df.plot(x='end', y='gigs', color='k')
        ax.set_ylim(ymin=0)
        ax.set_xlabel('time (s)')
        ax.set_ylabel('throughput (Gbps)')
        ax.set_title('Achieved throughput')
        ax.legend().set_visible(False)
        fig = plt.gcf()
        fig.set_size_inches(3,2.25,forward=True)
        #fig.subplots_adjust(bottom=.15)
        plt.tight_layout()
        plt.savefig(splitext(path)[0]+'.pdf',format='pdf')
        plt.close()
    except TypeError as e:
        print e
