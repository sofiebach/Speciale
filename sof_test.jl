include("ReadWrite.jl")
include("MIPModels.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/25_0_0.txt")

x = MIPExtended(data,"Gurobi")
sol = MIPtoSol(data,x)

sol, params = ALNS(data,sol,60,"extended",false)

drawTVSchedule(data,sol,"tv2")
drawRadioSchedule(data,sol,"radio2")
probabilityTracking(params, "prob2")
solutionTracking(params, "sol2")

randomDestroy!(data,sol,0.4)
regretRepair!(data,sol,"extended")