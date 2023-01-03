include("../../ALNS.jl")
include("../../ReadWrite.jl")
include("../../ConstructionHeuristics.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])
#idx = 4

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)

folder = "Experiments/InputSolution/initials/"
empty_sol = readSolution(folder*filename*"_empty", data)
good_sol = readSolution(folder*filename*"_good", data)
bad_sol = readSolution(folder*filename*"_bad", data)

type = "baseline"
modelRepair = false
N = 5
time_limit = data.timeperiod * 60
#time_limit = 10

objs = zeros(Float64, 3, N)
for n = 1:N
    # Run ALNS on input solutions
    sol1, params1 = ALNS_final(data, empty_sol, time_limit, type, modelRepair)
    sol2, params2 = ALNS_final(data, bad_sol, time_limit, type, modelRepair)
    sol3, params3 = ALNS_final(data, good_sol, time_limit, type, modelRepair)
    objs[1, n] = sol1.base_obj
    objs[2, n] = sol2.base_obj
    objs[3, n] = sol3.base_obj
end

avg_obj = mean(objs, dims=2)
stds = std(objs, dims=2)

outFile = open("Experiments/InputSolution/results/" * filename*"_"*type, "w")
write(outFile, "empty \t bad \t good \n")
write(outFile, "average objectives\n")
write(outFile, join(avg_obj," ")*"\n\n")
write(outFile, "standard deviations\n")
write(outFile, join(stds," ")*"\n\n")
close(outFile)
