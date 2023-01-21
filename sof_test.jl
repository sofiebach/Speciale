include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/test/100_0_0.txt")
sol = randomInitial(data)


sol, params = ALNS_final(data, sol, 300, "extended", [false,false,false,true,true,false,false],[true,false,true,false,false,false])

probabilityTracking(params, "TEST.png")