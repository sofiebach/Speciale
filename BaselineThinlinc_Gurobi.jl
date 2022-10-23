using JuMP, Gurobi, XLSX

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
    S::Array{Float64,1}
    w::Array{Float64,2}
    H::Array{Float64,2}
    I::Array{Float64,2}
    u::Array{Float64, 3}
    Instance(P,C,M,timeperiod,L_lower,L_upper,Q_lower,Q_upper,T) = new(P,C,M,timeperiod,
        L_lower,L_upper,collect(L_lower:L_upper),indexin(0,collect(L_lower:L_upper))[],
        Q_lower,Q_upper,collect(Q_lower:Q_upper),
        abs(Q_lower)+1,abs(Q_lower)+timeperiod,T,
        zeros(Float64, P),
        zeros(Float64, P, M),
        zeros(Float64, T, M),
        zeros(Float64, T, C),
        zeros(Float64, length(collect(L_lower:L_upper)), P, C))
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

function read_DR_data(P)
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
    data.S = convert(Array{Float64,2}, XLSX.readdata("data/data_staffing_constraint.xlsx", "Scope", "D2:D38"))[1:P]

    # Simulate I for now
    M = 100 #Number of posts per day
    average = [154 16 6 6 3 50 111 12 2 1 7118152 M]*7.0
    # [DR1, DR2, Ramasjang, P1, P2, P3, P4, P5, P6, P8, digital, SOME]
    for c = 1:data.C
        data.I[:, c] = repeat([average[c]], data.T)
    end

    return data
end


function Baseline(data, time_limit)
    if time_limit > 0
        model = Model(optimizer_with_attributes(Gurobi.Optimizer, "TimeLimit" => time_limit))
    else
        model = Model(optimizer_with_attributes(Gurobi.Optimizer))
    end

    @variable(model, x[1:data.T, 1:data.P] >= 0, Int)
    @variable(model, f[1:data.T,1:data.M] >= 0, Int)
    @variable(model, k[1:data.P] >= 0, Int)

    penalty_scope = round.(sum(sum(data.u[:,:,1:12], dims=1),dims=3)) # Including all channels

    @objective(model, Max, sum(x[t,p] for t = data.start:data.stop for p = 1:data.P) - sum(k[p]*penalty_scope[p] for p = 1:data.P))

    # Nothing can be planned before start and after stop
    @constraint(model, [t = 1:(data.start - 1)], sum(x[t,p] for p = 1:data.P) == 0)
    @constraint(model, [t = (data.stop + 1):data.T], sum(x[t,p] for p = 1:data.P) == 0)

    # Force freelance hours to be 0
    @constraint(model, [t = 1:data.T, m = 1:data.M], f[t,m] == 0)

    # Inventory constraint
    @constraint(model, [t=1:data.T, c=1:data.C], sum(data.u[t-t2+data.L_zero,p,c]*x[t2,p] for p = 1:data.P for t2 = max(t-data.L_upper, data.start):min(data.stop,t-data.L_lower)) <= data.I[t,c])

    # Staff from t = start:stop
    @constraint(model, [t=1:data.T, m=1:data.M], sum(data.w[p,m] * x[t2,p] for p=1:data.P for t2 = max(t-data.Q_upper, data.start):min(data.stop,t-data.Q_lower)) <= data.H[t,m]) 

    # Scope constraint
    @constraint(model, [p=1:data.P], sum(x[t,p] for t = data.start:data.stop) >= data.S[p] - k[p])

    JuMP.optimize!(model)

    # Create solution object
    sol = Sol(data.T,data.P,data.M)
    sol.obj = objective_value(model)
    for p = 1:sol.P
        if JuMP.value(k[p]) > 0.5
            sol.k[p] = JuMP.value(k[p])
        end
        for t = 1:sol.T
            if JuMP.value(x[t,p]) > 0.5
                sol.x[t,p] = JuMP.value(x[t,p])
            end
        end
    end
    for t = 1:sol.T
        for m = 1:sol.M
            if JuMP.value(f[t,m]) > 0.5
                sol.f[t,m] = JuMP.value(f[t,m])
            end
        end
    end
    return sol
end

function print_solution(sol)
    println("Objective: ", sol.obj)
    for p = 1:sol.P
        println("Priority ", p, " is scheduled ", sum(sol.x[:,p]), " times")
    end

    for p = 1:sol.P
        if sol.k[p] > 0.5
            println("Penalty for priority ", p , " with value: ", sol.k[p])
        end
    end
    for m = 1:sol.M
        for t = 1:sol.T 
            if sol.f[t,m] > 0.5
                #println("Number of freelance for media ", m , " at time ", t, ": ", sol.f[t,m])
            end
        end
        println("Number of freelance hours for media ", m, " is: ", sum(sol.f[:,m]))
    end
    
    println("Total number of campaigns: ", sum(sol.x))
end


P = 37
data = read_DR_data(P)

sol = Baseline(data, 0)

print_solution(sol)