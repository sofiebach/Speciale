include("ReadWrite.jl")
include("MIPModel.jl")
include("PlotSolution.jl")

P = 37
data = read_DR_data(P)

sol = MIP(data, 30)

print_solution(sol)

