include("../ReadWrite.jl")
include("../BasicFunctions.jl")
include("../MIPModels.jl")
using Dates

# Read data 
P = 37
data = read_DR_data(P)
time_limit = 3600
date_today = string(Dates.today())

# Run MIP Baseline
x_MIP, _ = MIPExtended(data, "Gurobi", 1, time_limit, 0)
sol_MIP = MIPtoSol(data, x_MIP)
filename = "results/MIPExtended"
if sol_MIP != 0
    writeSolution(filename, data, sol_MIP)
end

# Print to check that no errors occured
println("--- Script successful! ---")



