include("ReadWrite.jl")
include("MIPModelSpreading.jl")
include("MIPModel.jl")
include("ValidateSolution.jl")
include("PlotSolution.jl")

P = 37
data = read_DR_data(P)

#sol = MIP(data, 30, 0, 0)

sol = MIPExpansion(data, 2400, 0, 1)



print_solution(sol)

inventory_used, staff_used = checkSolution(data, sol)

# filename = "output/solution.txt"
# writeSolution(filename, data, sol)
# data, sol = readSolution(filename)

drawTVSchedule(data,sol,"MIP_spread")

drawRadioSchedule(data,sol,"MIP_spred")



#plotScope(data, sol)
used_inv, used_prod = checkSolution(data,sol)
include("PlotSolution.jl")
drawHeatmap(used_inv,used_prod,data,sol,"heatmaps_spread")