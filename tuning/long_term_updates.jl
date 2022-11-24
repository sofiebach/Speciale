include("../ALNS.jl")
include("tuningscript.jl")

thetas=[0.05]
alphas=[0.99975]
Ws = [[10,5,1]]
gammas=[0.9]
destroy_fracs=[0.2]
segment_sizes=[10]
long_term_updates=[1000,5000,10000,15000,20000]

stds, averages = tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates) 

filename = "results/initial_LTU.txt"
write_tuning(filename)

println("--- Script successful! ---")