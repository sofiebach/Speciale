include("PlotSolution.jl")
include("../Expansion/ReadWrite.jl")
include("../Expansion/ConstructionHeuristics_expanded.jl")
include("../Expansion/ALNS_expanded.jl")
include("../Expansion/MIPModelSpreading.jl")
include("../Expansion/LocalSearch.jl")

profile 


P = 37
data = read_DR_data(P)

#sol = randomInitial(data)

sol, params = ALNS_uden_modelrepair(data, 120)

inv, prod = checkSolution(data, sol)

drawHeatmap(inv, prod, data, sol, "hej")

simulatedAnnealingPlot(params)

include("PlotSolution.jl")
progressDestroyRepair(params)

sol1 = deepcopy(sol)

swapInsert(data,sol1)

#chosenDestroyRepair(params)