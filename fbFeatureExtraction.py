path = 'dataset/twitter/'
filenames = ['0', '107', '348', '414', '686', '698', '1684', '1912', '3437', '3980']

nodes = 81306
feature_total_number = 999
feature_matrix = [[0 for i in range(feature_total_number)] for j in range(nodes)]

for filename in filenames:
    features = []
    file_featnames = open(path + filename + '.featnames', 'r')
    for i, line in enumerate(file_featnames):
        line_split = line.split(';')
        #print line_split
        feature_number = line_split[-1].split(' ')
        #print feature_number
        features.append(int(feature_number[-1]))
    file_featnames.close()

    file_feat = open(path + filename + '.feat', 'r')
    for line in file_feat:
        line_split = line.split(' ')
        node_number = int(line_split[0])
        for i, x in enumerate(line_split[1:]):
            if x == '1':
                #print "here"
                feature_matrix[node_number][features[i]] = 1
    file_feat.close()

    file_egofeat = open(path + filename + '.egofeat', 'r')
    for line in file_egofeat:
        line_split = line.split(' ')
        for i, x in enumerate(line_split):
            if x == '1':
                #print "here2"
                feature_matrix[int(filename)][features[i]] = 1

output_file = open('dataset/twit-features.txt', 'w')
for i in feature_matrix:
    for j in i:
        print >> output_file, j,
    print >> output_file
