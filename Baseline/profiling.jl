include("ALNS.jl")
include("../tuning/tuning.jl")
include("../ReadWrite.jl")
include("../Validation/ValidateSolution.jl")
include("../Validation/PlotSolution.jl")

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
time_limit = 120
sol1, params1 = ALNS(data, time_limit, T, alpha, frac_cluster, frac_random, thres_worst, frac_related)
sol2, params2 = ALNS_uden_modelrepair(data, time_limit, T, alpha, frac_cluster, frac_random, thres_worst, frac_related)

println("--- ALNS with model repair ---")
num_iter1 = length(params1.current_obj)
println("Iterations: ", num_iter1)
println("Repair times: ", params1.time_repair)
avg_time_destroy1 = params1.time_destroy ./ params1.num_destroy
println("Average destroy times: ", avg_time_destroy1)
avg_time_repair1 = params1.time_repair ./ params1.num_repair
println("Average repair times: ", avg_time_repair1)

println("--- ALNS without model repair ---")
num_iter2 = length(params2.current_obj)
println("Iterations: ", num_iter2)
println("Repair times: ", params2.time_repair)
avg_time_destroy2 = params2.time_destroy ./ params2.num_destroy
println("Average destroy times: ", avg_time_destroy2)
avg_time_repair2 = params2.time_repair ./ params2.num_repair
println("Average repair times: ", avg_time_repair2)


