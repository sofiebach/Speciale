using XLSX
using PlotlyJS
using Statistics

include("ReadWrite.jl")

function DR_plan()
    output = XLSX.readdata("data/kampagner_planlagt2021.xlsx", "Data (2)", "A2:H63134")
    channel_mapping = XLSX.readdata("data/data_inventory_consumption.xlsx", "Mapping", "A2:B13")
    # [DR1, DR2, Ramasjang, P1, P2, P3, P4, P5, P6, P8, Banner, SOME]
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C38")
    BC_names = unique(mapping[:,1])

    T = maximum(output[:,7])
    C = size(channel_mapping)[1]
    P = size(mapping)[1]

    inventory_check = zeros(Float64, T, C)
    number_priorities = zeros(Int64, P)
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
            channel = "Banner"
        end

        # Fill number_priorities
        for p = 1:P
            if brand_channel == mapping[p, 1] && priority == mapping[p, 2]
                include = true
                # if not already counted
                if id in MP_ids
                    number_priorities[p] += 1
                    deleteat!(MP_ids, findall(x->x==id,MP_ids))
                end

                # Fill consumption check
                for c = 1:C
                    if channel == channel_mapping[c, 2]
                        consumption_check[p, c] += units
                    end
                end
            end
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
    
    BC = []
    for bc in BC_names
        priorities = []
        for i = 1:P
            if mapping[i,1] == bc
                priorities = push!(priorities, i)
            end
        end
        BC = push!(BC, priorities)
    end
    
    return inventory_check, number_priorities, consumption_check
end


inventory_check, number_priorities, consumption_check = DR_plan()

data = read_DR_data(37)

inventory_used = inventory_check ./ data.I[data.start:data.stop,:]

inventory_used[inventory_used .>= 1.0] .= 1.5

#U = zeros(Float64, data.P, data.C)
#
#for p = 1:data.P 
#    for c = 1:data.C
#        U[p, c] = sum(data.u[:,p,c])
#    end
#end
#
#check = U - consumption[1:data.P,:]
#
## DER ER NOGET GALT MED c=11
#check[:,11] = zeros(Float64, data.P)
channel_mapping = XLSX.readdata("data/data_inventory_consumption.xlsx", "Mapping", "A2:B13")
plot_inventory = plot(heatmap(   
            x = collect(1:53),
            y = channel_mapping,
            z = transpose(inventory_used)
            ))
plot_inventory
savefig(plot_inventory, "output/DR_inventory.png")
