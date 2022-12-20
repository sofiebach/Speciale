include("../ALNS.jl")
include("tuningscript.jl")

thetas=[0.05]
alphas=[0.99975]
Ws = [[10,5,1], [10,5,2], [10,9,1], [10,5,5], [7,5,1]]
gammas=[0.9]
destroy_fracs=[0.2]
segment_sizes=[100]
long_term_updates=[0.1]

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

stds, averages = tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates, filepath, filename) 

f = "tuning/results/initial_W" * filename * ".txt"
write_tuning(f)

println("--- Script successful! ---")