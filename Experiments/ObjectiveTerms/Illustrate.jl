include("../../ReadWrite.jl")
include("../../Validation/PlotSolution.jl")

filepath = joinpath.("Experiments/ObjectiveTerms/results", readdir("Experiments/ObjectiveTerms/results"))

for file in filepath
    prefix = "Experiments/ObjectiveTerms/"
    filename = split(split(file, ".")[1],"/")[4]
    data = readInstance("dataset/train/"*filename[1:8]*".txt")
    sol = readSolution(file, data)
    drawTVSchedule(data, sol, prefix*filename)
end

