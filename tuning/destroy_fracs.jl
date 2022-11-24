include("../ALNS.jl")
include("tuningscript.jl")

thetas=[0.05]
alphas=[0.99975]
Ws = [[10,5,1]]
gammas=[0.9]
destroy_fracs=[0.1, 0.2, 0.3, 0.4, 0.5]
segment_sizes=[10]
long_term_update=[5000]

stds, averages = tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates) 

filename = "tuning/results/initial_destroy_frac.txt"
outFile = open(filename, "w")
write(outFile, "Tuning parameter: destroy_frac\n\n")

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
write(outFile,join(long_term_update," ")*"\n\n")

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