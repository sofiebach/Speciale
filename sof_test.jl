include("ReadWrite.jl")
include("MIPModels.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")

data = read_DR_data(37)

sol1 = randomInitial(data)

sol2, params = ALNS(data, 30, "baseline", false)

sol2.base_obj
sol2.exp_obj

sol2.objective
sol2.objective.k_penalty - sol2.objective.x_reward + sol2.objective.g_penalty - sol2.objective.L_reward

x = MIPExpansion(data,"HiGHS")



