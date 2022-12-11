include("PlotSolution.jl")
include("../ReadWrite.jl")

data = readInstance("dataset/100_0_0.txt")

model = "ALNS"
type = "extended"
modelrepair = "false"
prefix = "results/"
filename = model*"_"*type*"_"*modelrepair
sol = readSolution(prefix * filename, data)
params = readParameters(prefix * filename*"_parameters")

solutionTracking_all(params, filename*"_sol_tracking")

probabilityTracking(params, filename*"_prob_tracking")
   
temperatureTracking(params, filename*"temp_tracking")

drawTVSchedule(data,sol,"hej")