include("../Baseline/ALNS.jl")
include("../Baseline/ConstructionHeuristics.jl")

function tuneAcceptanceCriteria(data, temperatures, alphas, gammas)
    filename = "results/acceptanceCriteria"
    outFile = open(filename, "w")
    time_limit = 60
    num_iter = 5
    println("Will run for ", length(temperatures)*length(alphas)*length(gammas)*time_limit*num_iter/60/60, " hours.")

    best_obj = Inf
    best_T = 0
    best_alpha = 0
    best_gamma = 0
    for T in temperatures, alpha in alphas, gamma in gammas
        println("T: ", T, " alpha: ", alpha, "gamma: ", gamma)
        objs = 0
        for k = 1:num_iter
            sol, _ = ALNS_uden_modelRepair(data,time_limit,T,alpha,gamma)
            objs += sol.obj
        end
        write(outFile, "T, alpha, gamma, avg objective\n")
        write(outFile, join([T, alpha, gamma, objs/num_iter]," ")*"\n")
        if objs / num_iter < best_obj 
            best_obj = objs / num_iter
            best_T = T
            best_alpha = alpha
            best_gamma = gamma
        end
    end
    close(outFile)
    return best_T, best_alpha, best_gamma
end

function tuneDestroy(data, cluster, random, worst, related, filename)
    time_limit = 60
    num_iter = 5
    println("Will run for ", length(cluster)*length(random)*length(worst)*length(related)*time_limit*num_iter/60/60, " hours.")

    T = 1000
    alpha = 0.9
    gamma = 0.9
    
    best_obj = Inf
    best_cluster = 0
    best_random = 0
    best_worst = 0
    best_related = 0

    outFile = open(filename, "w")
    for frac_cluster in cluster, frac_random in random, thres_worst in worst, frac_related in related
        println("cluster: ", frac_cluster)
        println("random: ", frac_random)
        println("worst: ", thres_worst)
        println("related: ", frac_related)
        objs = 0
        for k = 1:num_iter
            sol, _ = ALNS_uden_modelRepair(data, time_limit, T, alpha, gamma, frac_cluster, frac_random, thres_worst, frac_related)
            objs += sol.obj
        end
        write(outFile, "cluster, random, worst, related, avg objective\n")
        write(outFile, join([frac_cluster, frac_random, thres_worst, frac_related, objs/num_iter]," ")*"\n")
        if objs / num_iter < best_obj 
            best_obj = objs / num_iter
            best_cluster = frac_cluster
            best_random = frac_random
            best_worst = thres_worst
            best_related = frac_related
        end
    end
    close(outFile)
    return best_cluster, best_random, best_worst, best_related
end

function readTuneDestroy(filename)
    file = open(filename)

    params = []
    objectives = []

    comment = 1
    for line in eachline(file)
        if comment % 2 == 0
            frac_cluster, frac_random, thres_worst, frac_related, obj = parse.(Float64, split(line))
            push!(params, [frac_cluster, frac_random, thres_worst, frac_related])
            push!(objectives, obj)
        end
        comment += 1
    end
    close(file)

    return params, objectives
end

function readTuneAcceptance()
    filename = "results/acceptanceCriteria"
    file = open(filename)

    params = []
    objectives = []

    comment = 1
    for line in eachline(file)
        if comment % 2 == 0
            T, alpha, gamma, obj = parse.(Float64, split(line))
            push!(params, [T, alpha, gamma])
            push!(objectives, obj)
        end
        comment += 1
    end
    close(file)

    return params, objectives
end

