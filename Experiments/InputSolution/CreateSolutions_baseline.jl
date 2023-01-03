include("../../ALNS.jl")
include("../../ReadWrite.jl")
include("../../ConstructionHeuristics.jl")

filepath = joinpath.("dataset/train/", readdir("dataset/train/"))

for file in filepath
    filename = split(split(file, ".")[1],"/")[3]

    data = readInstance(file)

    # Input solutions
    empty_sol = Sol(data)
    good_obj = Inf
    good_sol = 0
    bad_obj = -Inf
    bad_sol = 0
    for n = 1:1000
        temp_sol = randomInitial(data)
        if temp_sol.base_obj < good_obj 
            good_obj = temp_sol.base_obj
            good_sol = deepcopy(temp_sol)
        end 
        if temp_sol.base_obj > bad_obj 
            bad_obj = temp_sol.base_obj
            bad_sol = deepcopy(temp_sol)
        end
    end

    

    folder = "Experiments/InputSolution/initials/base/"
    writeSolution(folder*filename*"_empty", data, empty_sol)
    writeSolution(folder*filename*"_good", data, good_sol)
    writeSolution(folder*filename*"_bad", data, bad_sol)
end