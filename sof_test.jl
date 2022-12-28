include("ReadWrite.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")
include("Validation/ValidateSolution.jl")

data = readInstance("dataset/train/25_0_0.txt")
sol1 = randomInitial(data)
time_limit = 60

theta=0.2
alpha=0.99975
W=[10,5,1]
gamma=0.9
destroy_frac=0.05
segment_size=50
long_term_update=0.05
sol, params = ALNS(data,sol1,time_limit,"extended",false,theta,alpha,W,gamma,destroy_frac,segment_size,long_term_update)

destroy_frac=0.4
sol2, params2 = ALNS(data,sol1,time_limit,"extended",false,theta,alpha,W,gamma,destroy_frac,segment_size,long_term_update)

probabilityTracking(params, "test1")


probabilityTracking(params2, "test2")

