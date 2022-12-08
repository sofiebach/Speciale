include("ReadWrite.jl")
include("MIPModels.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/100_0_0.txt")

sol = randomInitial(data)
sol, params = ALNS(data,sol,120,"baseline",true)

drawTVSchedule(data,sol,"tv")
drawRadioSchedule(data,sol,"radio")
probabilityTracking(params, "prob")
solutionTracking(params, "sol")

