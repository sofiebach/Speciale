include("../../ReadWrite.jl")
include("../../ALNS.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])
filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)
folder = "Experiments/DestroyRepair/initials/"
init_sol = readSolution(folder*filename, data)
init_obj = init_sol.exp_obj

# destroy_functions = [horizontalDestroy!,verticalDestroy!,randomDestroy!,similarityDestroy!,worstIdleDestroy!,concurrentDestroy!]
# repair_functions = [greedyRepair!, firstRepair!,flexibilityRepair!,bestRepair!,horizontalModelRepair!,regretRepair!,modelRepair!]
config = "config2/"
destroys = [true, false, true, false, false, false]
repairs = [false, false, false, true, true, false, false]

N = 5
time_limit = data.timeperiod * 60
type = "extended"
imps = zeros(Float64, N)

for n = 1:N
    sol, params = ALNS_final(data,init_sol,time_limit,type,repairs,destroys)
    imps[n] = 100 * (init_obj - sol.exp_obj) / init_obj
end

outFile = open("Experiments/DestroyRepair/results/"*config*filename, "w")
write(outFile, "imp\n")
write(outFile, join(mean(imps)," ")*"\n\n")
write(outFile, "std\n")
write(outFile, join(std(imps)," ")*"\n\n")
close(outFile)
 