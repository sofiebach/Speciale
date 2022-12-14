using Plots
using PyCall

filenames = joinpath.("dataset/train/", readdir("dataset/train/"))
f = open("TradeOff/results/trade-off2")


X = []
Y = []

for _ in filenames
    readline(f) # X
    x = parse.(Float64,split(readline(f)))
    push!(X, x)
    readline(f) # blank
    readline(f) # Y
    y = parse.(Float64,split(readline(f)))
    push!(Y, y)
    readline(f) # blank
end
close(f)

# gap = 0.1
# Y_gap = -(gap .* abs.(Y) .- Y)

py"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import ticker

def tradeoffIllustration(X, Y, Y_gap, filename):
    
    
    fig, ax = plt.subplots()

    for i in range(len(X)):
        ax.plot(X[i], Y[i], '--', linewidth=1, color="black")
        ax.plot(X[i], Y[i], '.', markersize=10, color='tab:blue')
        # ax.plot(X, Y_gap, '--', linewidth=0.5, color='tab:blue')
        # ax.fill_between(X, Y, Y_gap, alpha=0.2)
        
    plt.title("Minizing spreading term, fixed campaign term")
    plt.xlabel("Campaign term")
    plt.ylabel("Spreading term")
    plt.savefig("TradeOff/results/" + filename + ".png")
        
    #plt.show()

"""
py"tradeoffIllustration"(X, Y, Y_gap, filename)


