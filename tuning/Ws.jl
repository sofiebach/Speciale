include("../ALNS.jl")
include("tuningscript.jl")

thetas=[0.05]
alphas=[0.99975]
Ws = [[10,5,1], [10,5,2], [10,9,1], [10,5,5], [7,5,1]]
gammas=[0.9]
destroy_fracs=[0.2]
segment_sizes=[10]
long_term_updates=[5000]

stds, averages = tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates) 

filename = "results/initial_W.txt"
outFile = open(filename, "w")
write(outFile, "Tuning parameter: W\n\n")

write(outFile, "thetas\n")
write(outFile,join(thetas," ")*"\n\n")
write(outFile, "alphas\n")
write(outFile,join(alphas," ")*"\n\n")
write(outFile, "Ws\n")
write(outFile,join(Ws," ")*"\n\n")
write(outFile, "gammas\n")
write(outFile,join(gammas," ")*"\n\n")
write(outFile, "destroy_fracs\n")
write(outFile,join(destroy_fracs," ")*"\n\n")
write(outFile, "segment_sizes\n")
write(outFile,join(segment_sizes," ")*"\n\n")
write(outFile, "long_term_update\n")
write(outFile,join(long_term_updates," ")*"\n\n")

write(outFile, "Standard deviations\n")
for i = 1:5
    write(outFile,join(stds[:,i]," ")*"\n")
end
write(outFile, "\n")
write(outFile, "Average\n")
for i = 1:5
    write(outFile,join(averages[:,i]," ")*"\n")
end
write(outFile, "\n")

close(outFile)

println("--- Script successful! ---")