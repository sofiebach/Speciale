include("../../ReadWrite.jl")
include("ALNS_tunedestroy.jl")

using Statistics

function tune(horizontalDestroy,verticalDestroy,randomDestroy,relatedDestroy,worstIdleDestroy,stackDestroy,filepath) 
    N = 5
    data_idx = 0
    N_values = 5
    averages = zeros(Float64,N_values)
    stds = zeros(Float64,N_values)
    data_idx += 1
    data = readInstance(filepath)
    # time_limit = data.timeperiod * 60
    time_limit = 3 * 60
    init_sol = []
    for i = 1:N 
        push!(init_sol, randomInitial(data))
    end
    value_idx = 0
    for horizontalfrac in horizontalDestroy, verticalfrac in verticalDestroy, randomfrac in randomDestroy, relatedfrac in relatedDestroy, idlefrac in worstIdleDestroy, stackfrac in stackDestroy
        value_idx += 1
        gap = []
        destroy_frac = [horizontalfrac, verticalfrac, randomfrac, relatedfrac, idlefrac, stackfrac]
        for n = 1:N
            sol, _ = ALNS(data,init_sol[n],time_limit,"extended",false,destroy_frac)
            append!(gap,(init_sol[n].exp_obj - sol.exp_obj)/init_sol[n].exp_obj)
        end
        stds[value_idx] = std(gap)
        averages[value_idx] = mean(gap)
    end
    return stds, averages
end


function write_tuning(filename, stds, averages)
    outFile = open(filename, "w")
    write(outFile, "horizontalDestroy\n")
    write(outFile,join(horizontalDestroy," ")*"\n\n")
    write(outFile, "verticalDestroy\n")
    write(outFile,join(verticalDestroy," ")*"\n\n")
    write(outFile, "randomDestroy\n")
    write(outFile,join(randomDestroy," ")*"\n\n")
    write(outFile, "relatedDestroy\n")
    write(outFile,join(relatedDestroy," ")*"\n\n")
    write(outFile, "worstIdleDestroy\n")
    write(outFile,join(worstIdleDestroy," ")*"\n\n")
    write(outFile, "stackDestroy\n")
    write(outFile,join(stackDestroy," ")*"\n\n")

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