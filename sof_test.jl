include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")
include("Validation/ValidateSolution.jl")

data = readInstance("dataset/test/100_0_0.txt")
data.I = 10000*ones(data.T, data.C)
data.H = 10000*ones(data.T, data.M)

x = MIPExtended(data, "Gurobi", 1, 60*5)

sol = MIPtoSol(data, x)

sol = randomInitial(data)
sol, params = ALNS(data,sol,60,"extended",false)

drawTVSchedule(data, sol, "perfect_TV")
drawRadioSchedule(data, sol, "perfect_Radio")

drawHeatmap(sol.I_cap, sol.H_cap, data, sol, "test")

