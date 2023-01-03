include("ReadWrite.jl")
include("ALNS.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]
folder = "Experiments/MIP/results/"
timelimit = data.timeperiod*60
