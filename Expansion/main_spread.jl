include("../ReadWrite.jl")
include("MIPModelSpreading.jl")
include("../Validation/ValidateSolution.jl")
include("ConstructionHeuristics_expanded.jl")
include("ALNS_expanded.jl")

P = 37
data = read_DR_data(P)

# sol = randomInitial(data)
# println(sol.obj)
# clusterDestroy(data,sol,0.2)
# println(sol.obj)
# regretRepair(data,sol)
# println(sol.obj)

sol, params = ALNS(data, 60)

checkSolution(data, sol)

sol = MIPExpansion(data, 120,0, 1)

checkSolution(data,sol)

println("Objective to compare with meta:")
println(-sum(data.reward.*transpose(sol.x))+sum(sol.k.*data.penalty_S))

print_solution(sol)



