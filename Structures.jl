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
        zeros(Float64, P))
end

# mutable struct Sol
#     obj::Float64
#     num_campaigns::Int64
#     x::Array{Int64,2}
#     f::Array{Float64,2}
#     k::Array{Int64,1}
#     L::Array{Int64, 1}
#     g::Array{Int64,2}
#     P::Int64
#     T::Int64
#     M::Int64
#     Sol(T,P,M) = new(0.0, 0, zeros(Int64,T,P), zeros(Float64,T,M), zeros(Int64,P), zeros(Int64,P), zeros(Int64, T, P), P, T, M)
# end
# 
# mutable struct BaselineSol
#     obj::Float64
#     num_campaigns::Int64
#     x::Array{Int64,2}
#     f::Array{Float64,2}
#     k::Array{Int64,1}
#     P::Int64
#     T::Int64
#     M::Int64
#     I_cap::Array{Float64,2}
#     H_cap::Array{Float64,2}
#     BaselineSol(data) = new(0.0, 0, zeros(Int64,data.T,data.P), zeros(Float64,data.T,data.M), deepcopy(data.S), data.P, data.T, data.M, deepcopy(data.I), deepcopy(data.H))
# end

mutable struct Objective
    k_penalty::Float64
    g_penalty::Float64
    L_reward::Float64
    Objective() = new(0.0, 0.0, 0.0)
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
    P::Int64
    T::Int64
    M::Int64
    C::Int64
    I_cap::Array{Float64,2}
    H_cap::Array{Float64,2}
    Sol(data) = new(0.0, 0.0, Objective(), 0,
    zeros(Int64,data.T,data.P), zeros(Float64,data.T,data.M), deepcopy(data.S), 
    zeros(Int64, data.P), zeros(Int64, data.T, data.P), 
    data.P, data.T, data.M, data.C, 
    deepcopy(data.I), deepcopy(data.H))
end
