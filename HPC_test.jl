include("ReadWrite.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(path, ".")[1],"/")[3]
outFile = open("test/" * filename, "w")
data = readInstance(filepath)
write(outFile, "Scope\n")
write(outFile, join(data.S," ")*"\n\n")
close(outFile)