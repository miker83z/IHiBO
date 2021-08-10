import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import csv
import numpy as np

gasMeasurementsRed = []
gasMeasurementsExt = []
tmpGasRed = []
tmpGasExt = []

gasMeasurementsNeg = []


def plot1():
    fig, _ = plt.subplots(nrows=1, ncols=1, constrained_layout=True)
    fig.set_size_inches(7, 5)
    blue_patch = mpatches.Patch(
        color='tab:blue', label='Enumerating Preferred Extensions of AF method')
    red_patch = mpatches.Patch(
        color='tab:red', label='Reductions of PAF to AF method')

    sxrange = []
    width = 0.4
    j = -1
    for i in range(len(gasMeasurementsRed)):
        if i % 3 == 0:
            j += 1.2
            sxrange.append(i - j + .9 - width)
        elif i % 3 == 1:
            sxrange.append(i - j)
        else:
            sxrange.append(i - j - .9 + width)

    sxrange = np.array(sxrange)
    # print(sxrange)

    plt.ylabel('Gas Cost', fontsize=12)
    # plt.title('Argumentation Gas Cost', fontdict={'fontsize': 16}, weight='heavy')
    plt.bar(sxrange - (width/4), gasMeasurementsRed, (width/2), color='tab:red',
            align='center')
    plt.bar(sxrange + (width/4), gasMeasurementsExt, (width/2), color='tab:blue',
            align='center')
    plt.xticks(sxrange, ['0.33\n', '0.5\n5 nodes\n(i.e. arguments)', '0.66\n',
                         '0.33\n', '0.5\n10 nodes\n(i.e. arguments)', '0.66\n',
                         '0.33\n', '0.5\n15 nodes\n(i.e. arguments)', '0.66\n',
                         '0.33\n', '0.5\n20 nodes\n(i.e. arguments)', '0.66\n'])
    plt.xlabel('Edge (i.e. attack) Formation Probability (p)', fontsize=12)

    plt.legend(handles=[blue_patch, red_patch], fontsize='large')
    # plt.show()
    plt.savefig('./gas-cost.png', bbox_inches='tight', dpi=300)


def plot2():
    fig, _ = plt.subplots(nrows=1, ncols=1, constrained_layout=True)
    fig.set_size_inches(5, 4)

    width = 0.5
    plt.ylabel('Gas Cost', fontsize=12)
    plt.xlabel('Issues Number', fontsize=12)
    # plt.title('Argumentation Gas Cost', fontdict={'fontsize': 16}, weight='heavy')
    # plt.ylim(72000, 558547)
    plt.bar(range(1, 26), gasMeasurementsNeg, width,
            align='center')

    # plt.show()
    plt.savefig('./gas-cost2.png', bbox_inches='tight', dpi=300)


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

with open('data2.csv', 'r') as csvFile:
    reader = csv.reader(csvFile)
    next(reader)
    for row in reader:
        gasMeasurementsNeg.append(int(row[2]))
    plot2()
