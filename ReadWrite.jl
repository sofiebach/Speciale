using XLSX
using Dates
using Statistics
include("Structures.jl")

function read_DR_data(P)
    population = 5800000
    C = 12
    M = 4 # medias
    L_lower = -2
    L_upper = 5
    Q_lower = -4
    Q_upper = -3
    timeperiod = 52
    T = abs(Q_lower) + timeperiod + L_upper

    data = Instance(P,C,M,timeperiod,L_lower,L_upper,Q_lower,Q_upper,T)
    # Read GRP consumption
    # u[l,p,c] is GRP consumption of priority p on channel c in relative week l-3
    prefix = "Priority "
    for p = 1:data.P
        sheet_name = prefix * string(p)
        consumption = XLSX.readdata("data/data_inventory_consumption.xlsx", sheet_name, "C4:J15")
        consumption = convert(Array{Float64,2}, consumption)
        data.u[:,p,:] = transpose(consumption)
        data.u[:,p,11] = data.u[:,p,11] ./ population # convert impressions to GRP

        for l = 1:(L_upper-L_lower+1)
            if sum(data.u[l,p,:]) > 0
                data.L_l[p] = l-data.L_zero
                break
            end
        end
        for l = (L_upper-L_lower+1):-1:(data.L_l[p]+data.L_zero)
            if sum(data.u[l,p,:]) > 0
                data.L_u[p] = l-data.L_zero
                break
            end
        end

    end

    # Read production hours
    # w[p,m] is weekly production hours of priority p on media m (platforms are TV, RADIO, digital, SOME)
    per_week = data.Q_upper-data.Q_lower+1
    data.w = convert(Array{Float64,2},XLSX.readdata("data/data_staffing_constraint.xlsx", "Producertimer", "D2:G38"))[1:P,:]./per_week

    # Read staffing
    # H[t,m] is weekly staffing (hours) on platform m (medias are TV, RADIO, digital, SOME) at time t
    data.H = transpose(repeat(convert(Array{Float64,2},XLSX.readdata("data/data_staffing_constraint.xlsx", "Bemanding", "E2:E5")),1,data.T))

    # Read scope
    # S[p] is scope for priority p
    data.S = convert(Array{Int64,2}, XLSX.readdata("data/data_staffing_constraint.xlsx", "Scope", "D2:D38"))[1:P]
    data.penalty_S = ones(data.P)./data.S
    for p in data.P_bar 
        data.penalty_S[p] += 1000
    end

    data.F = ones(Float64, data.M)*100
    # Read I
    # [DR1, DR2, Ramasjang, P1, P2, P3, P4, P5, P6, P8, digital, SOME]
    inventory = XLSX.readdata("data/data_lagerestimater.xlsx", "Sheet1", "B2:M53")
    inventory = convert(Array{Float64,2}, coalesce.(inventory, NaN))
    inventory[:,11] = inventory[:,11] / population
    I = fill!(zeros(Float64, data.T, data.C), NaN)
    I[data.start:data.stop, :] = inventory
    posts_per_week = 700.0
    I[:,12] = repeat([posts_per_week], data.T)
    for c = 1:data.C
        avg = mean(filter(!isnan, I[:,c]))
        I[:, c] = replace(I[:, c], NaN => avg)
    end
    data.I = I

    data.aimed_g = ceil.(data.S/data.timeperiod)

    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:D38")[1:data.P,:]
    data.P_names = mapping[:,2]
    data.C_names = XLSX.readdata("data/data_inventory_consumption.xlsx", "Mapping", "B2:B13")[1:data.C]
    data.M_names = XLSX.readdata("data/data_staffing_constraint.xlsx", "Bemanding", "A2:A5")[1:data.M]
    data.BC_names = mapping[:,1]
    data.campaign_type = mapping[:,3]
    data.penalty_g = 1 ./ (data.S .- data.aimed_g)
    replace!(data.penalty_g, Inf => 0)
    data.aimed_L = (data.timeperiod - 1) ./(data.S .- 1)
    replace!(data.aimed_L, Inf => 0)
    data.weight_idle = (data.S .- 1) / (data.timeperiod - 1)
    return data
end

