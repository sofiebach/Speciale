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
