include("../../ALNS.jl")
include("../../ReadWrite.jl")
include("../../ConstructionHeuristics.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])
# idx = 1

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)

type = "extended"
modelRepair = false
N = 5
time_limit = data.timeperiod * 60

# Input solutions
empty_sol = Sol(data)
good_obj = deepcopy(empty_sol.exp_obj) 
good_sol = 0
bad_obj = -deepcopy(empty_sol.exp_obj)
bad_sol = 0
for n = 1:100
    temp_sol = randomInitial(data)
    if temp_sol.exp_obj < good_obj 
        good_obj = temp_sol.exp_obj
        good_sol = deepcopy(temp_sol)
    end 
    if temp_sol.exp_obj > bad_obj 
        bad_obj = temp_sol.exp_obj
        bad_sol = deepcopy(temp_sol)
    end
end

m = 3
objs = zeros(Float64, m, N)
for n = 1:N    
    # Run ALNS on input solutions
    sol1, params1 = ALNS(data, empty_sol, time_limit, type, modelRepair)
    sol2, params2 = ALNS(data, bad_sol, time_limit, type, modelRepair)
    sol3, params3 = ALNS(data, good_sol, time_limit, type, modelRepair)
    objs[1, n] = sol1.exp_obj
    objs[2, n] = sol2.exp_obj
    objs[3, n] = sol3.exp_obj
end

avg_obj = mean(objs, dims=2)
stds = std(objs, dims=2)

outFile = open("Experiments/InputSolution/" * filename * "_results", "w")
write(outFile, "empty \t bad \t good \n")
write(outFile, "average objectives\n")
write(outFile, join(avg_obj," ")*"\n\n")
write(outFile, "standard deviations\n")
write(outFile, join(stds," ")*"\n\n")
close(outFile)
