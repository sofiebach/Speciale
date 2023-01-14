include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/train/100_5_0.txt")
sol = randomInitial(data)
sol,params = ALNS(data,sol,60,"extended")
drawHeatmap(data,sol,"heatmap_example.pdf")

