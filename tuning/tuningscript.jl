include("../ReadWrite.jl")
include("../ALNS.jl")

using Statistics

function tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates,filepath,filename) 
    N = 5
    data_idx = 0
    N_values = 5
    averages = zeros(Float64,N_values)
    stds = zeros(Float64,N_values)
    data_idx += 1
    data = readInstance(filepath)
    time_limit = data.timeperiod * 60 
    init_sol = randomInitial(data)
    value_idx = 0
    for theta in thetas, alpha in alphas, W in Ws, gamma in gammas, destroy_frac in destroy_fracs, segment_size in segment_sizes, long_term_update in long_term_updates
        value_idx += 1
        gap = []
        for n = 1:N
            sol, _ = ALNS(data,init_sol,time_limit,"extended",false,theta,alpha,W,gamma,destroy_frac,segment_size,long_term_update)
            append!(gap,(init_sol.exp_obj - sol.exp_obj)/init_sol.exp_obj)
        end
        stds[value_idx] = std(gap)
        averages[value_idx] = mean(gap)
    end
    return stds, averages
end


function write_tuning(filename)
    outFile = open(filename, "w")
    write(outFile, "Tuning parameter: W\n\n")

    write(outFile, "thetas\n")
    write(outFile,join(thetas," ")*"\n\n")
    write(outFile, "alphas\n")
    write(outFile,join(alphas," ")*"\n\n")
    write(outFile, "Ws\n")
    for i = 1:length(Ws)
        write(outFile,join(Ws[i]," ")*"\n")
    end
    write(outFile, "\n")
    write(outFile, "gammas\n")
    write(outFile,join(gammas," ")*"\n\n")
    write(outFile, "destroy_fracs\n")
    write(outFile,join(destroy_fracs," ")*"\n\n")
    write(outFile, "segment_sizes\n")
    write(outFile,join(segment_sizes," ")*"\n\n")
    write(outFile, "long_term_update\n")
    write(outFile,join(long_term_updates," ")*"\n\n")

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