include("../ReadWrite.jl")
include("MIP_tradeoff.jl")
include("../MIPModels.jl")
include("../BasicFunctions.jl")
include("../ConstructionHeuristics.jl")

n = 5

filenames = joinpath.("dataset/train/", readdir("dataset/train/"))
outFile = open("TradeOff/results/trade-off" * string(filenames[n][15:21]), "w")
for f in [filenames[n]]
    data = readInstance(f)

    logging = 1
    time_limit = 0
    gap = 0.1
    spreading = 0

    # Find maximum objective for campaigns
    sol_max = Sol(data)
    randomInsert!(data, sol_max, data.P_bar)

    # Find minimum objective for campaigns
    x = MIPBaseline(data, "Gurobi", logging, time_limit, gap)
    sol_min = MIPtoSol(data, x)

    # Initialize points on x-axis
    N = 10
    X = LinRange(sol_min.base_obj, sol_max.base_obj, N)
    Y = zeros(Float64, N)

    gap = 0.1
    spreading = 1
    for i = 1:N
        x2 = MIPTradeoff(data, logging, time_limit, gap, spreading, X[i])
        sol2 = MIPtoSol(data, x2)
        Y[i] = sol2.objective.g_penalty - sol2.objective.L_reward + sol2.objective.y_penalty
    end

    write(outFile, "X\n")
    write(outFile, join(X," ")*"\n\n")
    write(outFile, "Y\n")
    write(outFile, join(Y," ")*"\n\n")
end
close(outFile)
