include("../../ReadWrite.jl")
include("../../MIPModels.jl")
include("../../BasicFunctions.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]
folder = "Experiments/MIP/results/"
data = readInstance(filepath)

timelimit = data.timeperiod*60



x, gap, time = MIPBaseline(data, "Gurobi", 1, timelimit, 0, 1)
sol = MIPtoSol(data,x)

writeSolution(folder * filename * "_baseline1thread", data, sol, gap, time)