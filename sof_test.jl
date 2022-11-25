include("ReadWrite.jl")
include("MIPModels.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/25_0_0.txt")

sol = randomInitial(data)
time_limit = 60*5
sol, params = ALNS(data,sol,time_limit,"expanded")

filename = "test"
probabilityTracking(params, filename*"_prob_tracking")

temperatureTracking(params, filename)
