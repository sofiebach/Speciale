include("../../ReadWrite.jl")
include("MIP_Terms.jl")
include("../../MIPModels.jl")
include("../../Validation/PlotSolution.jl")
include("../../BasicFunctions.jl")


filepath = joinpath.("dataset/train/", readdir("dataset/train/"))
file = filepath[1]
filename = split(split(file, ".")[1],"/")[3]

data = readInstance(file)
data.I = 10000*ones(data.T, data.C)
data.H = 10000*ones(data.T, data.M)

mins = 60

folder = "Experiments/ObjectiveTerms/results/"

# Only k term
x1 = MIPBaseline(data, "Gurobi", 1, 60*mins)
sol1 = MIPtoSol(data, x1)
writeSolution(folder*filename*"_sol1", data, sol1)

# Only k and g
x2 = MIPSpreadingTerms(data, 1, 60*mins, 0, 2)
sol2 = MIPtoSol(data, x2)
writeSolution(folder*filename*"_sol2", data, sol2)

# Only k and L, y
x3 = MIPSpreadingTerms(data, 1, 60*mins, 0, 3)
sol3 = MIPtoSol(data, x3)
writeSolution(folder*filename*"_sol3", data, sol3)

# All terms
x4 = MIPSpreadingTerms(data, 1, 60*mins, 0, 4)
sol4 = MIPtoSol(data, x4)
writeSolution(folder*filename*"_sol4", data, sol4)


