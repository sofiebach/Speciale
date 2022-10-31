include("ReadWrite.jl")
include("MIPModelSpreading.jl")
include("ValidateSolution.jl")

P = 37
data = read_DR_data(P)

sol = MIPExpansion(data, 120,0, 1)

checkSolution(data,sol)

println("Objective to compare with meta:")
println(-sum(data.reward.*transpose(sol.x))+sum(sol.k.*data.penalty_S))

print_solution(sol)



