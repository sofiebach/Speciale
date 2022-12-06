include("ReadWrite.jl")
include("ALNS.jl")
include("PlotSolution.jl")

data = readInstance("100_0_0.txt")
sol = randomInitial(data)

# sol = Sol(data) #Empty solution
# p = 7
# insert!(data,sol,data.start, p)
# insert!(data,sol,data.stop, p)
# regretInsertion(data,sol,[p], "expanded")

time_limit = 60 #Seconds

sol, params = ALNS(data, sol, time_limit, "expanded")

# Plotting
probabilityTracking(params, "probability")
solutionTracking(params, "solution")
drawTVSchedule(data, sol, "TV-schedule")
drawRadioSchedule(data, sol, "Radio-schedule")