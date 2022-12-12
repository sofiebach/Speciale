include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")
include("Validation/ValidateSolution.jl")

data = readInstance("dataset/100_0_0.txt")

x = MIPExtended(data,"Gurobi")
sol = MIPtoSol(data,x)

sol = randomInitial(data)
# sol, params = ALNS(data,sol,60,"extended",false)
println(sol.exp_obj)
horizontalDestroy!(data,sol,0.2)
println(sol.exp_obj)
horizontalModelRepair(data,sol,"extended")
println(sol.exp_obj)

modelRepair!(data,sol,"extended")
checkSolution(data,sol)

# drawTVSchedule(data,sol,"tv2")
# drawRadioSchedule(data,sol,"radio2")
probabilityTracking(params, "prob")
solutionTracking(params, "sol")

randomDestroy!(data,sol,0.4)
regretRepair!(data,sol,"extended")