include("../ReadWrite.jl")
include("ALNS.jl")
using Dates

P = 37
data = read_DR_data(P)
timelimit = 30
modelRepair = true
sol, params = ALNSBaseline(data, timelimit, modelRepair)



date_today = string(Dates.today())
filename = "results/ALNS_" * string(timelimit) * "_" * date_today
writeSolution(filename, data, sol)
writeParameters(filename * "_parameters", params) 

sol1 = readSolution(filename)
params = readParameters(filename * "_parameters")