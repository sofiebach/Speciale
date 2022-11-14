include("PlotSolution.jl")
include("../ReadWrite.jl")

P = 37
data = read_DR_data(P)

model = "ALNS"
type = "baseline"
modelrepair = "false"
prefix = "results/"
filename = model*"_"*type*"_"*modelrepair
sol = readSolution(prefix * filename, data)
params = readParameters(prefix * filename*"_parameters")

solutionTracking_all(params, filename*"_sol_tracking")

probabilityTracking(params, filename*"_prob_tracking")
   
temperatureTracking(params, filename*"temp_tracking")