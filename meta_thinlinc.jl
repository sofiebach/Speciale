include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("MIPModel.jl")
include("ALNS.jl")
using Dates
P = 37
data = read_DR_data(P)
timelimit = 600
sol, params = ALNS(data, timelimit)



date_today = string(Dates.today())
filename = "results/ALNS_" * string(timelimit) * "_" * date_today
writeSolution(filename, data, sol)
writeParameters(filename * "_parameters", params) 

sol1 = readSolution(filename)
params = readParameters(filename * "_parameters")