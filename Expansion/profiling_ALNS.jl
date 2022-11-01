include("ALNS_expanded.jl")
include("../tuning/tuning.jl")
include("../ReadWrite.jl")


# Read best T and best alpha
params1, objs1 = readTuneAcceptance()
_, idx1 = findmin(objs1)
T, alpha = params1[idx1]

# Read best fractions and thresholds
fracs_10, objs_10 = readTuneDestroy("tuning/destroy_cluster_10")
fracs_15, objs_15 = readTuneDestroy("tuning/destroy_cluster_15")
fracs_20, objs_20 = readTuneDestroy("tuning/destroy_cluster_20")
fracs_25, objs_25 = readTuneDestroy("tuning/destroy_cluster_25")
fracs_30, objs_30 = readTuneDestroy("tuning/destroy_cluster_30")
objs2 = vcat(objs_10, objs_15, objs_20, objs_25, objs_30)
params2 = vcat(fracs_10, fracs_15, fracs_20, fracs_25, fracs_30)

_, idx2 = findmin(objs2)
frac_cluster, frac_random, thres_worst, frac_related = params2[idx2]

# Read data 
P = 37
data = read_DR_data(P)

# Run ALNS with tuned parameters
time_limit = 60
sol, params = ALNS(data, time_limit, T, alpha, frac_cluster, frac_random, thres_worst, frac_related)





