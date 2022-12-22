include("../../ReadWrite.jl")
include("ALNS_analysis.jl")

# idx = parse(Int64, ENV["LSB_JOBINDEX"])
idx = 4

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)
folder = "Experiments/DestroyRepair/initials/"
init_sol = readSolution(folder*filename, data)

destroy_functions = [horizontalDestroy!,verticalDestroy!,randomDestroy!,relatedDestroy!,worstIdleDestroy!,stackDestroy!]
repair_functions = [greedyRepair!, firstRepair!,flexibilityRepair!,bestRepair!,modelRepair!,horizontalModelRepair!,regretRepair!]

N = 1
# time_limit = data.timeperiod * 60
time_limit = 10
type = "extended"
for i = 1:length(destroy_functions)
    destroys = deepcopy(destroy_functions)
    deleteat!(destroys, i)
    for n = 1:N
        sol, params = ALNS_analysis(data,init_sol,time_limit,type,destroys,repair_functions)    
    end
end
 