include("ReadWrite.jl")
include("BasicFunctions.jl")
include("MIPModels.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)
timelimit = 60*1

x, _, _ = MIPBaseline(data, "Gurobi", 0, timelimit)
sol = MIPtoSol(data, x)

writeSolution("output/Solution_" * filename, data, sol)