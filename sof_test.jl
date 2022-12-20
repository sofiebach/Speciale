include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")
include("Validation/ValidateSolution.jl")

data = readInstance("dataset/train/25_0_0.txt")

sol = randomInitial(data)
sol, params = ALNS(data,sol,30,"extended",false)

drawTVSchedule(data, sol, "perfect_TV")
drawRadioSchedule(data, sol, "perfect_Radio")

drawHeatmap(data, sol, "test")

sol = Sol(data)
insert!(data,sol,5,1)
insert!(data,sol,10,1)
