include("../../ReadWrite.jl")
include("../../ALNS.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])
#idx=3
filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)
sol = randomInitial(data)
time_limit = data.timeperiod
#time_limit=10
sol, params = ALNS_final(data, sol, time_limit, "extended")

folder = "Experiments/DestroyRepair/results/combinations/"
writeSolution(folder*filename*"_sol", data, sol)
writeParameters(folder*filename*"_params", params)