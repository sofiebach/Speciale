include("../../ALNS.jl")
include("../../ReadWrite.jl")
include("../../ConstructionHeuristics.jl")

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))

for file in filepath
    filename = split(split(file, ".")[1],"/")[3]

    data = readInstance(file)
    sol = randomInitial(data)

    folder = "Experiments/DestroyRepair/initials/"
    writeSolution(folder*filename, data, sol)
end