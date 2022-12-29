include("DR_output.jl")
include("../ReadWrite.jl")
include("../BasicFunctions.jl")
include("../Validation/PlotSolution.jl")

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

pdf = true
p_tv = findall(x -> x == "TV", data.campaign_type)
p_radio = findall(x -> x == "RADIO", data.campaign_type)
TV_BC_names = unique(data.BC_names[p_tv])
radio_BC_names = unique(data.BC_names[p_radio])

for bc = 1:length(TV_BC_names)
    drawTVSchedule(data, DRsol, "DR stuff/schedules/tv_"*string(bc), bc, pdf)
end
for bc = 1:length(radio_BC_names)
    drawRadioSchedule(data, DRsol, "DR stuff/schedules/radio_"*string(bc), bc, pdf)
end


