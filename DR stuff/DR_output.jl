using XLSX
using PlotlyJS
using Statistics

include("../Baseline/ReadWrite.jl")

function DR_plan()

    output = XLSX.readdata("data/kampagner_planlagt2021.xlsx", "Data (2)", "A2:H63134")
    channel_mapping = XLSX.readdata("data/data_inventory_consumption.xlsx", "Mapping", "A2:B13")
    # [DR1, DR2, Ramasjang, P1, P2, P3, P4, P5, P6, P8, digital, SOME]
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C38")
    BC_names = unique(mapping[:,1])

    T = maximum(output[:,7])
    C = size(channel_mapping)[1]
    P = size(mapping)[1]

    data = read_DR_data(P)
    dr_sol = Sol(data.T,data.P,data.M)

    inventory_check = zeros(Float64, T, C)
    number_priorities = zeros(Int64, P)
    MP_ids = unique(output[:,1])
    MP_ids = unique(output[:,1])
    
    consumption_check = zeros(Float64, P, C)

    for n = 1:size(output)[1]
        include = false

        id = output[n, 1]
        brand_channel = output[n, 3]
        priority = output[n, 4]
        channel = output[n, 6]
        week = output[n, 7]
        units = output[n, 8]

        # Adjust priority
        if occursin("Volumen", priority)
            priority = "Kernen"
        elseif occursin("enkeltstående", priority)
            priority = split(priority, " ")[1] * " (enk.)"
        elseif occursin("Stacking", priority)
            priority = "Dilemma - Stacking"
        elseif occursin("Flow-tid", priority)
            priority = "Flow-tid"
        elseif occursin("Perspektiv", priority)
            priority = "Perspektiv"
        end

        # Adjust brand_channel
        if brand_channel == "DR LYD"
            brand_channel = "DR Radio"
        end

        # Adjust channel
        if startswith(channel, "F ") || occursin("Facebook", channel) || channel == "Instagram"
            channel = "SOME"
        elseif occursin("banner", channel)
            channel = "Digital"
        end

        # Fill number_priorities
        for p = 1:P
            if brand_channel == mapping[p, 1] && priority == mapping[p, 2]
                include = true
                # if not already counted
                if id in MP_ids
                    # Fill x in dr_sol
                    week0 = minimum(output[output[:,1] .== id, 7]) - data.L_l[p] + data.start
                    if week0 >= data.start && week0 <= data.stop
                        dr_sol.x[week0, p] += 1

                        # Count number of priority
                        number_priorities[p] += 1
                        deleteat!(MP_ids, findall(x->x==id,MP_ids))
                    else 
                        include = false
                    end
                    
                end

                # Fill consumption check
                for c = 1:C
                    if channel == channel_mapping[c, 2]
                        consumption_check[p, c] += units
                    end
                end
            end
        end

        # Fill k and obj in dr_sol
        dr_sol.obj = sum(dr_sol.x)
        for p = 1:P
            dr_sol.k[p] = max(data.S[p] - number_priorities[p], 0)
        end

        # Fill inventory_check
        if include
            for c = 1:C
                if channel == channel_mapping[c, 2]
                    inventory_check[week, c] += units
                end
            end
        end
    end

    # Find average consumption per priority
    for c = 1:C
        consumption_check[:,c] = consumption_check[:,c] ./ number_priorities
    end
    replace!(consumption_check, NaN=>0.0)
    
    return inventory_check, number_priorities, consumption_check, dr_sol
end


