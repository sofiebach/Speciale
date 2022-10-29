using PyCall
# pyimport_conda("pandas", PKG)
include("ValidateSolution.jl")
used_inv, used_prod = checkSolution(data,sol)
channels = XLSX.readdata("data/data_inventory_consumption.xlsx", "Mapping", "B2:B13")[1:data.C]
media = XLSX.readdata("data/data_staffing_constraint.xlsx", "Bemanding", "A2:A5")[1:data.M]
py"""
pd = pyimport("pandas")
plt = pyimport("matplotlib.pyplot")
np = pyimport("numpy")
sns = pyimport("seaborn")

A = [ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17,
18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62]

def heatmap(used_inv, used_prod, channels, media):
    #fig = make_subplots(
    #    rows=2,
    #    cols=1,
    #    shared_xaxes=True,
    #    vertical_spacing=0.02)    
#
    df1 = pd.DataFrame(transpose(used_prod), index = media)
    df2 = pd.DataFrame(transpose(used_inv), index = channels)

    max_total = max(df1.max().max(),df2.max().max())

    
    f,(ax1,ax2) = plt.subplots(2,1, figuresize = (10,15))

    cbar_ax = f.add_axes([.91, .3, .03, .4])
    p1 = sns.heatmap(df1, linewidths=.5, ax = ax1, vmin=0, vmax=max_total, cbar_ax = cbar_ax)
    ax1.set_xlabel("Time (weeks)")
    ax1.tick_params(axis = 'x', labelsize=14)
    ax1.tick_params(axis = 'y', labelsize=14)
    ax1.figure.set_size_inches((18, 8))

    p2 = sns.heatmap(df2, linewidths=.5, ax = ax2, vmin=0, vmax=max_total, cbar_ax = cbar_ax)
    ax2.tick_params(axis = 'x', labelsize=14)
    ax2.tick_params(axis = 'y', labelsize=24)
    ax2.figure.set_size_inches((18, 8))

    f.tight_layout(rect=[0, 0, .9, 1])
    plt.show()

"""
py"heatmap"(sol,data)