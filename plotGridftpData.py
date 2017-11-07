#!/usr/bin/env python

import pandas
import matplotlib.pyplot as plt
import numpy as np
import re
import glob
from os.path import splitext

times = {'host':[], 'paced': [], 'unpaced': []}

for path in glob.glob('*.log'):
	with open(path,'r') as fp:
		if splitext(path)[0] == '190':
			times['host'].append('Amsterdam')
		elif splitext(path)[0] == '191':
			times['host'].append('New York')
		else:
			times['host'].append('Denver')
		for i, line in enumerate(fp):
			start = float(re.compile('START=\d+.\d+').search(line).group(0)[6:])
			end = float(re.compile('DATE=\d+.\d+').search(line).group(0)[5:])
			if i == 0:
				times['paced'].append(end-start)
			else:
				times['unpaced'].append(end-start)

df = pandas.DataFrame(times) 

ind = np.arange(len(df))
width = 0.4

fig, ax = plt.subplots()
ax.barh(ind, df.paced, width, color='red', label='Paced')
ax.barh(ind + width, df.unpaced, width, color='blue', label='Unpaced')

ax.set_title('GridFTP Flow Completion Times to Washington, DC')
ax.set_xlabel('Completion time (s)')
ax.set_ylabel('Sender location')
ax.set(yticks=ind + width, yticklabels=df.host, ylim=[2*width - 1, len(df)])
ax.legend()
plt.tight_layout()
plt.savefig('gridFTP.pdf', format='pdf')
plt.close()
