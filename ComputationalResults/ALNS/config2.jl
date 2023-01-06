include("../../ReadWrite.jl")
include("../../ALNS.jl")



function dummyfunction()
    idx = parse(Int64, ENV["LSB_JOBINDEX"])
    #idx = 4

    configuration = "config2/"

    filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
    filename = split(split(filepath, ".")[1],"/")[3]
    folder = "ComputationalResults/ALNS/results/"
    data = readInstance(filepath)

    timelimit = data.timeperiod*60
    #timelimit = 5
    best_i = 0
    best_obj = 1000

    N = 20
    #N = 3
    for i = 1:N
        sol = randomInitial(data)
        sol, params = ALNS_final(data, sol, timelimit, "extended", [false,false,false,true,true,false,false],[true,false,true,false,false,false])
        if sol.exp_obj < best_obj
            best_obj = sol.exp_obj
            best_i = i
        end
        writeSolution(folder * configuration * filename * "/solution_" * string(i), data, sol)
        writeParameters(folder * configuration * filename * "/params_" * string(i), params)
    end

    println("---- best i is " * string(best_i)* " ----")
end

dummyfunction()