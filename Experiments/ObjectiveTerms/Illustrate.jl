include("../../ReadWrite.jl")
include("../../Validation/PlotSolution.jl")

filepath = joinpath.("Experiments/ObjectiveTerms/results/", readdir("Experiments/ObjectiveTerms/results/"))

for file in filepath
    prefix = "Experiments/ObjectiveTerms/"
    filename = split(split(file, ".")[1],"/")[4]
    len = length(filename) - 5
    data = readInstance("dataset/train/"*filename[1:len]*".txt")
    sol = readSolution(file, data)
    drawTVSchedule(data, sol, prefix*filename*"_TV",1)
    drawRadioSchedule(data, sol, prefix*filename*"_Radio",7)
end
