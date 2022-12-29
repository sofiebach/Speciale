using XLSX
using PlotlyJS
using Statistics

function read_DR_solution()
    output = XLSX.readdata("data/kampagner_planlagt2021.xlsx", "Data (2)", "A2:H63134")
    channel_mapping = XLSX.readdata("data/data_inventory_consumption.xlsx", "Mapping", "A2:B13")
    # [DR1, DR2, Ramasjang, P1, P2, P3, P4, P5, P6, P8, digital, SOME]
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C38")

    data = readInstance("DR stuff/DRdata.txt")
    x = zeros(Int64,data.T,data.P)

    MP_ids = unique(output[:,1])

    for n = 1:size(output)[1]
        include = false

        id = output[n, 1]
        brand_channel = output[n, 3]
        type = output[n, 4]
        channel = output[n, 6]

        # Adjust priority
        if occursin("Volumen", type)
            type = "Kernen"
        elseif occursin("enkeltstående", type)
            type = split(type, " ")[1] * " (enk.)"
        elseif occursin("Stacking", type)
            type = "Dilemma - Stacking"
        elseif occursin("Flow-tid", type)
            type = "Flow-tid"
        elseif occursin("Perspektiv", type)
            type = "Perspektiv"
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
        for p = 1:data.P
            if brand_channel == mapping[p, 1] && type == mapping[p, 2]
                # if not already counted
                if id in MP_ids
                    # Fill x in dr_sol
                    campaign_weeks = output[output[:,1] .== id, 7]
                    if minimum(campaign_weeks) > 1 && maximum(campaign_weeks) < 52
                        week0 = minimum(campaign_weeks) - data.L_l[p] + data.start - 2
                    else
                        week0 = 0
                    end
                    if week0 >= data.start && week0 <= data.stop
                        x[week0, p] += 1
                        deleteat!(MP_ids, findall(x->x==id,MP_ids))
                    end
                end
            end
        end
    end
    return x
end


