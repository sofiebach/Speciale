include("../../ReadWrite.jl")
include("../../MIPModels.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]
folder = "Experiments/MIP/results/"

outFile = open("test/testfil_" * filename, "w")

data = readInstance(filepath)
outFile = open(folder * filename, "w")
write(outFile, "timeperiod\n")
write(outFile, join(data.timeperiod," ")*"\n\n")
close(outFile)


#x = MIPExtended(data, "Gurobi", 1, data.timeperiod)
#sol = randomInitial(data)

#writeSolution(folder * filename * "_extended")