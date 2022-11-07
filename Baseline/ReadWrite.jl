using XLSX
using Dates
using Statistics
include("../Structures.jl")

function read_DR_data(P)
    population = 5800000
    C = 12
    M = 4 # medias
    L_lower = -2
    L_upper = 5
    Q_lower = -4
    Q_upper = -3
    timeperiod = 53
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

        # penalty for priority
        data.penalty_S[p] = sum(data.u[:,p,:])

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

    # Read I
    # [DR1, DR2, Ramasjang, P1, P2, P3, P4, P5, P6, P8, digital, SOME]
    inventory = XLSX.readdata("data/data_lagerestimater.xlsx", "Sheet1", "B2:M54")
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

    # Penalty for freelance hours (can be modified)
    for m = 1:data.M
        data.penalty_f[m] = 0.001
        data.F[m] = 100   
    end
    # reward for Priority
    data.reward = (data.penalty_S.-minimum(data.penalty_S).+1)./(maximum(data.penalty_S)-minimum(data.penalty_S))

    data.aimed = ceil.(data.S/data.T)
    return data
end

# Write solution
function writeSolution(filename, data, sol)
    outFile = open(filename, "w")
    write(outFile, "T P M\n")
    write(outFile, join([data.T, data.P, data.M]," ")*"\n\n")

    write(outFile, "obj\n")
    write(outFile, join(sol.obj," ")*"\n\n")

    write(outFile, "x\n")
    for p = 1:sol.P
        write(outFile,join(sol.x[:,p]," ") * "\n")
    end
    write(outFile, "\n")

    write(outFile, "k\n")
    write(outFile,join(sol.k," ")*"\n\n")

    write(outFile, "f\n")
    for m = 1:sol.M
        write(outFile,join(sol.f[:,m]," ")*"\n")
    end
    close(outFile)
end

function readSolution(filename)
    f = open(filename)
    readline(f) # T P M
    T, P, M = parse.(Int,split(readline(f)))
    readline(f) # blank

    sol = Sol(T,P,M)
    readline(f) # obj
    sol.obj = parse.(Float64, readline(f))
    readline(f) # blank
    readline(f) # x
    for p in 1:P
        sol.x[:,p] = parse.(Int,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # k
    sol.k = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # f
    for m = 1:M
        sol.f[:,m] = parse.(Float64,split(readline(f)))
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

    write(outFile, "prob destroy iter\n")
    write(outFile, join(params.prob_destroy_t," ")*"\n\n")

    write(outFile, "prob repair iter\n")
    write(outFile, join(params.prob_repair_t," ")*"\n\n")

    write(outFile, "time destroy\n")
    write(outFile, join(params.time_destroy," ")*"\n\n")

    write(outFile, "time repair\n")
    write(outFile, join(params.time_repair," ")*"\n\n")

    write(outFile, "num destroy\n")
    write(outFile, join(params.num_destroy," ")*"\n\n")

    write(outFile, "num repair\n")
    write(outFile, join(params.num_repair," ")*"\n\n")

    write(outFile, "destroy names\n")
    write(outFile, join(params.destroy_names," ")*"\n\n")

    write(outFile, "repair names\n")
    write(outFile, join(params.repair_names," ")*"\n\n")
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
    readline(f) # prob destroy iter
    prob_destroy_t = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # prob repair iter
    prob_repair_t = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # time destroy
    time_destroy = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # time repair
    time_repair = parse.(Float64,split(readline(f)))
    readline(f) # blank
    readline(f) # num destroy
    num_destroy = parse.(Int64,split(readline(f)))
    readline(f) # blank
    readline(f) # num repair
    num_repair = parse.(Int64,split(readline(f)))
    readline(f) # blank
    readline(f) # destroy names
    destroy_names = split(readline(f), " ")
    readline(f) # blank
    readline(f) # repair names
    repair_names = split(readline(f), " ")
    
    return (prob_destroy=prob_destroy, prob_repair=prob_repair, destroys=destroys,  prob_destroy_t = prob_destroy_t,
    prob_repair_t = prob_repair_t, repairs=repairs, current_obj=current_obj, current_best=current_best, status=status, 
    time_repair=time_repair, time_destroy=time_destroy, num_repair=num_repair, num_destroy=num_destroy, 
    destroy_names=destroy_names, repair_names=repair_names)
end

