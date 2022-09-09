using XLSX

# Struct for holding the instance
mutable struct Instance
    P::Int64
    C::Int64
    M::Int64
    timeperiod::Int64
    L_lower::Int64
    L_upper::Int64
    L::Array{Int64,1}
    L_zero::Int64
    Q_lower::Int64
    Q_upper::Int64
    Q::Array{Int64,1}
    start::Int64
    stop::Int64
    T::Int64
    S::Array{Float64,2}
    w::Array{Float64,2}
    H::Array{Float64,2}
    I::Array{Float64,2}
    u::Array{Float64, 3}
    GRP_matrix::Array{Float64, 4}
    Instance(P,C,M,timeperiod,L_lower,L_upper,Q_lower,Q_upper,T) = new(P,C,M,timeperiod,
        L_lower,L_upper,collect(L_lower:L_upper),indexin(0,collect(L_lower:L_upper))[],
        Q_lower,Q_upper,collect(Q_lower:Q_upper),
        abs(Q_lower)+1,abs(Q_lower)+timeperiod,T,
        zeros(Float64, T, P),
        zeros(Float64, P, M),
        zeros(Float64, T, M),
        zeros(Float64, T, C),
        zeros(Float64, length(collect(L_lower:L_upper)), P, C),
        zeros(Float64, T, T, P, C))
end

# Struct for holding the instance
mutable struct Sol
    obj::Float64
    x::Array{Int64,2}
    f::Array{Int64,2}
    k::Array{Int64,1}
    P::Int64
    T::Int64
    M::Int64
    Sol(T,P,M) = new(0.0, zeros(Int64,T,P), zeros(Int64,T,M), zeros(Int64,P), P, T, M)
end

function read_DR_data()
    P = 29 # skal sættes op, når vi ved noget om Binge, Stacking osv.
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
        consumption = XLSX.readdata("data/Inventory-consumptiom.xlsx", sheet_name, "C4:J15")
        consumption = convert(Array{Float64,2}, consumption)
        data.u[:,p,:] = transpose(consumption)
    end

    # Read production hours
    # w[p,m] is production hours of priority p on media m (platforms are TV, RADIO, BANNER, SOME)
    data.w = convert(Array{Float64,2},XLSX.readdata("data/data_staffing_constraint.xlsx", "Producertimer", "D2:G38"))

    # Read staffing
    # H[t,m] is weekly staffing (hours) on platform m (medias are TV, RADIO, BANNER, SOME) at time t
    data.H = transpose(repeat(convert(Array{Float64,2},XLSX.readdata("data/data_staffing_constraint.xlsx", "Bemanding", "E2:E5")),1,data.T))

    # Read scope
    # S[p] is scope for priority p
    data.S = convert(Array{Float64,2}, XLSX.readdata("data/data_staffing_constraint.xlsx", "Scope", "D2:D38"))

    # Simulate I for now
    average = [154 16 6 6 3 50 111 12 2 1 10 10]*7.0 # Banner og SOME er opfundet
    #1	DR1
    #2	DR2
    #3	Ramasjang
    #4	P1
    #5	P2
    #6	P3
    #7	P4
    #8	P5
    #9	P6
    #10	P8
    #11	Banner
    #12	SOME
    for c = 1:data.C
        data.I[:, c] = repeat([average[c]], data.T)
    end

    for t_col = data.start:data.stop
        row_start = t_col + data.L_lower
        row_stop = min(data.T, row_start + length(data.L) - 1)
        for t_row = row_start:row_stop
            for c = 1:data.C
                for p = 1:data.P
                    l = data.L_zero + t_row-t_col
                    data.GRP_matrix[t_row, t_col, p, c] = data.u[l,p,c]
                end
            end
        end
    end

    return data
end


