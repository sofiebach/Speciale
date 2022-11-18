include("../ReadWrite.jl")
include("../ALNS.jl")

# Read data 
P = 37
data = read_DR_data(P)
time_limit = 3600

# Run ALNS without modelRepair
type = "baseline"
modelrepair = false
sol, params = ALNS(data, time_limit, type, modelrepair,100)
filename = "results/ALNS_" * type * "_" * string(modelrepair)
writeSolution(filename, data, sol)
writeParameters(filename * "_parameters", params) 

# Print to check that no errors occured
println("--- Script successful! ---")



