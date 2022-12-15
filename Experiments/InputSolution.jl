include("../ALNS.jl")
include("../ReadWrite.jl")
include("../ConstructionHeuristics.jl")

filenames = joinpath.("dataset/train/", readdir("dataset/train/"))
# filenames = filenames[1:1]

type = "extended"
modelRepair = false

avg_objs = zeros(Float64, 3, length(filenames))
avg_stds = zeros(Float64, 3, length(filenames))

idx = 0
for file in filenames
    idx += 1

    data = readInstance(file)
    # time_limit = data.timeperiod
    time_limit = 10
    objs = []
    
    # Input solutions
    empty_sol = Sol(data)
    bad_sol = randomInitial(data)
    # good_sol = MIPBaseline(data, "Gurobi", 1, 60*2)
    
    # Run ALNS on input solutions
    sol1, params1 = ALNS(data, empty_sol, time_limit, type, modelRepair)
    # objs[1, idx] = sol1.exp_obj

    sol2, params2 = ALNS(data, bad_sol, time_limit, type, modelRepair)
    # objs[2, idx] = sol2.exp_obj
end

