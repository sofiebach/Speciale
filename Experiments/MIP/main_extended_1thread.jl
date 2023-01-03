include("../../ReadWrite.jl")
include("../../MIPModels.jl")
include("../../BasicFunctions.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]
folder = "Experiments/MIP/results/"
timelimit = data.timeperiod*60

data = readInstance(filepath)

x, gap, time = MIPExtended(data, "Gurobi", 0, timelimit, 0, 0, 1)
sol = MIPtoSol(data,x)

writeSolution(folder * filename * "_extended1thread", data, sol, gap, time)