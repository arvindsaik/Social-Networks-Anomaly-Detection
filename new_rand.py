import pickle
path = 'dataset/'

file = open(path+'78813.txt', 'r')


nodes = ['0']

for line in file:
	nodes.append(line.split(' ')[0])

print nodes
#filenames = ['0', '107', '348', '414', '686', '698', '1684', '1912', '3437', '3980']
