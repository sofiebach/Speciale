include("PlotSolution.jl")
include("../ReadWrite.jl")

P = 37
data = read_DR_data(P)

model = "ALNS"
type = "baseline"
modelrepair = "false"
filename = "results/"*model*"_"*type*"_"*modelrepair
sol = readSolution(filename)
params = readParameters(filename*"_parameters")

solutionTracking_all(params, "test3")

temperatureTracking(params, "temp_check")


include("PlotSolution.jl")

probabilityTracking(params, "hej")

sol1 = deepcopy(sol)

swapInsert(data,sol1)


drawTVSchedule(data,sol,"hallo")