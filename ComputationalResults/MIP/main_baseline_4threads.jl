include("../../ReadWrite.jl")
include("../../MIPModels.jl")
include("../../BasicFunctions.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]
folder = "Experiments/MIP/results/"
data = readInstance(filepath)

timelimit = 30*60



x, gap, time = MIPBaseline(data, "Gurobi", 1, timelimit, 0, 4)
sol = MIPtoSol(data,x)

writeSolution(folder * filename * "_baseline4threads", data, sol, gap, time)