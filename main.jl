include("ReadWrite.jl")
include("MIPModel.jl")
include("ValidateSolution.jl")
include("PlotSolution.jl")

data = read_DR_data()

sol = MIP(data, 30)

print_solution(sol)

checkSolution(data,sol)

#filename = "output/solution.txt"
#writeSolution(filename, data, sol)
#data, sol = readSolution(filename)

drawSolution(data,sol)

drawHeatmap(data,sol)