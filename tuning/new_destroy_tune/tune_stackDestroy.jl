include("tuningscript.jl")

horizontalDestroy = [0.2]
verticalDestroy = [0.2]
randomDestroy = [0.2]
relatedDestroy = [0.2]
worstIdleDestroy = [0.2]
stackDestroy = [0.1,0.2,0.3,0.4,0.5]

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath,"/")[3],".")[1]

stds, averages = tune(horizontalDestroy,verticalDestroy,randomDestroy,relatedDestroy,worstIdleDestroy,stackDestroy,filepath) 

f = "tuning/new_destroy_tune/results/stackDestroy_" * filename * ".txt"
write_tuning(f, stds, averages)

println("--- Script successful! ---")