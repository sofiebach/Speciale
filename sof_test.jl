include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/train/100_5_0.txt")
sol = randomInitial(data)
time_limit=60
sol, params = ALNS(data, sol, time_limit, "extended")

solutionTracking_all(params, "sof_test")
