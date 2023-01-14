include("../../ReadWrite.jl")
include("../../Validation/PlotSolution.jl")

data = readInstance("dataset/test/100_0_0.txt")

sol1 = readSolution("ComputationalResults/MIP/results/100_0_0_baseline4threads", data)
sol2 = readSolution("ComputationalResults/MIP/results/100_0_0_extended4threads", data)

drawTVSchedule(data, sol1, "ComputationalResults/MIP/plots/TV_baseline.pdf", 1)
drawRadioSchedule(data, sol1, "ComputationalResults/MIP/plots/Radio_baseline.pdf", 4)

drawTVSchedule(data, sol2, "ComputationalResults/MIP/plots/TV_extended.pdf", 1)
drawRadioSchedule(data, sol2, "ComputationalResults/MIP/plots/Radio_extended.pdf", 4)


