include("../../ReadWrite.jl")
include("../../Validation/ValidateSolution.jl")

idx = 1
filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)
filename="dummy"
sol = readSolution("ComputationalResults/IncreasedInventory/results/"*filename, data)

init_I = data.I * 50
init_H = data.H * 50

required_I = init_I .- sol.I_cap
required_H = init_H .- sol.H_cap

difference_I = 0
difference_H = 0
for t = 1:data.T 
    for c = 1:data.C 
        if required_I[t,c] > data.I[t,c]
            difference_I += required_I[t,c] - data.I[t,c]
        end
    end

    for m = 1:data.M 
        if required_H[t,m] > data.H[t,m]
            difference_H += required_H[t,m] - data.H[t,m]
        end
    end
end


difference_I / sum(data.I[data.start+data.L_lower:data.stop+data.L_upper,:]) * 100
difference_H / sum(data.H[data.start+data.Q_lower:data.stop+data.Q_upper,:]) * 100