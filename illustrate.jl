using Plots
using PyCall

gap = 0.02
f = open("results/trade-off")
readline(f) # X
X = parse.(Float64,split(readline(f)))
readline(f) # blank
readline(f) # Y
Y = parse.(Float64,split(readline(f)))
close(f)
Y_gap = -(gap .* abs.(Y) .- Y)
filename = "test"

#plot(X,[Y, Y_gap])

py"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import ticker

def tradeoffIllustration(X, Y, Y_gap, filename):
    
    # plt.plot(X, Y, 'bo', markersize = 4)
    # plt.plot(X, Y_gap, 'yo', markersize = 4)

    fig, ax = plt.subplots()
    ax.plot(X, Y, '-', color='tab:blue')
    ax.plot(X, Y_gap, '--', linewidth=0.5, color='tab:blue')
    ax.fill_between(X, Y, Y_gap, alpha=0.2)
    y_min = min(Y) * 1.1
    y_max = max(Y) * 1.1
    x_min = min(X)
    x_max = max(X)
    ax.set_ylim([y_min, y_max])
    ax.axhspan(y_min, (y_max+y_min)/2, 0, 0.5, facecolor='green', alpha=0.2)
    ax.axhspan(y_min, (y_max+y_min)/2, 0.5, 1, facecolor='orange', alpha=0.2)
    ax.axhspan((y_max+y_min)/2, y_max, 0, 0.5, facecolor='orange', alpha=0.2)
    ax.axhspan((y_max+y_min)/2, y_max, 0.5, 1, facecolor='red', alpha=0.2)
    
    plt.title("Minizing spreading term, fixed campaign term")
    plt.xlabel("Campaign term")
    plt.ylabel("Spreading term")
    plt.savefig("output/" + filename + ".png")
    
    #plt.show()

"""
py"tradeoffIllustration"(X, Y, Y_gap, filename)


