include("../ReadWrite.jl")

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