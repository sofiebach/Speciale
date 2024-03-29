include("../ALNS.jl")
include("tuningscript.jl")

theta, alpha, W, gamma, frac, segment, LTU = read_parameters()
thetas=[theta]
alphas=[alpha]
Ws = [W]
gammas = [gamma]
destroy_fracs=[frac]
segment_sizes=[segment]
long_term_updates=[LTU]

gammas=read_ranges("gamma")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("../dataset/train/", readdir("../dataset/train/"))[idx]
filename = split(split(filepath,"/")[4],".")[1]

stds, averages = tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates, filepath, filename) 

if (!isdir("results/gamma/"))
    mkpath("results/gamma/")
end

f = "results/gamma/" * filename * "_gamma.txt"
write_tuning(f, stds, averages)

println("--- Script successful! ---")