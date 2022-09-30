include("ReadWrite.jl")
include("MIPModel.jl")
include("MIP2.jl")
include("ValidateSolution.jl")
include("PlotSolution.jl")

P = 37
data = read_DR_data(P)

sol = MIP2(data, 60)

print_solution(sol)

inventory_used, staff_used = checkSolution(data, sol)

# filename = "output/solution.txt"
# writeSolution(filename, data, sol)
# data, sol = readSolution(filename)

drawTVSchedule(data,sol,"MIP2")

drawRadioSchedule(data,sol,"MIP2")

drawHeatmap(inventory_used, staff_used, data, "MIP2")

#plotScope(data, sol)
