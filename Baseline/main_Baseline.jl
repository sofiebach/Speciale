include("../tuning/tuning.jl")
include("ReadWrite.jl")
include("ALNS.jl")
using Dates

# Read best T and best alpha
prefix = "results/"
params1, objs1 = readTuneAcceptance(prefix * "acceptanceCriteria")
_, idx1 = findmin(objs1)
T, alpha, gamma = params1[idx1]

# Read best fractions and thresholds
fracs_10, objs_10 = readTuneDestroy(prefix * "destroy_10")
fracs_15, objs_15 = readTuneDestroy(prefix * "destroy_15")
fracs_20, objs_20 = readTuneDestroy(prefix * "destroy_20")
fracs_25, objs_25 = readTuneDestroy(prefix * "destroy_25")
fracs_30, objs_30 = readTuneDestroy(prefix * "destroy_30")
objs2 = vcat(objs_10, objs_15, objs_20, objs_25, objs_30)
params2 = vcat(fracs_10, fracs_15, fracs_20, fracs_25, fracs_30)
_, idx2 = findmin(objs2)
frac_cluster, frac_random, thres_worst, frac_related = params2[idx2]

# Read data 
P = 37
data = read_DR_data(P)
time_limit = 3600
date_today = string(Dates.today())

# Run MIP Baseline
sol_MIP = MIPBaseline(data, time_limit, 0, 1)
filename = "results/MIPBaseline_" * string(time_limit) * "_" * date_today
writeSolution(filename, data, sol_MIP)

# Run ALNS without modelRepair
sol1, params1 = ALNSBaseline(data, time_limit, false, T, alpha, gamma, frac_cluster, frac_random, thres_worst, frac_related)
filename = "results/ALNSBaseline_without_" * string(time_limit) * "_" * date_today
writeSolution(filename, data, sol1)
writeParameters(filename * "_parameters", params1) 
test = readParameters(filename * "_parameters")

# Run ALNS with modelRepair
sol2, params2 = ALNSBaseline(data, time_limit, true, T, alpha, gamma, frac_cluster, frac_random, thres_worst, frac_related)
filename = "results/ALNSBaseline_with_" * string(time_limit) * "_" * date_today
writeSolution(filename, data, sol2)
writeParameters(filename * "_parameters", params2) 

# Print to check that no errors occured
println("--- Script successful! ---")



