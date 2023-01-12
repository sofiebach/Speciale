include("ReadWrite.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")
include("Validation/ValidateSolution.jl")
include("MIPModels.jl")

data = readInstance("dataset/test/100_0_0.txt")

sol1 = readSolution("ComputationalResults/ALNS/results/config1/100_0_0/solution_15", data)
sol2 = readSolution("ComputationalResults/MIP/results/1thread/100_0_0_extended1thread", data)

function analyzeObjective(data, sol, p)
    k_penalty = sum(data.penalty_S[p] * sol.k[p])                    # Penalty for not fulfilled Scope
    g_penalty = sum(data.penalty_g[p] * sol.g[t,p] for t=1:data.T)   # Penalty for stacking
    L_penalty = sum(data.weight_idle[p] * (-sol.L[p]+sol.y[p]) + 1)  # Penalty for no spreading

    return k_penalty, g_penalty, L_penalty
end

k1, g1, L1 = analyzeObjective(data, sol1, 36)
k2, g2, L2 = analyzeObjective(data, sol2, 36)
