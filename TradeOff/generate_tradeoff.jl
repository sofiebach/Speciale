include("../ReadWrite.jl")
include("MIP_tradeoff.jl")
include("../MIPModels.jl")
include("../BasicFunctions.jl")
include("../ConstructionHeuristics.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)

logging = 1
time_limit = 0
gap = 0.1
spreading = 0

# Find maximum objective for campaigns
sol_max = Sol(data)
randomInsert!(data, sol_max, data.P_bar)

# Find minimum objective for campaigns
# x = MIPBaseline(data, "Gurobi", logging, time_limit, gap)
x = MIPTradeoff(data, logging, time_limit, gap, spreading)
sol_min = MIPtoSol(data, x)

# Initialize points on x-axis
N = 10
X = LinRange(sol_min.base_obj, sol_max.base_obj, N)
Y = zeros(Float64, N)
spreading = 1
gap = 0.2
for i = 1:N
    x2 = MIPTradeoff(data, logging, time_limit, gap, spreading, X[i])
    sol2 = MIPtoSol(data, x2)
    Y[i] = sol2.objective.g_penalty - sol2.objective.L_reward + sol2.objective.y_penalty
end
outFile = open("TradeOff/results/"*filename, "w")
write(outFile, "X\n")
write(outFile, join(X," ")*"\n\n")
write(outFile, "Y\n")
write(outFile, join(Y," ")*"\n\n")
close(outFile)
