include("../ALNS.jl")
include("tuningscript.jl")

thetas=[0.05]
alphas=[0.99975]
Ws = [[10,5,1]]
gammas=[0.9]
destroy_fracs=[0.1, 0.2, 0.3, 0.4, 0.5]
segment_sizes=[10]
long_term_updates=[5000]

stds, averages = tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates) 

filename = "results/initial_destroy_frac.txt"
write_tuning(filename)

println("--- Script successful! ---")