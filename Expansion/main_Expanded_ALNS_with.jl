include("../ReadWrite.jl")
include("../ALNS.jl")

# Read data 
P = 37
data = read_DR_data(P)
time_limit = 60

# Run ALNS without modelRepair
type = "expanded"
modelrepair = false
sol, params = ALNS(data, time_limit, type, modelrepair)
filename = "results/ALNS_" * type * "_" * string(modelrepair)
writeSolution(filename, data, sol)
writeParameters(filename * "_parameters", params) 

# Print to check that no errors occured
println("--- Script successful! ---")


randomDestroy!(data, sol, 0.2)

spreadModelRepair!(data, sol, type)



