include("../ReadWrite.jl")
include("DR_output.jl")
include("../BasicFunctions.jl")

# Create data set in same size at DR
data = read_DR_data(37)
timeperiod = 50
T = timeperiod + abs(data.Q_lower) + data.L_upper

data.T = T
data.start = abs(data.Q_lower)+1
data.stop = abs(data.Q_lower)+timeperiod
data.timeperiod = timeperiod
data.I = data.I[1:T,:]
data.H = data.H[1:T,:]

writeInstance("DR stuff/DRdata.txt", data)


# Create dataset that corresponds to DRs plan
data = readInstance("DR stuff/DRdata.txt")
x = read_DR_solution()
DRsol = Sol(data)

for t = 1:data.T 
    for p = 1:data.P 
        for n = 1:x[t,p]
            insert!(data, DRsol, t, p)
        end
    end
end

DRdata = deepcopy(data)
DRdata.S = sum(DRsol.x, dims = 1)[1,:]
DRdata.F = zeros(Float64, 4)

for t = 1:DRdata.T 
    for c = 1:DRdata.C 
        if DRsol.I_cap[t,c] < 0
            DRdata.I[t,c] -= (DRsol.I_cap[t,c] - 1e-6)
        end
    end
end

for t = 1:DRdata.T 
    for m = 1:DRdata.M 
        if DRsol.H_cap[t,m] < 0
            DRdata.H[t,m] -= (DRsol.H_cap[t,m]  - 1e-6)
        end
    end
end

writeInstance("DR stuff/DRcapacitiesData.txt", DRdata)