include("tuningscript.jl")

destroy_method = horizontalDestroy!
destroy_fracs = [0.05,0.1,0.15,0.2,0.3]

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath,"/")[3],".")[1]

stds, averages = tune(destroy_method,destroy_fracs,filepath) 

f = "tuning/new_destroy_tune/results/" * string(destroy_method)[1:end-1] * "/" * filename * ".txt"
write_tuning(f, destroy_method, destroy_fracs, stds, averages)

println("--- Script successful! ---")