function writeInstance(filename, data)
    outFile = open(filename, "w")
    write(outFile, "timeperiod P M C T\n")
    write(outFile, join([data.timeperiod, data.P, data.M, data.C, data.T]," ")*"\n\n")

    write(outFile, "L_lower L_upper L_zero Q_lower Q_upper\n")
    write(outFile, join([data.L_lower, data.L_upper, data.L_zero, data.Q_lower, data.Q_upper]," ")*"\n\n")
    
    write(outFile, "start stop\n")
    write(outFile, join([data.start, data.stop]," ")*"\n\n")
    
    write(outFile, "P_bar\n")
    write(outFile,join(data.P_bar," ")*"\n\n")

    write(outFile, "S \n")
    write(outFile,join(data.S," ")*"\n\n")
    
    write(outFile, "w\n")
    for m = 1:data.M
        write(outFile,join(data.w[:,m]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "H\n")
    for m = 1:data.M
        write(outFile,join(data.H[:,m]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "I\n")
    for c = 1:data.C
        write(outFile,join(data.I[:,c]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "u\n")
    for c = 1:data.C
        for p=1:data.P
            write(outFile,join(data.u[:,p,c]," ")*"\n")
        end
    end
    write(outFile, "\n")

    write(outFile, "L_l\n")
    write(outFile,join(data.L_l," ")*"\n\n")

    write(outFile, "L_u\n")
    write(outFile,join(data.L_u," ")*"\n\n")

    write(outFile, "penalty_S\n")
    write(outFile,join(data.penalty_S," ")*"\n\n")

    write(outFile, "F\n")
    write(outFile,join(data.F," ")*"\n\n")

    write(outFile, "aimed g\n")
    write(outFile,join(data.aimed_g," ")*"\n\n")

    write(outFile, "P_names\n") 
    write(outFile,join(replace.(data.P_names, " " => "£")," ")*"\n\n")

    write(outFile, "C_names\n")
    write(outFile,join(data.C_names," ")*"\n\n")

    write(outFile, "M_names\n")
    write(outFile,join(data.M_names," ")*"\n\n")

    write(outFile, "BC_names\n") 
    write(outFile,join(replace.(data.BC_names, " " => "£")," ")*"\n\n")

    write(outFile, "campaign_type\n") #skal fikses
    write(outFile,join(replace.(data.campaign_type, " " => "£")," ")*"\n\n")

    write(outFile, "penalty_g\n")
    write(outFile,join(data.penalty_g," ")*"\n\n")

    write(outFile, "aimed_L\n")
    write(outFile,join(data.aimed_L," ")*"\n\n")

    write(outFile, "weight_idle\n")
    write(outFile,join(data.weight_idle," ")*"\n\n")
    close(outFile)
end

function readInstance(filename)
    f = open(filename)
    readline(f) # timeperiod P M C T
    timeperiod, P, M, C, T = parse.(Int,split(readline(f)))
    readline(f) # blank

    readline(f) # L_lower L_upper L_zero Q_lower Q_upper
    L_lower,L_upper, L_zero, Q_lower, Q_upper = parse.(Int,split(readline(f)))
    readline(f) # blank

    data = Instance(P,C,M,timeperiod,L_lower,L_upper,Q_lower,Q_upper,T) 
    
    readline(f) # start, stop
    data.start, data.stop = parse.(Int,split(readline(f)))
    readline(f) # blank

    readline(f) # P_bar
    data.P_bar = parse.(Int,split(readline(f)))
    readline(f) # blank

    readline(f) # S
    data.S = parse.(Int,split(readline(f)))
    readline(f) # blank

    readline(f) # w
    for m = 1:M
        data.w[:,m] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank

    readline(f) # H
    for m = 1:M
        data.H[:,m] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank

    readline(f) # I
    for c = 1:C
        data.I[:,c] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank

    readline(f) # u
    for c = 1:C
        for p = 1:P
            data.u[:,p,c] = parse.(Float64,split(readline(f)))
        end
    end
    readline(f) # blank

    readline(f) # L_l
    data.L_l = parse.(Int,split(readline(f)))
    readline(f) # blank

    readline(f) # L_u
    data.L_u = parse.(Int,split(readline(f)))
    readline(f) # blank

    readline(f) # penalty_S
    data.penalty_S = parse.(Float64,split(readline(f)))
    readline(f) # blank

    readline(f) # F
    data.F = parse.(Float64,split(readline(f)))
    readline(f) # blank

    readline(f) # aimed_g
    data.aimed_g = parse.(Int,split(readline(f)))
    readline(f) # blank

    readline(f) # P_names
    data.P_names = replace.(split(readline(f)), "£" => " ")
    readline(f) # blank

    readline(f) # C_names
    data.C_names = split(readline(f))
    readline(f) # blank

    readline(f) # M_names
    data.M_names = split(readline(f))
    readline(f) # blank

    readline(f) # BC_names
    data.BC_names = replace.(split(readline(f)), "£" => " ")
    readline(f) # blank

    readline(f) # campaign_type
    data.campaign_type = split(readline(f))
    readline(f) # blank

    data.sim = findSimilarity(data)

    readline(f) # penalty_g
    data.penalty_g = parse.(Float64,split(readline(f)))
    readline(f) # blank

    readline(f) # aimed_L
    data.aimed_L = parse.(Float64,split(readline(f)))
    readline(f) # blank

    readline(f) # weight_idle
    data.weight_idle = parse.(Float64,split(readline(f)))
    readline(f) # blank

    return data
end

# Write solution
function writeSolution(filename, data, sol)
    outFile = open(filename, "w")
    write(outFile, "T P M C\n")
    write(outFile, join([data.T, data.P, data.M, data.C]," ")*"\n\n")

    write(outFile, "base obj\n")
    write(outFile, join(sol.base_obj," ")*"\n\n")

    write(outFile, "exp obj\n")
    write(outFile, join(sol.exp_obj," ")*"\n\n")

    write(outFile, "Objective struct\n")
    write(outFile, join([sol.objective.k_penalty, sol.objective.g_penalty, sol.objective.L_penalty]," ")*"\n\n")

    write(outFile, "num campaigns\n")
    write(outFile, join(sol.num_campaigns," ")*"\n\n")

    write(outFile, "x\n")
    for p = 1:sol.P
        write(outFile,join(sol.x[:,p]," ") * "\n")
    end
    write(outFile, "\n")

    write(outFile, "y\n")
    write(outFile,join(sol.y," ") * "\n\n")

    write(outFile, "k\n")
    write(outFile,join(sol.k," ")*"\n\n")

    write(outFile, "f\n")
    for m = 1:sol.M
        write(outFile,join(sol.f[:,m]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "L\n")
    write(outFile, join(sol.L," ")*"\n\n")

    write(outFile, "g\n")
    for p = 1:sol.P
        write(outFile,join(sol.g[:,p]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "I cap\n")
    for c = 1:sol.C
        write(outFile,join(sol.I_cap[:,c]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "H cap\n")
    for m = 1:sol.M
        write(outFile,join(sol.H_cap[:,m]," ")*"\n")
    end
    write(outFile, "\n")

    close(outFile)
end

function readSolution(filename, data)
    f = open(filename)
    readline(f) # T P M
    T, P, M, C = parse.(Int,split(readline(f)))
    readline(f) # blank

    sol = Sol(data)
    readline(f) # baseobj
    sol.base_obj = parse.(Float64, readline(f))
    readline(f) # blank
    readline(f) # exp obj
    sol.exp_obj = parse.(Float64, readline(f))
    readline(f) # blank
    readline(f) # Objective struct
    sol.objective.k_penalty, sol.objective.g_penalty, sol.objective.L_penalty = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # num campaigns
    sol.num_campaigns = parse.(Int64, readline(f))
    readline(f) # blank
    readline(f) # x
    for p in 1:P
        sol.x[:,p] = parse.(Int,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # k
    sol.y = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # k
    sol.k = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # f
    for m = 1:M
        sol.f[:,m] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # L 
    sol.L = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # g 
    for p = 1:P
        sol.g[:,p] = parse.(Int,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # I_cap
    for c = 1:C
        sol.I_cap[:,c] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # H_cap
    for m = 1:M
        sol.H_cap[:,m] = parse.(Float64,split(readline(f)))
    end
    return sol
end

function writeParameters(filename, params)
    outFile = open(filename, "w")
    write(outFile, "prob destroy\n")
    write(outFile, join(params.prob_destroy," ")*"\n\n")

    write(outFile, "prob repair\n")
    write(outFile, join(params.prob_repair," ")*"\n\n")

    write(outFile, "destroys\n")
    write(outFile, join(params.destroys," ")*"\n\n")

    write(outFile, "repairs\n")
    write(outFile, join(params.repairs," ")*"\n\n")

    write(outFile, "current objective\n")
    write(outFile, join(params.current_obj," ")*"\n\n")

    write(outFile, "curent best objective\n")
    write(outFile, join(params.current_best," ")*"\n\n")

    write(outFile, "status\n")
    write(outFile, join(params.status," ")*"\n\n")

    write(outFile, "num destroy\n")
    write(outFile, join(params.num_destroy," ")*"\n\n")

    write(outFile, "num repair\n")
    write(outFile, join(params.num_repair," ")*"\n\n")

    write(outFile, "prob destroy iter\n")
    for i = 1:length(params.num_destroy)
        write(outFile, join(params.prob_destroy_it[i,:]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "prob repair iter\n")
    for i = 1:length(params.num_repair)
        write(outFile, join(params.prob_repair_it[i,:]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "time destroy\n")
    write(outFile, join(params.time_destroy," ")*"\n\n")

    write(outFile, "time repair\n")
    write(outFile, join(params.time_repair," ")*"\n\n")

    write(outFile, "destroy names\n")
    write(outFile, join(params.destroy_names," ")*"\n\n")

    write(outFile, "repair names\n")
    write(outFile, join(params.repair_names," ")*"\n\n")

    write(outFile, "iterations\n")
    write(outFile, join(params.iter," ")*"\n\n")

    write(outFile, "Temperature\n")
    write(outFile, join(params.T_it," ")*"\n\n")

    write(outFile, "W\n")
    write(outFile, join(params.W," ")*"\n\n")
    close(outFile)
end

function readParameters(filename)
    f = open(filename)
    readline(f) # prob_destroy
    prob_destroy = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # prob_repair
    prob_repair = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # destroys
    destroys = parse.(Int64,split(readline(f)))
    readline(f) # blank
    readline(f) # repairs
    repairs = parse.(Int64,split(readline(f)))
    readline(f) # blank
    readline(f) # current objective
    current_obj = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # current best objective
    current_best = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # status
    status = parse.(Int64,split(readline(f)))
    readline(f) # blank
    readline(f) # num destroy
    num_destroy = parse.(Int64,split(readline(f)))
    readline(f) # blank
    readline(f) # num repair
    num_repair = parse.(Int64,split(readline(f)))
    readline(f) # blank
    readline(f) # prob destroy iter
    prob_destroy_it = zeros(Float64, length(num_destroy), length(status))
    for i = 1:length(num_destroy)
        prob_destroy_it[i,:] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # prob repair iter
    prob_repair_it = zeros(Float64, length(num_repair), length(status))
    for i = 1:length(num_repair)
        prob_repair_it[i,:] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # time destroy
    time_destroy = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # time repair
    time_repair = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # destroy names
    destroy_names =  split(readline(f), " ")
    readline(f) # blank
    readline(f) # repair names
    repair_names =  split(readline(f), " ")
    readline(f) # blank
    readline(f) # iterations
    iter = parse(Int64,readline(f))
    readline(f) # blank
    readline(f) # temperature
    T_it = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # W
    W = parse.(Float64,split(readline(f)))
    
    return (prob_destroy=prob_destroy, prob_repair=prob_repair, destroys=destroys, prob_destroy_it = prob_destroy_it,
    prob_repair_it = prob_repair_it, repairs=repairs, current_obj=current_obj, current_best=current_best, status=status, 
    time_repair=time_repair, time_destroy=time_destroy, num_repair=num_repair, num_destroy=num_destroy, 
    destroy_names=destroy_names, repair_names=repair_names, iter = iter, T_it = T_it, W = W)
end

function findSimilarity(data)
    sim = zeros(Float64, data.P, data.P)
    for p1 = 1:(data.P-1)
        for p2 = (p1+1):data.P
            sim_u = pearsonSimilarity(data.u[:,p1,:], data.u[:,p2,:])
            sim_w = pearsonSimilarity(data.w[p1,:], data.w[p2,:])

            sim[p1,p2] = mean([sim_u, sim_w])
            sim[p2,p1] = mean([sim_u, sim_w])
        end 
    end
    return sim
end

function pearsonSimilarity(a, b)
    mu_a =  mean(a)
    mu_b = mean(b)
    t = (sum((a.-mu_a).*(b.-mu_b)))
    n = sqrt(sum((a.-mu_a).^2))*sqrt(sum((b.-mu_b).^2))
    return t/n
end