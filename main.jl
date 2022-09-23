include("ReadWrite.jl")
include("MIPModel.jl")
include("ValidateSolution.jl")
include("PlotSolution.jl")
#include("DR_output.jl")

P = 37
data = read_DR_data(P)

# Replace with DR inventory and DR scope
#I, S = DR_plan()
#data.I[data.start:data.stop,:] = I
#data.S = S[1:data.P]

sol = MIP(data, 60)

#println("DR plans: ", sum(S[1:data.P]))
#println("MIP plans: ", sum(sol.x))

print_solution(sol)

checkSolution(data,sol)



filename = "output/solution.txt"
#writeSolution(filename, data, sol)
data, sol = readSolution(filename)



drawSolution(data,sol)

include("PlotSolution.jl")
drawHeatmap(data,sol)

#plotScope(data, sol)

