include("../ReadWrite.jl")
include("../ALNS.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]
folder = "ALNS_test_sletmigsenere/results/"

data = readInstance(filepath)

timelimit = data.timeperiod*60
sol = randomInitial(data)

sol, params = ALNS_final(data, sol, timelimit, "extended")

outFile = open("ALNS_test_sletmigsenere/results/" * filename * "_fil", "w")
write(outFile, join([sol.objective.k_penalty, sol.objective.g_penalty, sol.objective.L_penalty]," ")*"\n\n")
write(outFile, "exp obj\n")
write(outFile, join(sol.exp_obj," "))
write(outFile, "\nbase obj \n")
write(outFile, join(sol.base_obj," "))
close(outFile)