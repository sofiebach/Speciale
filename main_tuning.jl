include("ALNS.jl")
include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("MIPModel.jl")
include("tuning.jl")

P = 37
data = read_DR_data(P)

# temperatures = collect(500:100:1000)
# alphas = collect(0.70:0.02:0.99)
temperatures = [100, 1000]
alphas = [0.8, 0.9]

T, alpha = tuneAcceptanceCriteria(data, temperatures, alphas)

# T_alpha, objectives1 = readTuneAcceptance()

cluster = collect(0.1:0.05:0.3)
random = collect(0.1:0.05:0.3)
worst = collect(5:1:10)
related = collect(0.1:0.05:0.3)
# cluster = [0.1, 0.2]
# random = [0.1, 0.2]
# worst = [5, 10]
# related = [0.1, 0.2]
frac_cluster, frac_random, thres_worst, frac_related = tuneDestroy(data, cluster, random, worst, related)

# fracs, objectives2 = readTuneDestroy()