#Read data instance
#function readInstance(filename)
#    f = open(filename)
#    readline(f) # comment
#    P, C, M, timeperiod = parse.(Int,split(readline(f)))
#    readline(f) # blank
#    readline(f) # comment
#    L_lower, L_upper, L_zero = parse.(Int,split(readline(f)))
#    readline(f) # blank
#    readline(f) # comment
#    L = parse.(Int,split(readline(f)))
#    readline(f) # blank
#    readline(f) # comment
#    Q_lower, Q_upper = parse.(Int,split(readline(f)))
#    readline(f) # blank
#    readline(f) # comment
#    Q = parse.(Int,split(readline(f)))
#    readline(f) # blank
#    readline(f) # comment
#    start, stop, T = parse.(Int,split(readline(f)))
#    readline(f) # blank
#    readline(f) # comment
#    S = parse.(Float64,split(readline(f)))
#    readline(f) # blank
#    readline(f) # comment
#    w = parse.(Float64,split(readline(f)))
#    readline(f) # blank
#    readline(f) # comment
#    H = zeros(Float64, T, M)
#    for m = 1:M
#        H[:,m] = parse.(Float64,split(readline(f)))
#    end
#    #H = parse.(Int,split(readline(f)))
#    readline(f) # blank
#    readline(f) # comment
#    I = zeros(Float64, T, C)
#    for c in 1:C
#        I[:,c] = parse.(Float64,split(readline(f)))
#    end
#    readline(f) # blank
#    readline(f) # comment
#    L = collect(L_lower:L_upper)
#    u = zeros(Float64, length(L), P, C)
#    for c = 1:C
#        line = parse.(Float64,split(readline(f)))
#        u[:,:,c] = reshape(line, (length(L), P))
#    end
#
#    GRP_matrix = zeros(Float64, T, T, P, C)
#    for t_col = start:stop
#        row_start = t_col + L_lower
#        row_stop = min(T, row_start + length(L) - 1)
#        for t_row = row_start:row_stop
#            for c = 1:C
#                for p = 1:P
#                    l = L_zero + t_row-t_col
#                    GRP_matrix[t_row, t_col, p, c] = u[l,p,c]
#                end
#            end
#        end
#    end
#    data = Instance(P,C,M,timeperiod,L_lower,L_upper,L,L_zero,Q_lower,Q_upper,Q,start,stop,T,S,w,H,I,u,GRP_matrix)
#    return data
#end

# Write solution
function writeSolution(filename, data, sol)
    outFile = open(filename, "w")
    write(outFile, "P, C, M, T, timeperiod" * "\n")
    write(outFile, join([data.P, data.C, data.M, data.T, data.timeperiod]," ")*"\n\n")

    write(outFile, "L_lower, L_upper" * "\n")
    write(outFile, join([data.L_lower, data.L_upper]," ")*"\n\n")

    write(outFile, "Q_lower, Q_upper" * "\n")
    write(outFile, join([data.Q_lower, data.Q_upper]," ")*"\n\n")

    write(outFile, "CONSUMPTION" * "\n")
    for c = 1:data.C
        write(outFile, join(data.u[:,:,c], " ") * "\n")
    end
    write(outFile, "\n")

    write(outFile, "INVENTORY" * "\n")
    for c = 1:data.C
        write(outFile, join(data.I[:,c], " ") * "\n")
    end
    write(outFile, "\n")

    write(outFile, "STAFFING" * "\n")
    for m = 1:data.M
        write(outFile, join(data.H[:,m], " ") * "\n")
    end
    write(outFile, "\n")

    write(outFile, "Objective value \n")
    write(outFile, join(sol.obj," ")*"\n\n")
    write(outFile, "Solution \n")
    for p = 1:sol.P
        write(outFile,join(sol.x[:,p]," ") * "\n")
    end
    write(outFile, "\n")

    write(outFile, "Penalty for undone jobs" * "\n")
    write(outFile,join(sol.k," ")*"\n")
    write(outFile, "\n")

    write(outFile, "Freelancers hired" * "\n")
    for m = 1:sol.M
        write(outFile,join(sol.f[:,m]," ")*"\n")
    end
    close(outFile)
end


# Read solution
function readSolution(filename)
    f = open(filename)
    readline(f) # comment
    P, C, M, T, timeperiod = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    L_lower, L_upper = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    Q_lower, Q_upper = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    data = Instance(P,C,M,timeperiod,L_lower,L_upper,Q_lower,Q_upper,T)
    for c = 1:C
        line = parse.(Float64,split(readline(f)))
        data.u[:,:,c] = reshape(line, (length(data.L), data.P))
    end
    readline(f) # blank
    readline(f) # comment
    for c in 1:data.C
        data.I[:,c] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    for m = 1:data.M
        data.H[:,m] = parse.(Float64,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    sol = Sol(data.T,data.P,data.M)
    sol.obj = parse.(Float64, readline(f))
    readline(f) # blank
    readline(f) # comment
    #x = zeros(Int, T, P)
    for p in 1:data.P
        sol.x[:,p] = parse.(Int,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    sol.k = parse.(Int,split(readline(f)))
    readline(f) # blank
    readline(f) # comment
    for m = 1:M
        sol.f[:,m] = parse.(Int,split(readline(f)))
    end
    readline(f) # blank
    readline(f) # comment
    return data, sol
end