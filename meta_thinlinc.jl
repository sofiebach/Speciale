include("ReadWrite.jl")

include("MIPModelSpreading.jl")
include("MetaSpreading/ALNS_expanded.jl")
include("MetaSpreading/ConstructionHeuristics_expanded.jl")
using Dates
P = 37
data = read_DR_data(P)
timelimit = 60


sol = randomInitial(data)
sol, params = ALNS(data, timelimit)



date_today = string(Dates.today())
filename = "results/ALNS_" * string(timelimit) * "_" * date_today
writeSolution(filename, data, sol)
writeParameters(filename * "_parameters", params) 

sol1 = readSolution(filename)
params = readParameters(filename * "_parameters")