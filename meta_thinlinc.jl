include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("MIPModel.jl")
include("ALNS.jl")

P = 37
data = read_DR_data(P)

sol, prob_destroy, prob_repair = ALNS(data, 120)

println("Prob destroy:")
display(prob_destroy)

println("Prob repair:")
display(prob_repair)

println("Objective: ", sol.obj)
println("Num campaigns: ", sol.num_campaigns)
