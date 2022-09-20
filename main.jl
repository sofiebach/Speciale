include("ReadWrite.jl")
include("MIPModel.jl")
include("ValidateSolution.jl")
include("PlotSolution.jl")
include("DR_output.jl")

P = 29
data = read_DR_data(P)

# Replace with DR inventory and DR scope
I, S = DR_plan()
data.I[data.start:data.stop,:] = I
data.S = S[1:data.P]

sol = MIP(data, 30)

println("DR plans: ", sum(S[1:data.P]))
println("MIP plans: ", sum(sol.x))

print_solution(sol)

checkSolution(data,sol)

#writeSolution(filename, data, sol)

#filename = "output/solution.txt"
#data, sol = readSolution(filename)



drawSolution(data,sol)

drawHeatmap(data,sol)

plotScope(data, sol)

