mutable struct Instance
    P::Int64
    P_bar::Array{Int64, 1}
    C::Int64
    M::Int64
    timeperiod::Int64
    L_lower::Int64
    L_upper::Int64
    L_zero::Int64
    Q_lower::Int64
    Q_upper::Int64
    start::Int64
    stop::Int64
    T::Int64
    S::Array{Int64,1}
    w::Array{Float64,2}
    H::Array{Float64,2}
    I::Array{Float64,2}
    u::Array{Float64, 3}
    L_l::Array{Int64, 1}
    L_u::Array{Int64, 1}
    penalty_S::Array{Float64, 1}
    F::Array{Float64, 1}
    aimed_g::Array{Int64,1}
    P_names::Array{String,1}
    C_names::Array{String,1}
    M_names::Array{String,1}
    BC_names::Array{String,1}
    campaign_type::Array{String,1}
    sim::Array{Float64, 2}
    penalty_g::Array{Float64,1}
    aimed_L::Array{Float64,1}
    weight_idle::Array{Float64,1}
    lambda::Float64
    Instance(P,C,M,timeperiod,L_lower,L_upper,Q_lower,Q_upper,T) = new(P,[1,8],C,M,timeperiod,
        L_lower,L_upper,indexin(0,collect(L_lower:L_upper))[],
        Q_lower,Q_upper,
        abs(Q_lower)+1,abs(Q_lower)+timeperiod,T,
        zeros(Int64, P),
        zeros(Float64, P, M),
        zeros(Float64, T, M),
        zeros(Float64, T, C),
        zeros(Float64, length(collect(L_lower:L_upper)), P, C),
        zeros(Int64, P),
        zeros(Int64, P),
        zeros(Float64, P),
        zeros(Int64, M),
        zeros(Int64, P),
        Vector(undef, P),
        Vector(undef, C),
        Vector(undef, M),
        Vector(undef, P),
        Vector(undef, P),
        zeros(Float64, P, P),
        zeros(Float64, P),
        zeros(Float64, P),
        zeros(Float64, P),
        3/4)
end

mutable struct Objective
    k_penalty::Float64
    g_penalty::Float64
    L_penalty::Float64
    Objective(data, k, g, L, y) = new(
        sum(data.penalty_S[p]*k[p] for p = 1:data.P), 
        sum(data.penalty_g[p] * g[t,p] for t=1:data.T, p=1:data.P), 
        sum(data.weight_idle[p] * (-L[p]+y[p]) + 1 for p=1:data.P)
        )
end

mutable struct Sol
    base_obj::Float64
    exp_obj::Float64
    objective::Objective
    num_campaigns::Int64
    x::Array{Int64,2}
    f::Array{Float64,2}
    k::Array{Int64,1}
    L::Array{Int64, 1}
    g::Array{Int64,2}
    y::Array{Float64, 1}
    P::Int64
    T::Int64
    M::Int64
    C::Int64
    I_cap::Array{Float64,2}
    H_cap::Array{Float64,2}
    Sol(data) = new(
        sum(data.penalty_S[p]*deepcopy(data.S)[p] for p = 1:data.P), 
        data.lambda * sum(data.penalty_S[p]*deepcopy(data.S)[p] for p = 1:data.P)
            + (1-data.lambda) * (sum(data.penalty_g[p] * zeros(Int64, data.T, data.P)[t,p] for t=1:data.T, p=1:data.P)+sum(data.weight_idle[p] * (-zeros(Int64, data.P)[p]+zeros(Float64, data.P)[p]) + 1 for p=1:data.P)), 
        Objective(data,deepcopy(data.S),zeros(Int64, data.T, data.P),zeros(Int64, data.P),zeros(Float64, data.P)), 
        0,
        zeros(Int64,data.T,data.P), 
        zeros(Float64,data.T,data.M), 
        deepcopy(data.S), 
        zeros(Int64, data.P), 
        zeros(Int64, data.T, data.P), 
        zeros(Float64, data.P),
        data.P, 
        data.T, 
        data.M, 
        data.C, 
        deepcopy(data.I), 
        deepcopy(data.H))
end