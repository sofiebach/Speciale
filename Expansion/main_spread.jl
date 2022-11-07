include("../Expansion/ReadWrite.jl")
include("../Validation/ValidateSolution.jl")
include("ALNS_expanded.jl")

P = 37
data = read_DR_data(P)

time_limit = 180
modelRepair = false
sol, params = ALNSExpanded(data, time_limit, modelRepair)

checkSolution(data, sol)

sol = MIPExpansion(data, 120,0, 1)

checkSolution(data,sol)

println("Objective to compare with meta:")
println(-sum(data.reward.*transpose(sol.x))+sum(sol.k.*data.penalty_S))

print_solution(sol)



