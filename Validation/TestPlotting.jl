include("PlotSolution.jl")
include("../ReadWrite.jl")
include("../ConstructionHeuristics.jl")
include("ValidateSolution.jl")

include("../ALNS.jl")
include("../MIPModels.jl")



P = 37
data = read_DR_data(P)

sol = randomInitial(data)

sol, params = ALNS(data, 120, "expanded", false, 10000, 0.995)


inventory, production = checkSolution(data, sol)

drawHeatmap(inventory, production, data, sol, "hej")

include("PlotSolution.jl")
solutionTracking_all(params, "test3")

temperatureTracking(params, "temp_check")


include("PlotSolution.jl")

probabilityTracking(params, "hej")

sol1 = deepcopy(sol)

swapInsert(data,sol1)

#chosenDestroyRepair(params)

drawTVSchedule(data,sol,"hallo")