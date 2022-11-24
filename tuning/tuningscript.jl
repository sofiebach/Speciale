include("../ReadWrite.jl")
include("../ALNS.jl")

using Statistics

function tune(thetas,alphas,Ws,gammas,destroy_fracs,segment_sizes,long_term_updates) 
    size = [0,5,10,15]
    time_limit = 60*10
    N = 3
    data_idx = 0
    N_values = 5
    N_dataset = 7
    averages = zeros(Float64,N_dataset,N_values)
    stds = zeros(Float64,N_dataset,N_values)
    for i in size
        data_idx += 1
        filename = "../dataset/25_"*string(i)*"_0.txt"
        data = readInstance(filename)
        init_sol = randomInitial(data)
        value_idx = 0
        for theta in thetas, alpha in alphas, W in Ws, gamma in gammas, destroy_frac in destroy_fracs, segment_size in segment_sizes, long_term_update in long_term_updates
            value_idx += 1
            gap = []
            for n = 1:N
                sol, _ = ALNS(data,init_sol,time_limit,"expanded",false,theta,alpha,W,gamma,destroy_frac,segment_size,long_term_update)
                append!(gap,(init_sol.exp_obj - sol.exp_obj)/init_sol.exp_obj)
            end
            stds[data_idx, value_idx] = std(gap)
            averages[data_idx, value_idx] = mean(gap)
        end
    end
    for i in size[2:end]
        data_idx += 1
        filename = "../dataset/25_0_"*string(i)*".txt"
        data = readInstance(filename)
        init_sol = randomInitial(data)
        value_idx = 0
        for theta in thetas, alpha in alphas, W in Ws, gamma in gammas, destroy_frac in destroy_fracs, segment_size in segment_sizes, long_term_update in long_term_updates
            value_idx += 1
            gap = []
            for n = 1:N
                sol, _ = ALNS(data,init_sol,time_limit,"expanded",false,theta,alpha,W,gamma,destroy_frac,segment_size,long_term_update)
                append!(gap,(init_sol.exp_obj - sol.exp_obj)/init_sol.exp_obj)
            end
            stds[data_idx, value_idx] = std(gap)
            averages[data_idx, value_idx] = mean(gap)       
        end
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

    #write(outFile, "Standard deviations\n")
    #for i = 1:5
    #    write(outFile,join(stds[:,i]," ")*"\n")
    #end
    #write(outFile, "\n")
    #write(outFile, "Average\n")
    #for i = 1:5
    #    write(outFile,join(averages[:,i]," ")*"\n")
    #end
    #write(outFile, "\n")

    close(outFile)
end