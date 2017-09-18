fh = open("wsn.tr", "r")
data = fh.readlines()
nodes = [[] for _ in range(6)]
for line in data:
    arr = line.split()
    if arr[0] in ['s','r']:
        node = arr[2][1]
        residual = float(arr[13])
        spent = float(arr[15]) + float(arr[17]) + float(arr[19]) + float(arr[21][:-1]) 
        time = float(arr[1])
        nodes[int(node)].append([time, residual, spent])
        # print node,time,residual,spent

for i in range(6):
    spent_energy = sum([x[2] for x in nodes[i]])
    try:
        residual_energy = nodes[i][len(nodes[i])-1][1]
    except:
        pass
    print "node {0} spent {1}i residual {2}".format(i,spent_energy,residual_energy)
