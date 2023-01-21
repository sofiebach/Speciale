include("../../ReadWrite.jl")
include("../../Validation/PlotSolution.jl")

data = readInstance("dataset/test/100_0_0.txt")

config = "config3"
nummer = "13"

sol = readSolution("ComputationalResults/ALNS/results/" * config * "/100_0_0/solution_" * nummer, data)
params = readParameters("ComputationalResults/ALNS/results/" * config * "/100_0_0/params_" * nummer)
drawTVSchedule(data, sol, "ComputationalResults/ALNS/plots/"*config *"_TVschedule.pdf", 1)

for i = 1:20
    nummer = string(i)
    sol = readSolution("ComputationalResults/ALNS/results/" * config * "/100_0_0/solution_" * nummer, data)
    params = readParameters("ComputationalResults/ALNS/results/" * config * "/100_0_0/params_" * nummer)
    drawTVSchedule(data, sol, "ComputationalResults/ALNS/plots/"*config *"_TVschedule.pdf", 1)
end

start2 = 4750
stop2 = 5450

start1 = 10
stop1 = 10

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


include("../../Validation/PlotSolution.jl")
probabilityTracking(params, "ComputationalResults/ALNS/plots/"* config *"_probabilityzoom_13.png")
plotWparamsInput(params, w_destroy, w_repair, "ComputationalResults/ALNS/plots/"* config *"_bar.pdf")
solutionTracking(params,  "ComputationalResults/ALNS/plots/" *config *"_SA_13.png")



drawTVSchedule(data, sol, "ComputationalResults/ALNS/plots/"*config *"_TVschedule.pdf", 1)
drawRadioSchedule(data, sol, "ComputationalResults/ALNS/plots/"* config *"_Radioschedule.pdf", 4)


sol2 = readSolution("ComputationalResults/MIP/results/100_0_0_extended1thread", data)

drawTVSchedule(data, sol2, "ComputationalResults/ALNS/plots/MIP_TVschedule.pdf", 1)
drawRadioSchedule(data, sol2, "ComputationalResults/ALNS/plots/MIP_Radioschedule.pdf", 4)