include("ConstructionHeuristics.jl")
include("ReadWrite.jl")

P = 37
data = read_DR_data(P)
using Statistics
N = 1000
obj = []
num_cam = []
freelancers = []

for i = 1:N
    sol = randomInitial(data)
    append!(obj, sol.obj)
    append!(num_cam, sol.num_campaigns)
    
end

mean(obj)
minimum(obj)
mean(num_cam)
maximum(num_cam)
std(obj)
std(num_cam)