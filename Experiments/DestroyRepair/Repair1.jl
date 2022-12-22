include("../../ReadWrite.jl")
include("ALNS_analysis.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])
# idx = 4

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)
folder = "Experiments/DestroyRepair/initials/"
init_sol = readSolution(folder*filename, data)
init_obj = init_sol.exp_obj

destroy_functions = [horizontalDestroy!,verticalDestroy!,randomDestroy!,relatedDestroy!,worstIdleDestroy!,stackDestroy!]
repair_functions = [greedyRepair!, firstRepair!,flexibilityRepair!,bestRepair!,modelRepair!,horizontalModelRepair!,regretRepair!]

N = 3
M = length(repair_functions)
time_limit = data.timeperiod * 60
# time_limit = 10
type = "extended"
imps = zeros(Float64, M)
stds = zeros(Float64, M)
for i = 1:M
    objs = zeros(Float64, N)
    repairs = deepcopy(repair_functions)
    deleteat!(repairs, i)
    for n = 1:N
        sol, params = ALNS_analysis(data,init_sol,time_limit,type,destroy_functions,repairs)
        objs[n] = sol.exp_obj
    end
    imps[i] = 100 * (init_obj - mean(objs)) / init_obj
    stds[i] = std(objs)
end

outFile = open("Experiments/DestroyRepair/results/repair/" * filename, "w")
write(outFile, "functions\n")
write(outFile, join(repair_functions," ")*"\n\n")
write(outFile, "average imps\n")
write(outFile, join(imps," ")*"\n\n")
write(outFile, "standard deviations\n")
write(outFile, join(stds," ")*"\n\n")
close(outFile)
 