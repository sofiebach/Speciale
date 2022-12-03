include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("HeuristicFunctions.jl")

data = readInstance("dataset/100_0_0.txt")

sol = randomInitial(data)

println(sol.exp_obj)
randomDestroy!(data,sol,0.2)
println(sol.exp_obj)
flexibilityRepair!(data,sol,"expanded")
println(sol.exp_obj)