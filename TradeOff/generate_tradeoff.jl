include("../ReadWrite.jl")
include("MIP_tradeoff.jl")
include("../BasicFunctions.jl")
include("../ConstructionHeuristics.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)

logging = 1
time_limit = 0
gap = 0.05

# Initialize points on x-axis
N = 11
lambdas = LinRange(0, 1, N)
X = zeros(Float64, N)
Y = zeros(Float64, N)

for i = 1:N
    lambda = lambdas[i]
    x = MIPTradeoff(data, logging, time_limit, gap, lambda)
    sol = MIPtoSol(data, x)
    X[i] = sol.objective.k_penalty
    Y[i] = sol.objective.g_penalty + sol.objective.L_penalty
end
outFile = open("TradeOff/results/"*filename, "w")
write(outFile, "lambdas\n")
write(outFile, join(lambdas," ")*"\n\n")
write(outFile, "X\n")
write(outFile, join(X," ")*"\n\n")
write(outFile, "Y\n")
write(outFile, join(Y," ")*"\n\n")
close(outFile)
