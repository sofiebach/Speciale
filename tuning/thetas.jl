include("../ALNS.jl")
include("tuningscript.jl")

thetas=[0.01, 0.025, 0.05, 0.075, 0.1]
alphas=[0.99975]
Ws = [[10,5,1]]
gammas=[0.9]
destroy_fracs=[0.2]
segment_sizes=[10]
long_term_updates=[5000]

stds, averages = tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates) 

filename = "results/initial_theta.txt"
write_tuning(filename)

println("--- Script successful! ---")