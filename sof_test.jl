include("ReadWrite.jl")
include("MIPModels.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/100_0_0.txt")

sol = randomInitial(data)
time_limit = 60
sol, params = ALNS(data,sol,time_limit,"expanded",false)
probabilityTracking(params, "prob")
solutionTracking_all(params, "sol")
temperatureTracking(params, "temp")

temperatureTracking(params, filename)

x = MIPBaseline(data, "Gurobi", 1, time_limit, 0)

sol = MIPtoSol(data, x)
