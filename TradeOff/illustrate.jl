using Plots
using PyCall

py"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import ticker
import matplotlib.font_manager

def tradeoffIllustration(x, y, lambdas, filename):
    # font = {'fontname':'Times'}
    
    #plt.rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
    fig, ax = plt.subplots()
    fig.set_figheight(7)
    fig.set_figwidth(7)
    ax.plot(x, y, '--', linewidth=1, color="black", dashes=(5, 5))
    ax.plot(x, y, 'o', markersize=10, color='tab:blue')
    # for j in range(len(lambdas)):
    #     ax.plot(x[j], y[j], '.', markersize=10)
    # for j, txt in enumerate(lambdas):
    #     ax.annotate(txt, (x[j], y[j]))
    # plt.legend(lambdas)
    ax.tick_params(axis='x', labelsize=20)
    ax.tick_params(axis='y', labelsize=20)
    # plt.title("Trade-off between terms in cost function",fontsize="20")
    plt.title("Data instance: " + filename,fontsize="20")
    plt.xlabel("Scope term",fontsize="20")
    plt.ylabel("Distribution term",fontsize="20")
    plt.savefig("TradeOff/" + filename + ".pdf")
    plt.close()

"""
folder = "TradeOff/results/"
filenames = joinpath.(folder, readdir(folder))

for file in filenames
    f = open(file)
    readline(f) # lambdas
    lambdas = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # X
    x = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # Y
    y = parse.(Float64,split(readline(f)))
    readline(f) # blank
    close(f)
    prefix = length(folder)
    py"tradeoffIllustration"(x, y, lambdas, file[prefix+1:end])

end

