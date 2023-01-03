include("../../ReadWrite.jl")
include("../../MIPModels.jl")

#idx = parse(Int64, ENV["LSB_JOBINDEX"])
idx = 3
filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]