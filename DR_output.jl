using XLSX
include("ReadWrite.jl")

function DR_plan()
    output = XLSX.readdata("data/kampagner_planlagt2021.xlsx", "Data (2)", "A2:H63134")
    channel_mapping = XLSX.readdata("data/data_inventory_consumption.xlsx", "Mapping", "A2:B13")
    # [DR1, DR2, Ramasjang, P1, P2, P3, P4, P5, P6, P8, Banner, SOME]
    media_mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "J2:J5")
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C38")
    BC_names = unique(mapping[:,1])

    T = maximum(output[:,7])
    C = size(channel_mapping)[1]
    P = size(mapping)[1]
    M = size(media_mapping)[1]

    inventory_check = zeros(Float64, T, C)
    number_priorities = zeros(Int64, P)
    MP_ids = unique(output[:,1])
    
    consumption_check = zeros(Float64, P, M)

    for n = 1:size(output)[1]
        # Adjust priority
        include = false

        id = output[n, 1]
        brand_channel = output[n, 3]
        priority = output[n, 4]
        media = output[n, 5]
        channel = output[n, 6]
        week = output[n, 7]
        units = output[n, 8]
        
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

        if brand_channel == "DR LYD"
            brand_channel = "DR Radio"
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
                for m = 1:M 
                    if media == media_mapping[m]
                        consumption_check[p, m] += units
                    end
                end
            end
        end

        # Adjust channel
        if startswith(channel, "F ") || occursin("Facebook", channel) || channel == "Instagram"
            channel = "SOME"
        elseif occursin("banner", channel)
            channel = "Banner"
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
    consumption_check[:,1] = consumption_check[:,1]./S
    consumption_check[:,2] = consumption_check[:,2]./S
    consumption_check[:,3] = consumption_check[:,3]./S
    consumption_check[:,4] = consumption_check[:,4]./S
    replace!(check, NaN=>0.0)

    # Simulate I for now
    #I = zeros(Float64, T, C)
    ## average = [154 16 22 6 3 50 111 12 2 1 10 10]*7.0
    #average = [154 16 6 6 3 50 111 12 2 1 10 10]*7.0
    #for c = 1:C
    #    I[:, c] = repeat([average[c]], T)
    #end
    #
    #inventory_used = inventory_check ./ I
    #
    #inventory_used[inventory_used .>= 1.0] .= 1.0
    #
    #BC = []
    #for bc in BC_names
    #    priorities = []
    #    for i = 1:P
    #        if mapping[i,1] == bc
    #            priorities = push!(priorities, i)
    #        end
    #    end
    #    BC = push!(BC, priorities)
    #end
    #
    #plot_inventory = plot(heatmap(   
    #        x = collect(1:T),
    #        y = channel_mapping,
    #        z = transpose(inventory_used)
    #        ))
    return inventory_check, number_priorities, consumption_check
end


I, S, check = DR_plan()
data = read_DR_data(29)
consumption = 



check[1:data.P,:]

