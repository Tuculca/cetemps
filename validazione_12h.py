import sys
import numpy
import pandas
import hashlib
import datetime

### INPUT FROM TERMINAL ###
date = sys.argv[1] #esempio 2022/08/17
### DATE FOR OUTPUT FILENAME ###
date_for_filename = datetime.datetime.strptime(date,"%Y/%m/%d").strftime("%d%m%Y")
### READ CSV ###
obs = pandas.read_csv('exportData_october.csv')
len_obs = len(obs)
### RENAME COLUMNS TO REMOVE SPECIAL CHARACTERS ###
obs = obs.rename(columns={'CUMULATED 12 hours':'CUMULATED_12_hours'})
obs = obs.rename(columns={'DATE/TIME':'DATE_TIME'})
obs = obs[obs.CUMULATED_12_hours > -1000]
obs = obs[(obs['DATE_TIME'] == date + ' 00.00') | (obs['DATE_TIME'] == date + ' 12.00')]  


#obs = obs[obs.CUMULATED_3_hours != -9998.0]
#obs = obs[obs.DATE_TIME == date + ' ' + ora]
stazioni = dict([(y, x) for x, y in list(enumerate(sorted(set(obs['STATION']))))])

with open('PLUVIO_acc12h_' + date_for_filename + '.txt', 'w') as f:
	for j in range(len_obs):
		try:
			f.write('ADPSFC ' + \
			"{0:>4}".format(str(stazioni[obs['STATION'][j]])) + ' ' + \
			datetime.datetime.strptime(obs['DATE_TIME'][j],"%Y/%m/%d %H.%M").strftime("%Y%m%d_%H%M%S") + '   ' + \
			"{0:>5}".format(str("%.2f" % obs['LAT'][j])) + '   ' + \
			"{0:>5}".format(str("%.2f" % obs['LON'][j])) + \
			" -9999.00 61 12 -9999.00 NA   " + \
			"{0:>4}".format(str("%.2f" % obs['CUMULATED_12_hours'][j])) + '\n')
		except KeyError:
			pass