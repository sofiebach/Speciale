include("../ReadWrite.jl")
include("MIP_tradeoff.jl")
include("../BasicFunctions.jl")
include("../ConstructionHeuristics.jl")

data = readInstance("dataset/25_0_0.txt")

logging = 1
time_limit = 0
gap = 0
spreading = 0

# Find maximum objective for campaigns
sol_max = Sol(data)
randomInsert!(data, sol_max, data.P_bar)

# Find minimum objective for campaigns
x = MIPExpansion(data, logging, time_limit, gap, spreading)
sol_min = MIPtoSol(data, x)

# Initialize points on x-axis
N = 15
X = LinRange(sol_min.base_obj, sol_max.base_obj, N)
Y = zeros(Float64, N)

gap = 0.02
spreading = 1
for i = 1:N
    x2 = MIPExpansion(data, logging, time_limit, gap, spreading, X[i])
    sol2 = MIPtoSol(data, x2)
    Y[i] = sol2.objective.g_penalty - sol2.objective.L_reward
end

outFile = open("results/trade-off", "w")
write(outFile, "X\n")
write(outFile, join(X," ")*"\n\n")
write(outFile, "Y\n")
write(outFile, join(Y," ")*"\n\n")
close(outFile)
