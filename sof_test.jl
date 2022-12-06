include("ReadWrite.jl")
include("MIPModels.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/25_0_0.txt")

sol = randomInitial(data)
time_limit = 60
sol, params = ALNS(data,sol,time_limit,"expanded")
probabilityTracking(params, "prob")
solutionTracking_all(params, "sol")
temperatureTracking(params, "temp")

temperatureTracking(params, filename)
