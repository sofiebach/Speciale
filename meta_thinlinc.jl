include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("MIPModel.jl")
include("ALNS.jl")

P = 37
data = read_DR_data(P)
timelimit = 60
sol, prob_destroy, prob_repair = ALNS(data, timelimit)

# println("Prob destroy:")
# display(prob_destroy)
# 
# println("Prob repair:")
# display(prob_repair)
# 
# println("Objective: ", sol.obj)
# println("Num campaigns: ", sol.num_campaigns)
date_today = string(Dates.now())
filename = "results/ALNS_" * string(timelimit) * "_" * date_today
writeSolution(filename, data, sol)

sol1 = readSolution(filename)