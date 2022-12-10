include("../ReadWrite.jl")
include("../ALNS.jl")

# Read data 
data = readInstance("dataset/100_0_0.txt")

# Run ALNS without modelRepair
time_limit = 60
type = "extended"
modelrepair = true
sol, params = ALNS(data, time_limit, type, modelrepair)
filename = "results/ALNS_" * type * "_" * string(modelrepair)
writeSolution(filename, data, sol)
writeParameters(filename * "_parameters", params) 

# Print to check that no errors occured
println("--- Script successful! ---")



