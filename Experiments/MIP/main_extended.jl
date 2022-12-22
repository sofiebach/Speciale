include("../../ReadWrite.jl")
include("../../MIPModels.jl")
include("../../BasicFunctions.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]
folder = "Experiments/MIP/results/"

data = readInstance(filepath)

x, gap, time = MIPExtended(data, "Gurobi", 0, data.timeperiod*60)
sol = MIPtoSol(data,x)

writeSolution(folder * filename * "_extended", data, sol, gap, time)