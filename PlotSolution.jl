include("ReadWrite.jl")
using Luxor
using ColorSchemes
using PlotlyJS

data, sol = readSolution("output/solution.txt")

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
    
    #col = ["blue","red","green","yellow","orange","purple","cyan","magenta","lime","gray","pink"]
    #col = ColorSchemes.mk_12[1:length(P_names)]
    col = ColorScheme(distinguishable_colors(length(P_names)+1))[2:(length(P_names)+1)]
    
    scalar = 100
    height = 80
    h = 0.8
    c = 2
    w = length(data.L)
    Drawing((data.T+w)*scalar, height*scalar, "output/schedule.png")
    background("white") # color of background
    origin() 

    translate(-(data.T+w)*scalar/2, -height*scalar/2)

    fontsize(70)
    sethue("black")

    for t = 1:data.stop+w
        time = t-data.start+1
        #rect((t-1) * scalar,(c-1) * scalar ,1,(height) * scalar, :fill)
        if time > 0
            text(string(time), Point(-data.L_lower*scalar+(t)*scalar,1 * scalar), halign=:center)
        end
    end
    #rect((data.stop+w)*scalar+h*scalar,0,5,height*scalar, :fill)

    row_start = 2

    fontsize(80)

    #for prio = 1:length(P_names)
    #    setcolor("black")
    #    text(string(P_names[prio]), Point((data.stop+w)*scalar+h*scalar, h*scalar+h*prio*scalar), halign=:left)
    #    setcolor(col[prio])
    #    setopacity(0.5)
    #    rect((data.stop+w)*scalar+h*scalar, h*prio*scalar, w*scalar, h*scalar,:fill)
    #end

    for bc = 1:length(BC)
        sethue("black")
        setopacity(1)
        rect(0,(c-0.5)*scalar,(data.stop+w)*scalar+h*scalar,5, :fill)
        text(string(BC_names[bc]), Point((0.5)*scalar,(c+0.5) * scalar), halign=:left)
        ends = ones(1)*w
        for t = 1:data.T
            for p in BC[bc]
                if sol.x[t,p] != 0
                    priority = mapping[p,2]
                    for n = 1:sol.x[t,p]
                        isPlaced = false
                        for e = 1:length(ends)
                            if (t+data.L_lower) >= ends[e]
                                for prio = 1:length(P_names)
                                    if mapping[p,2] == P_names[prio]
                                        setcolor(col[prio])
                                    end
                                end
                                #setcolor(colors[bc])
                                setopacity(0.5)
                                #rect(t*scalar, (row_start+e-1)*scalar, w*scalar, h*scalar,:fill)
                                rect(-data.L_lower*scalar+(t+data.L_lower)*scalar, (row_start+e-1)*scalar, w*scalar, h*scalar,:fill)
                                sethue("black")
                                #rect(t*scalar, (row_start+e-1)*scalar, w*scalar, h*scalar,:stroke)
                                rect(-data.L_lower*scalar+(t+data.L_lower)*scalar, (row_start+e-1)*scalar, w*scalar, h*scalar,:stroke)
                                text(string(priority), Point(-data.L_lower*scalar+(t+data.L_lower)*scalar, h*scalar+(row_start+e-1)*scalar), halign=:left)
                                ends[e] = t + w
                                isPlaced = true
                                break
                            end
                        end
                        if isPlaced == false
                            c += 1
                            for prio = 1:length(P_names)
                                if mapping[p,2] == P_names[prio]
                                    setcolor(col[prio])
                                end
                            end
                            #sethue(colors[bc])
                            setopacity(0.5)
                            #rect(t*scalar, c*scalar, w*scalar, h*scalar,:fill)
                            rect(-data.L_lower*scalar+(t+data.L_lower)*scalar, c*scalar, w*scalar, h*scalar,:fill)
                            sethue("black")
                            #rect(t*scalar, c*scalar, w*scalar, h*scalar,:stroke)
                            rect(-data.L_lower*scalar+(t+data.L_lower)*scalar, c*scalar, w*scalar, h*scalar,:stroke)
                            text(string(priority), Point(-data.L_lower*scalar+(t+data.L_lower)*scalar, h*scalar+c*scalar), halign=:left)
                            append!(ends,(t+w))
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

drawSolution(data,sol)

function drawHeatmap(data, sol)
    inventory_used, staff_used = checkSolution(data, sol)
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C38")[1:data.P,:]
    BC_names = unique(mapping[:,1])
    channels = ["DR1","DR2","Ramasjang","P1","P2","P3","P4","P5","P6","P8","Banner","SOME"]
    media = ["TV", "Radio", "Banner", "SOME"]
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
    relayout!(p, title_text="Capacity for channel inventory and staff",xaxis_title="Lorte akse")
    p
end

data, sol = readSolution("output/solution.txt")
drawHeatmap(data,sol)

