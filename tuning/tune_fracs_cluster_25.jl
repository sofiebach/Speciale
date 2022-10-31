include("ALNS.jl")
include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("MIPModel.jl")
include("tuning.jl")

P = 37
data = read_DR_data(P)

cluster = [0.25]
random = collect(0.1:0.05:0.3)
worst = collect(5:1:10)
related = collect(0.1:0.05:0.3)

filename = "tuning/destroy_cluster_25"
frac_cluster, frac_random, thres_worst, frac_related = tuneDestroy(data, cluster, random, worst, related, filename)

