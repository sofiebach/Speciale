using XLSX

function read_DR_data()
    
    P = 29 # skal sættes op, når vi ved noget om Binge, Stacking osv.
    C = 12
    M = 4 # medias
    L_lower = -2
    L_upper = 5
    L = collect(L_lower:L_upper)
    L_zero = indexin(0,L)[]
    Q_lower = -4
    Q_upper = -3
    Q = collect(Q_lower:Q_upper)
    l = length(L)
    timeperiod = 52
    T = abs(minimum(Q)) + timeperiod + maximum(L)
    start = abs(minimum(Q)) + 1
    stop = abs(minimum(Q)) + timeperiod

    # Read GRP consumption
    # u[l,p,c] is GRP consumption of priority p on channel c in relative week l-3
    prefix = "Priority "
    u = zeros(Float64, l, P, C)
    for p = 1:P
        sheet_name = prefix * string(p)
        consumption = XLSX.readdata("data/Inventory-consumptiom.xlsx", sheet_name, "C4:J15")
        consumption = convert(Array{Float64,2}, consumption)
        u[:,p,:] = transpose(consumption)
    end

    # Read production hours
    # w[p,m] is production hours of priority p on media m (platforms are TV, RADIO, BANNER, SOME)
    w = XLSX.readdata("data/data_staffing_constraint.xlsx", "Producertimer", "D2:G38")
    w = convert(Array{Float64,2}, w)

    # Read staffing
    # H[t,m] is weekly staffing (hours) on platform m (medias are TV, RADIO, BANNER, SOME) at time t
    H = XLSX.readdata("data/data_staffing_constraint.xlsx", "Bemanding", "E2:E5")
    H = convert(Array{Float64,2}, H)
    H = repeat(H, 1, T)
    H = transpose(H)

    # Read scope
    # S[p] is scope for priority p
    S = XLSX.readdata("data/data_staffing_constraint.xlsx", "Scope", "D2:D38")
    S = convert(Array{Float64,2}, S)

    # Simulate I for now
    I = zeros(Float64, T, C)
    for c = 1:C
        I[:, c] = rand(10:100, T)*7.0
    end

    return P,C,M,timeperiod,L_lower,L_upper,L,L_zero,Q_lower,Q_upper,Q,start,stop,T,S[1:P],w[1:P,:],H,I,u
end

