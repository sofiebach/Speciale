include("../../ReadWrite.jl")
include("../../Validation/PlotSolution.jl")

data = readInstance("dataset/test/100_0_0.txt")

config = "config5"
nummer = "2"

sol = readSolution("ComputationalResults/ALNS/results/" * config * "/100_0_0/solution_" * nummer, data)
params = readParameters("ComputationalResults/ALNS/results/" * config * "/100_0_0/params_" * nummer)

w_destroy = zeros(Int64,length(params.num_destroy), 3)
w_repair = zeros(Int64,length(params.num_repair), 3)

for i = 1:length(params.status)
    if params.status[i] == params.W[1]
        w_destroy[params.destroys[i], 1] += 1
        w_repair[params.repairs[i], 1] += 1
    end
    if params.status[i] == params.W[2]
        w_destroy[params.destroys[i], 2] += 1
        w_repair[params.repairs[i], 2] += 1
    end
    if params.status[i] == params.W[3]
        w_destroy[params.destroys[i], 3] += 1
        w_repair[params.repairs[i], 3] += 1
    end
end

probabilityTracking(params, "ComputationalResults/ALNS/plots/"* config *"_probability")
plotWparamsInput(params, w_destroy, w_repair, "ComputationalResults/ALNS/plots/"* config *"_bar")
solutionTracking(params,  "ComputationalResults/ALNS/plots/" *config *"_SA")
drawTVSchedule(data, sol, "ComputationalResults/ALNS/plots/"*config *"_TVschedule")
drawRadioSchedule(data, sol, "ComputationalResults/ALNS/plots/"* config *"_Radioschedule")
