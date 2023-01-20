include("../../ReadWrite.jl")
include("../../ALNS.jl")

data = readInstance("dataset/train/100_0_10.txt")

time_limit = 30*60
destroys = [true,true,true,true,true,true]
repairs = [true,true,true,true,true,true,true]
repair_functions = ["GreedyRepair","FirstRepair","FlexibilityRepair","BestRepair","HorizontalRepair","RegretRepair","ModelRepair"]
destroy_functions = ["HorizontalRemoval","VerticalRemoval","RandomRemoval","SimilarityRemoval","WorstIdleRemoval","ConcurrentRemoval"]
        
init_sol = randomInitial(data)
sol, params = ALNS_final(data,init_sol,time_limit,"extended",repairs,destroys)

outFile = open("Experiments/Profiling/table", "w")
n_digits = 4
avg_destroy = params.time_destroy ./ params.num_destroy
avg_repair = params.time_repair ./ params.num_repair
for i = 1:length(destroys)
    write(outFile, destroy_functions[i]*" & ")
    write(outFile, string(round(avg_destroy[i],digits=n_digits))*" \\\\ \n")
end
write(outFile, "\\midrule \n")
for i = 1:length(repairs)
    write(outFile, repair_functions[i]*" & ")
    write(outFile, string(round(avg_repair[i],digits=n_digits))*" \\\\ \n")
end
close(outFile)
