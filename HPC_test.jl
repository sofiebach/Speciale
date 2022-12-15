include("ReadWrite.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filename = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
outFile = open("test/" * string(filename[15:21]), "w")
data = readInstance(filename)
write(outFile, "Scope\n")
write(outFile, join(data.S," ")*"\n\n")
close(outFile)