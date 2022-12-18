include("../../ReadWrite.jl")
include("../../Validation/PlotSolution.jl")

filepath = joinpath.("Experiments/ObjectiveTerms/results", readdir("Experiments/ObjectiveTerms/results"))[5:8]

for file in filepath
    prefix = "Experiments/ObjectiveTerms/"
    filename = split(split(file, ".")[1],"/")[4]
    data = readInstance("dataset/train/"*filename[1:6]*".txt")
    sol = readSolution(file, data)
    drawTVSchedule(data, sol, prefix*filename)
end

