include("../../ReadWrite.jl")
include("../../ALNS.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])
filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)
folder = "Experiments/DestroyRepair/initials/"
init_sol = readSolution(folder*filename, data)
init_obj = init_sol.exp_obj

destroys = true*ones(Bool, 6)
repairs = true*ones(Bool, 7)

N = 5
M = length(repairs)+1
time_limit = data.timeperiod * 60
type = "extended"
imps = zeros(Float64, M)
stds = zeros(Float64, M)
for i = 1:M
    objs = zeros(Float64, N)
    temp_repairs = deepcopy(repairs)
    if i > 1
        temp_repairs[i-1] = false
    end
    for n = 1:N
        sol, params = ALNS_final(data,init_sol,time_limit,type,temp_repairs,destroys)
        objs[n] = sol.exp_obj
    end
    imps[i] = 100 * (init_obj - mean(objs)) / init_obj
    stds[i] = std(objs)
end

outFile = open("Experiments/DestroyRepair/results/repair/" * filename, "w")
write(outFile, "average imps\n")
write(outFile, join(imps," ")*"\n\n")
write(outFile, "standard deviations\n")
write(outFile, join(stds," ")*"\n\n")
close(outFile)
 