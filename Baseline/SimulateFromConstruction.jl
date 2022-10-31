include("ConstructionHeuristics.jl")
include("../ReadWrite.jl")

P = 37
data = read_DR_data(P)


using Statistics
N = 1000
obj = []
num_cam = []
freelancers = []
function elapsed_time(start_time)
    return round((time_ns()-start_time)/1e9, digits = 3)
end

start_time = time_ns()
for i = 1:N
    sol = randomInitial(data)
    append!(obj, sol.obj)
    append!(num_cam, sol.num_campaigns)
    
end

stop_time =  elapsed_time(start_time)
println("Time: ", stop_time/N)
println("mean obj: ", mean(obj))
println("min obj: ", minimum(obj))
println("num campaigns: ", mean(num_cam))
println("max campaigns: ", maximum(num_cam))
