include("ReadWrite.jl")
include("MIPModel.jl")
include("ValidateSolution.jl")
include("PlotSolution.jl")

P = 37
data = read_DR_data(P)

sol = MIP(data, 60)

print_solution(sol)

inventory_used, staff_used = checkSolution(data, sol)

# filename = "output/solution.txt"
# writeSolution(filename, data, sol)
# data, sol = readSolution(filename)

drawTVSchedule(data,sol,"test")

drawRadioSchedule(data,sol,"test")

drawHeatmap(inventory_used, staff_used, data, "mip_distributed")

#plotScope(data, sol)
