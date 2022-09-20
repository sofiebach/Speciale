using Luxor
using PlotlyJS
using Colors

function print_solution(sol)
    println("Objective: ", sol.obj)
    for p = 1:sol.P
        println("Priority ", p, " is scheduled ", sum(sol.x[:,p]), " times")
    end

    for p = 1:sol.P
        if sol.k[p] > 0.5
            println("Penalty for priority ", p , " with value: ", sol.k[p])
        end
    end
    for m = 1:sol.M
        for t = 1:sol.T 
            if sol.f[t,m] > 0.5
                #println("Number of freelance for media ", m , " at time ", t, ": ", sol.f[t,m])
            end
        end
        println("Number of freelance hours for media ", m, " is: ", sum(sol.f[:,m]))
    end
    
    println("Total number of campaigns: ", sum(sol.x))
end

function drawSolution(data, sol)
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C38")[1:data.P,:]
    BC_names = unique(mapping[:,1])
    BC = []
    for bc in BC_names
        priorities = []
        for i = 1:data.P
            if mapping[i,1] == bc
                priorities = push!(priorities, i)
            end
        end
        BC = push!(BC, priorities)
    end

    P_names = unique(mapping[:,2])
    num_P_names = length(P_names)
    
    #col = ["blue","red","green","yellow","orange","purple","cyan","magenta","lime","gray","pink"]
    w = length(data.L)
    c = 2
    row_start = 2
    height = 0
    num_BC = length(BC)
    for bc = 1:num_BC
        ends = ones(1)
        for t = 1:data.T
            for p in BC[bc]
                if sol.x[t,p] != 0
                    priority = mapping[p,2]
                    for n = 1:sol.x[t,p]
                        isPlaced = false
                        len_ends = length(ends)
                        for e = 1:len_ends
                            if (t+data.L_lower) >= ends[e]

                                ends[e] = t + w + data.L_lower
                                isPlaced = true
                                break
                            end
                        end
                        if isPlaced == false
                            c += 1
                            append!(ends,(t+w+data.L_lower))
                        end
                    end
                end
            end
        end
        c = c+2    
        row_start = row_start + length(ends) + 1
        height = row_start
    end

    scalar = 100
    h = 0.8
    col = distinguishable_colors(length(P_names)+1)[2:(length(P_names)+1)]

    Drawing((data.T+w)*scalar, height*scalar, "output/schedule.png")
    background("white") # color of background
    origin() 

    translate(-(data.T+w)*scalar/2, -height*scalar/2)

    fontsize(70)
    sethue("black")
    offset = 2 
    
    for t = 1:data.stop+w
        time = t-data.start+1
        #rect((t-1) * scalar,(c-1) * scalar ,1,(height) * scalar, :fill)
        if time > 0
            text(string(time), Point((offset + t)*scalar,1 * scalar), halign=:center)
        end
    end

    c = 2
    row_start = 2
    fontsize(80)

    for bc = 1:num_BC
        sethue("black")
        setopacity(1)
        Luxor.rect(0,(c-0.5)*scalar,(data.T+w)*scalar,5, :fill)
        text(string(BC_names[bc]), Point((0.5)*scalar,(c+0.5) * scalar), halign=:left)
        ends = ones(1)
        for t = 1:data.T
            for p in BC[bc]
                if sol.x[t,p] != 0
                    priority = mapping[p,2]
                    for n = 1:sol.x[t,p]
                        isPlaced = false
                        len_ends = length(ends)
                        for e = 1:len_ends
                            if (t+data.L_lower) >= ends[e]
                                for prio = 1:num_P_names
                                    if mapping[p,2] == P_names[prio]
                                        setcolor(col[prio])
                                    end
                                end
                                setopacity(0.5)
                                Luxor.rect((offset+t+data.L_lower)*scalar, (row_start+e-1)*scalar, w*scalar, h*scalar,:fill)
                                sethue("black")
                                setopacity(0.8)
                                text(string(priority), Point((offset+t+data.L_lower+w/2)*scalar, (0.1 + row_start+e-1)*scalar),valign =:top, halign=:center)
                                setopacity(1)
                                Luxor.rect((offset+t+data.L_lower)*scalar, (row_start+e-1)*scalar, w*scalar, h*scalar,:stroke)
                                ends[e] = t + w + data.L_lower
                                isPlaced = true
                                break
                            end
                        end
                        if isPlaced == false
                            c += 1
                            for prio = 1:num_P_names
                                if mapping[p,2] == P_names[prio]
                                    setcolor(col[prio])
                                end
                            end
                            setopacity(0.5)
                            Luxor.rect((offset+t+data.L_lower)*scalar, c*scalar, w*scalar, h*scalar,:fill)
                            sethue("black")
                            setopacity(0.8)
                            text(string(priority), Point((offset+t+data.L_lower+w/2)*scalar, (0.1+c)*scalar), valign =:top, halign=:center)
                            setopacity(1)
                            Luxor.rect((offset+t+data.L_lower)*scalar, c*scalar, w*scalar, h*scalar,:stroke)
                            append!(ends,(t+w+data.L_lower))
                        end
                    end
                end
            end
        end
        c = c+2    
        row_start = row_start + length(ends) + 1
    end

    finish()
    preview()
end

function drawHeatmap(data, sol)
    inventory_used, staff_used = checkSolution(data, sol)
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C38")[1:data.P,:]
    BC_names = unique(mapping[:,1])
    channels = XLSX.readdata("data/data_inventory_consumption.xlsx", "Mapping", "B2:B13")[1:data.C]
    media = XLSX.readdata("data/data_staffing_constraint.xlsx", "Bemanding", "A2:A5")[1:data.M]
    BC = []
    for bc in BC_names
        priorities = []
        for i = 1:data.P
            if mapping[i,1] == bc
                priorities = push!(priorities, i)
            end
        end
        BC = push!(BC, priorities)
    end
    
    plot_inventory = plot(heatmap(   
            x = collect(1:data.T),
            y = channels,
            z = transpose(inventory_used)
            ))
    
    plot_staff = plot(heatmap(
        x = collect(1:data.T),
        y = media,
        z = transpose(staff_used)
        ))

    p = [plot_inventory; plot_staff]
    PlotlyJS.relayout!(p, title_text="Capacity for channel inventory and staff",xaxis_title="Lorte akse")
    display(p)
    #savefig(p, "output/heatmap.png")
end


function plotScope(data, sol)
    total = sum(sol.x, dims=1)
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C38")[1:data.P,:]
    BC_names = unique(mapping[:,1])
    num_BC = length(BC_names)
    campaign_names = unique(mapping[:,2])
    num_campaigns = length(campaign_names)
    output = zeros(Float64, length(BC_names), length(campaign_names))*NaN
    for p = 1:data.P
        for bc = 1:num_BC
            for campaign = 1:num_campaigns
                if mapping[p,1] == BC_names[bc] && mapping[p,2] == campaign_names[campaign]
                    output[bc, campaign] = total[p] - data.S[p]
                end
            end
        end
    end

    p = plot(heatmap(
        x = campaign_names,
        y = BC_names,
        z = output,
        theme="plotly_white"))
    display(p)
    #savefig(p, "output/scope.png")

end

