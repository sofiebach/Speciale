include("ReadWrite.jl")
include("MIPModel.jl")
include("ValidateSolution.jl")
include("PlotSolution.jl")

data = read_DR_data()

sol = MIP(data, 60)

print_solution(sol)

checkSolution(data,sol)

#filename = "output/solution.txt"
#writeSolution(filename, data, sol)
#data, sol = readSolution(filename)

drawSolution(data,sol)

drawHeatmap(data,sol)


function plotScope(data, sol)
    total = sum(sol.x, dims=1)
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C38")[1:data.P,:]
    BC_names = unique(mapping[:,1])
    campaign_names = unique(mapping[:,2])
    output = zeros(Float64, length(BC_names), length(campaign_names))
    for p = 1:data.P
        for bc = 1:length(BC_names)
            for campaign = 1:length(campaign_names)
                if mapping[p,1] == BC_names[bc] && mapping[p,2] == campaign_names[campaign]
                    output[bc, campaign] = total[p] - data.S[p]
                end
            end
        end
    end
    return output
end

output = plotScope(data, sol)