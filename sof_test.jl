include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")
include("Validation/ValidateSolution.jl")

data = readInstance("dataset/train/25_0_0.txt")

sol = randomInitial(data)
sol, params = ALNS(data,sol,120,"extended",false)


drawTVSchedule(data,sol,"tv")
drawRadioSchedule(data,sol,"radio")
probabilityTracking(params, "prob")
solutionTracking(params, "sol")
