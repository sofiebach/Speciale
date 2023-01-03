include("ReadWrite.jl")
include("ALNS.jl")

idx = 4#parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]
folder = "ALNS_test_sletmigsenere/results/"
timelimit = data.timeperiod*60

data = readInstance(filepath)

sol, params = ALNS_final(data, sol, timelimit, "extended")

