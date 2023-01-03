include("../../ReadWrite.jl")
include("../../MIPModels.jl")
include("../../BasicFunctions.jl")

idx = 1
filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)

# Increase inventory
data.I = data.I * 50
data.H = data.H * 50

solver = "Gurobi"
log = 1
time_limit = 24 * 60
x, gap, time = MIPExtended(data, solver, log, time_limit)
sol = MIPtoSol(data, x)

writeSolution("ComputationalResults/IncreasedInventory/results/"*filename,data,sol,gap,time)
