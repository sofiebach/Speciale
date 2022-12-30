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

n_digits = 3

scope_reached = round.(sum(DRsol.x,dims=1) ./ data.S' .* 100, sigdigits=n_digits)
plus = 0
plus_sum = 0
minus = 0
minus_sum = 0
spot_on = 0
for p = 1:data.P 
    if p == 20
        continue
    end
    if scope_reached[p] == 100
        spot_on += 1
    elseif scope_reached[p] > 100
        plus += 1
        plus_sum += scope_reached[p] - 100
    else
        minus += 1
        minus_sum += 100 - scope_reached[p]
    end
end
plus_avg = plus_sum / plus
minus_avg = minus_sum / minus

