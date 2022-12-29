include("../../ReadWrite.jl")
include("ALNS_tunedestroy.jl")

using Statistics

function tune(destroy_method,destroy_fracs,filepath) 
    N = 5
    data_idx = 0
    N_values = 5
    averages = zeros(Float64,N_values)
    stds = zeros(Float64,N_values)
    data_idx += 1
    data = readInstance(filepath)
    time_limit = 3 * 60
    init_sol = []
    for i = 1:N 
        push!(init_sol, randomInitial(data))
    end
    value_idx = 0
    for destroy_frac in destroy_fracs
        value_idx += 1
        gap = []
        for n = 1:N
            sol, _ = ALNS(data,init_sol[n],time_limit,destroy_method,"extended",false,destroy_frac)
            append!(gap,(init_sol[n].exp_obj - sol.exp_obj)/init_sol[n].exp_obj)
        end
        stds[value_idx] = std(gap)
        averages[value_idx] = mean(gap)
    end
    return stds, averages
end


function write_tuning(filename, destroy_method, destroy_fracs, stds, averages)
    outFile = open(filename, "w")
    write(outFile, "destroy_method\n")
    write(outFile,string(destroy_method)*"\n\n")
    write(outFile, "destroy_fracs\n")
    write(outFile,join(destroy_fracs," ")*"\n\n")

    write(outFile, "Standard deviations\n")
        write(outFile,join(stds," ")*"\n")
    write(outFile, "\n")
    write(outFile, "Average\n")
        write(outFile,join(averages," ")*"\n")
    write(outFile, "\n")

    close(outFile)
end

function read_parameters()
    f = open("parameter_values")
    readline(f)
    theta = parse.(Float64, readline(f))
    readline(f)
    alpha = parse.(Float64, readline(f))
    readline(f)
    W = parse.(Int64, split(readline(f)))
    readline(f)
    gamma = parse.(Float64, readline(f))
    readline(f)
    frac = parse.(Float64, readline(f))
    readline(f)
    segment = parse.(Float64, readline(f))
    readline(f)
    LTU = parse.(Float64, readline(f))
    return theta, alpha, W, gamma, frac, segment, LTU
end

function read_ranges(parameter)
    f = open("parameter_ranges")
    readline(f)
    theta = parse.(Float64,  split(readline(f)))
    readline(f)
    alpha = parse.(Float64,  split(readline(f)))
    readline(f)
    W = []
    for i = 1:5
        push!(W, parse.(Int64, split(readline(f), " ")))
    end
    readline(f)
    gamma = parse.(Float64, split(readline(f)))
    readline(f)
    frac = parse.(Float64, split(readline(f)))
    readline(f)
    segment = parse.(Float64, split(readline(f)))
    readline(f)
    LTU = parse.(Float64, split(readline(f)))
    if parameter == "theta"
        return theta
    elseif parameter == "alpha"
        return alpha
    elseif parameter == "W"
        return W
    elseif parameter == "gamma"
        return gamma
    elseif parameter == "frac"
        return frac
    elseif parameter == "segment"
        return segment
    else
        return LTU
    end
end