include("../ReadWrite.jl")

data = read_DR_data(37)

writeInstance("create_data/original.txt", data)

function createNewInstance(data, d, w, u)
    timeperiod = Int(ceil(data.timeperiod*d))
    T = timeperiod + data.start + abs(data.Q_lower)

    new_instance = Instance(data.P, data.C, data.M, timeperiod, data.L_lower, data.L_upper, data.Q_lower, data.Q_upper, T)
    
    new_instance.stop = deepcopy(abs(data.Q_lower)+timeperiod)
    new_instance.S = deepcopy(Int64.(ceil.(data.S*d)))
    new_instance.F = deepcopy(data.F*d)
    new_instance.penalty_S = ones(new_instance.P)./new_instance.S
    for p in data.P_bar
        new_instance.penalty_S[p] += 20
    end
    new_instance.aimed_g = Int64.(ceil.(new_instance.S/timeperiod))
    new_instance.aimed_L = (timeperiod - 1) ./(new_instance.S .- 1)
    replace!(new_instance.aimed_L, Inf => 0)
    new_instance.penalty_g = 1 ./ (new_instance.S .- new_instance.aimed_g)
    replace!(new_instance.penalty_g, Inf => 0)
    new_instance.weight_idle = (new_instance.S .- 1) / (timeperiod - 1)

    for m = 1:data.M
        new_instance.w[:,m] = deepcopy(data.w[:,m]*(1-w))
        new_instance.H[:,m] = deepcopy(data.H[1:T,m])
    end

    for c = 1:data.C
        new_instance.I[:,c] = deepcopy(data.I[1:T,c])
        for p=1:data.P
            new_instance.u[:,p,c] = deepcopy(data.u[:,p,c]*(1-u))
        end
    end

    new_instance.BC_names = deepcopy(data.BC_names)
    new_instance.P_names = deepcopy(data.P_names)
    new_instance.C_names = deepcopy(data.C_names)
    new_instance.M_names = deepcopy(data.M_names)
    new_instance.campaign_type = deepcopy(data.campaign_type)

    filename = "dataset/"*string(Int(d*100))*"_"*string(Int(w*100))*"_"*string(Int(u*100))*".txt"
    
    writeInstance(filename, new_instance)
end

data = readInstance("create_data/original.txt")

percent = [0.25,0.5,1]
U = [0, 0.05, 0.1, 0.15]
W = [0, 0.05, 0.1, 0.15]

for p in percent, u in U
    createNewInstance(data,p,0,u)
end

for p in percent, w in W
    createNewInstance(data,p,w,0)
end

