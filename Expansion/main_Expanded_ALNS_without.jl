include("../ReadWrite.jl")
include("../ALNS.jl")

data = readInstance("dataset/100_0_0.txt")
time_limit = 120

# Run ALNS without modelRepair
type = "expanded"
modelrepair = false
sol, params = ALNS(data, time_limit, type, modelrepair)
filename = "results/ALNS_" * type * "_" * string(modelrepair)
writeSolution(filename, data, sol)
writeParameters(filename * "_parameters", params) 

# Print to check that no errors occured
println("--- Script successful! ---")



