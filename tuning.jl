

function tuneAcceptanceCriteria(data, temperatures, alphas)
    filename = "tuning/T_alpha"
    outFile = open(filename, "w")
    time_limit = 30
    num_iter = 2

    best_obj = Inf
    best_T = 0
    best_alpha = 0
    T_idx = 1
    for T in temperatures
        a_idx = 1
        for alpha in alphas
            println("T: ", T, " alpha: ", alpha)
            objs = 0
            for k = 1:num_iter
                sol, _ = ALNS(data, time_limit, T, alpha)
                objs += sol.obj
            end
            write(outFile, "T, alpha, avg objective\n")
            write(outFile, join([T, alpha, objs/num_iter]," ")*"\n")
            if objs / num_iter < best_obj 
                best_obj = objs / num_iter
                best_T = T
                best_alpha = alpha
            end
            a_idx += 1
        end
        T_idx += 1
    end
    close(outFile)
    return best_T, best_alpha
end

function tuneDestroy(data, cluster, random, worst, related)
    time_limit = 10
    num_iter = 5
    T = 1000
    alpha = 0.99
    
    best_obj = Inf
    best_cluster = 0
    best_random = 0
    best_worst = 0
    best_related = 0

    filename = "tuning/destroy_fracs"
    outFile = open(filename, "w")
    for frac_cluster in cluster, frac_random in random, thres_worst in worst, frac_related in related
        println("cluster: ", frac_cluster)
        println("random: ", frac_random)
        println("worst: ", thres_worst)
        println("related: ", frac_related)
        objs = 0
        for k = 1:num_iter
            sol, _ = ALNS(data, time_limit, T, alpha, frac_cluster, frac_random, thres_worst, frac_related)
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

function readTuneDestroy()
    filename = "tuning/destroy_fracs"
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
    filename = "tuning/T_alpha"
    file = open(filename)

    params = []
    objectives = []

    comment = 1
    for line in eachline(file)
        if comment % 2 == 0
            T, alpha, obj = parse.(Float64, split(line))
            push!(params, [T, alpha])
            push!(objectives, obj)
        end
        comment += 1
    end
    close(file)

    return params, objectives
end

