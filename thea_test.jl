include("ReadWrite.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")
include("Validation/ValidateSolution.jl")
include("MIPModels.jl")

data = readInstance("dataset/test/100_0_0.txt")

sol = randomInitial(data)

[greedyRepair!, firstRepair!,flexibilityRepair!,bestRepair!,horizontalModelRepair!,regretRepair!,modelRepair!]

sol, params = ALNS_final(data, sol, 60, "extended", [false, false, false, false, true, false, false], [false, false, true, false, false, false] )



RandomRemoval(data, sol, 0.4)


sol = Sol(data)
horizontalModelRepair!(data, sol, "extended")















MIPExtended(data, "Gurobi", 1, 180)
sol1 = readSolution("ComputationalResults/ALNS/results/config2/100_0_0/solution_14", data)
sol2 = readSolution("ComputationalResults/MIP/results/100_0_0_extended1thread", data)






sol = Sol(data)

function analyzeObjective(data, sol, p)
    k_penalty = sum(data.penalty_S[p] * sol.k[p])                    # Penalty for not fulfilled Scope
    g_penalty = sum(data.penalty_g[p] * sol.g[t,p] for t=1:data.T)   # Penalty for stacking
    L_penalty = sum(data.weight_idle[p] * (-sol.L[p]+sol.y[p]) + 1)  # Penalty for no spreading

    return k_penalty, g_penalty, L_penalty
end

k2, g2, L2 = analyzeObjective(data, sol, 1)

insert!(data, sol, 20, 1)

k1, g1, L1 = analyzeObjective(data, sol, 33)



sol1 = Sol(data)

insert!(data, sol1, data.start, 1)
insert!(data, sol1, data.start, 1)
insert!(data, sol1, 10, 1)
insert!(data, sol1, 20, 1)

sol2 = Sol(data)

insert!(data, sol2, data.start, 1)
insert!(data, sol2, data.start, 1)
insert!(data, sol2, 20, 1)
insert!(data, sol2, 20, 1)

