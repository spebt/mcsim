import ROOT as rt
from matplotlib import pyplot as plt
import numpy as np

rt.gROOT.SetBatch(True)
infile = rt.TFile("../data/08282023/merge.root")
myTree = infile.Get("tree")
# sourcePosX = []
# sourcePosY = []
# gantryID = []
# moduleID = []
# submoduleID = []
# crystalID = []
# layerID = []
singleIDs = []
print(myTree.GetEntries())
for entry in myTree:
    physicalID  = entry.layerID + entry.crystalID*8 + entry.submoduleID*32 + entry.rsectorID*128
    # gantryID.append(entry.gantryID)
    # moduleID.append(entry.moduleID)
    # submoduleID.append(entry.submoduleID)
    # crystalID.append(entry.crystalID)
    # layerID.append(entry.layerID)
    singleIDs.append(physicalID)
data=np.asarray(singleIDs)

fig, ax = plt.subplots(figsize=(16, 9))
counts, bins = np.histogram(data,data.size)
plt.bar(bins[:-1],counts)
# sourcePosX_np = np.asarray(sourcePosX)
# sourcePosY_np = np.asarray(sourcePosY)
# submoduleID_np = np.asarray(submoduleID)
# moduleID_np = np.asarray(moduleID)
# crystalID_np = np.asarray(crystalID)
# layerID_np = np.asarray(layerID)
# xdata = sourcePosX_np
# ydata = sourcePosY_np
# ydata = sourcePosY_np[np.where(submoduleID_np==0 and moduleID_np ==0 and crystalID_np == 0 and layerID_np == 0)]
print(data.shape)
# print(sourcePosX_np.shape)
# print(sourcePosY_np.shape)
# ax.scatter(xdata, ydata)
plt.suptitle("Single Distribution from the Monte Carlo Simulation")
ax.set_xlabel("Physical Crystal Index")
ax.set_ylabel("Counts of the Singles")
fig.savefig("08282023.png")
# plt.show()
