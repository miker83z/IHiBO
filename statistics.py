import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import csv
import numpy as np

gasMeasurementsRed = []
gasMeasurementsExt = []
tmpGasRed = []
tmpGasExt = []


def plot1():
    fig, _ = plt.subplots(nrows=1, ncols=1, constrained_layout=True)
    fig.set_size_inches(10, 7.5)
    red_patch = mpatches.Patch(color='tab:red', label='Reduction method')
    blue_patch = mpatches.Patch(
        color='tab:blue', label='Pref Extensions method')

    sxrange = []
    width = 0.4
    for i in range(len(gasMeasurementsRed)):
        if i % 2:
            sxrange.append(i + width - .15)
        else:
            sxrange.append(i + 1.15 - width)
    sxrange = np.array(sxrange)
    print(sxrange)

    plt.ylabel('Gas Cost', fontsize=13)
    # plt.title('Argumentation Gas Cost', fontdict={'fontsize': 16}, weight='heavy')
    plt.bar(sxrange - (width/4), gasMeasurementsRed, (width/2), color='tab:red',
            align='center')
    plt.bar(sxrange + (width/4), gasMeasurementsExt, (width/2), color='tab:blue',
            align='center')
    plt.xticks(sxrange, ['    5\np = 0.33', 'nodes        \np = 0.5', '    10\np = 0.33', 'nodes        \np = 0.5',
                         '    15\np = 0.33', 'nodes        \np = 0.5', '    20\np = 0.33', 'nodes        \np = 0.5'])

    plt.legend(handles=[blue_patch, red_patch], fontsize='large')
    plt.show()


with open('data.csv', 'r') as csvFile:
    reader = csv.reader(csvFile)
    next(reader)
    nodesTmp = 5
    edgesPTmp = 0.33
    for row in reader:
        nodesNumber = int(row[0])
        edgesNumber = int(row[1])
        edgesP = float(row[2])
        prefP = float(row[3])
        reductionPref3 = int(row[4])
        prefExtensionsGas = int(row[5])

        if (nodesNumber != nodesTmp or edgesP != edgesPTmp):
            nodesTmp = nodesNumber
            edgesPTmp = edgesP
            gasMeasurementsRed.append(np.mean(tmpGasRed))
            gasMeasurementsExt.append(np.mean(tmpGasExt))
            tmpGasRed = []
            tmpGasExt = []
        tmpGasRed.append(reductionPref3)
        tmpGasExt.append(prefExtensionsGas)
    gasMeasurementsRed.append(np.mean(tmpGasRed))
    gasMeasurementsExt.append(np.mean(tmpGasExt))
    plot1()
