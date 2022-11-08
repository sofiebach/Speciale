include("PlotSolution.jl")
include("../Expansion/ReadWrite.jl")
include("../Expansion/ConstructionHeuristics_expanded.jl")
include("../Expansion/ALNS_expanded.jl")
include("../Expansion/MIPModelSpreading.jl")
include("../Expansion/LocalSearch.jl")


P = 37
data = read_DR_data(P)

#sol = randomInitial(data)

sol, params = ALNSExpanded(data, 30, false)


inventory, production = checkSolution(data, sol)

drawHeatmap(inventory, production, data, sol, "hej")

solutionTracking(params, "test")

include("PlotSolution.jl")
probabilityTracking(params, "hej")

include("PlotSolution.jl")
progressDestroyRepair(params)

sol1 = deepcopy(sol)

swapInsert(data,sol1)

#chosenDestroyRepair(params)

drawTVSchedule(data,sol,"hallo")