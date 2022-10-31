include("ALNS.jl")
include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("MIPModel.jl")
include("tuning.jl")

P = 37
data = read_DR_data(P)

temperatures = collect(500:100:1000)
alphas = collect(0.70:0.02:0.99)

T, alpha = tuneAcceptanceCriteria(data, temperatures, alphas)
