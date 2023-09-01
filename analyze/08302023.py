import ROOT as rt
from matplotlib import pyplot as plt
import numpy as np
import matplotlib.cm
my_cmap = matplotlib.cm.get_cmap('turbo')

rt.gROOT.SetBatch(True)
infile = rt.TFile("../data/08302023/merged.root")
tree = infile.Get("tree")
hmapAll = rt.TH2F("hmapAll","hampAll",180,-90,90,180,-90,90)
# c1=rt.TCanvas("c1","c1",1920,1080)
tree.Draw("sourcePosY:sourcePosX>>hmapAll","","goff")
# hmapAll.Draw()
# c1.Draw()
# c1.SaveAs("root_08302023.png")
mapAll = np.reshape(np.array(hmapAll),(182,182))[1:-1,1:-1]/1e6

# sourcePosX = []
# sourcePosY = []
# gantryID = []
# moduleID = []
# submoduleID = []
# crystalID = []
# layerID = []
# 
print(np.mean(mapAll))
fig, ax = plt.subplots(figsize=(10, 9))
imshow_obj = ax.imshow(mapAll,cmap=my_cmap,origin='lower')
cbar=plt.colorbar(imshow_obj)
# counts, bins = np.histogram(data,data.size)
# plt.bar(bins[:-1],counts)
# # sourcePosX_np = np.asarray(sourcePosX)
# # sourcePosY_np = np.asarray(sourcePosY)
# # submoduleID_np = np.asarray(submoduleID)
# # moduleID_np = np.asarray(moduleID)
# # crystalID_np = np.asarray(crystalID)
# # layerID_np = np.asarray(layerID)
# # xdata = sourcePosX_np
# # ydata = sourcePosY_np
# # ydata = sourcePosY_np[np.where(submoduleID_np==0 and moduleID_np ==0 and crystalID_np == 0 and layerID_np == 0)]
# print(data.shape)
# # print(sourcePosX_np.shape)
# # print(sourcePosY_np.shape)
# # ax.scatter(xdata, ydata)
plt.suptitle("All Recorded Singles in Monte Carlo Simulation")
ax.set_xlabel("Image Space Pixel X-Index")
ax.set_ylabel("Image Space Pixel Y-Index ")
fig.tight_layout()
fig.savefig("08302023.pdf")
# plt.show()
