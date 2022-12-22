include("../ALNS.jl")
include("tuningscript.jl")

theta, alpha, W, gamma, frac, segment, LTU = read_parameters()
thetas=[theta]
alphas=[alpha]
Ws = [W]
gamma = [gamma]
destroy_fracs=[frac]
segment_sizes=[segment]
long_term_updates=[LTU]

destroy_fracs=[0.1, 0.2, 0.3, 0.4, 0.5]

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("../dataset/train/", readdir("../dataset/train/"))[idx]
filename = split(split(filepath,"/")[4],".")[1]

stds, averages = tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates, filepath, filename) 

f = "results/" * filename * "_frac.txt"
write_tuning(f)

println("--- Script successful! ---")