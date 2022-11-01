using Luxor
using XLSX
using PlotlyJS
using Colors
# import Pkg
# ENV["PYTHON"] = "/Users/sofiebach/opt/anaconda3/envs/skole/bin/python3"
# Pkg.build("PyCall")
using PyCall
# @pyimport pandas as pd
# @pyimport numpy as np
# @pyimport matplotlib.pyplot as plt
# @pyimport seaborn as sns

include("ValidateSolution.jl")

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

function drawTVSchedule(data, sol, filename)
    TV_campaigns = 29
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B2:C30")[1:TV_campaigns,:]
    BC_names = unique(mapping[:,1])
    BC = []
    for bc in BC_names
        priorities = []
        for i = 1:TV_campaigns
            if mapping[i,1] == bc
                push!(priorities, i)
            end
        end
        push!(BC, priorities)
    end

    P_names = unique(mapping[:,2])
    num_P_names = length(P_names)
    
    #col = ["blue","red","green","yellow","orange","purple","cyan","magenta","lime","gray","pink"]
    w = data.L_upper - data.L_lower + 1
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

    Drawing((data.T+w)*scalar, height*scalar, "output/schedule_" * filename * ".png")
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

function drawRadioSchedule(data, sol, filename)
    radio_campaigns = 8
    mapping = XLSX.readdata("data/data_staffing_constraint.xlsx", "Mapping", "B31:C38")[1:radio_campaigns,:]
    BC_names = unique(mapping[:,1])
    BC = []
    for bc in BC_names
        priorities = []
        for i = 1:radio_campaigns
            if mapping[i,1] == bc
                push!(priorities, i)
            end
        end
        push!(BC, priorities)
    end

    P_names = reverse!(unique(mapping[:,2]))
    num_P_names = length(P_names)
    
    #col = ["blue","red","green","yellow","orange","purple","cyan","magenta","lime","gray","pink"]
    w = data.L_upper - data.L_lower + 1
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

    Drawing((data.T+w)*scalar, height*scalar, "output/schedule_" * filename * ".png")
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



function drawHeatmap(inventory_used, staff_used, data, sol, filename)       
    channels = XLSX.readdata("data/data_inventory_consumption.xlsx", "Mapping", "B2:B13")[1:data.C]
    media = XLSX.readdata("data/data_staffing_constraint.xlsx", "Bemanding", "A2:A5")[1:data.M]
    
    staff_incl_freelancer = data.H + sol.f 
    used_cap_inv = inventory_used ./data.I
    used_cap_prod = staff_used ./staff_incl_freelancer

    pd = pyimport("pandas")
    plt = pyimport("matplotlib.pyplot")
    np = pyimport("numpy")
    sns = pyimport("seaborn")
    ticker = pyimport("matplotlib.ticker")

    py"""
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    import seaborn as sns
    from matplotlib import ticker
    
    def heatmap(used_inv, used_prod, channels, media, filename):
        timesteps = np.arange(1,63)
        
        df1 = pd.DataFrame(np.transpose(used_prod), index = media)#,  columns = timesteps)
        df2 = pd.DataFrame(np.transpose(used_inv), index = channels)#,  columns = timesteps)

        f,(ax1,ax2) = plt.subplots(2,1, figsize = (12,8), gridspec_kw={'height_ratios': [1, 2]})
        
        max_total = max(df1.max().max(),df2.max().max())
        cbar_ax = f.add_axes([.91, .05, .02, .92])
        
        #M = 15
        #xticks = ticker.MaxNLocator(nbins=M, integer=True)
        #print(xticks())
        
        p1 = sns.heatmap(df1, linewidths=.5, ax = ax1, vmin=0, vmax=max_total, cbar_ax = cbar_ax, cmap = 'viridis')
        ax1.xaxis.set_ticks(np.arange(0,62,5))
        ax1.xaxis.set_major_formatter(ticker.FormatStrFormatter('%d'))
        ax1.tick_params(axis = 'x', labelsize=12, rotation=0)
        ax1.tick_params(axis = 'y', labelsize=12)
        ax1.set_xlabel("Time (weeks)")
        ax1.title.set_text('Production hours')
        ax1.set_xlim([0, 62])
        
        

        p2 = sns.heatmap(df2, linewidths=.5, ax = ax2, vmin=0, vmax=max_total, cbar_ax = cbar_ax, cmap = 'viridis') 
        ax2.xaxis.set_ticks(np.arange(0,62,5))
        ax2.xaxis.set_major_formatter(ticker.FormatStrFormatter('%d'))
        ax2.tick_params(axis = 'x', labelsize=12, rotation=0)
        ax2.tick_params(axis = 'y', labelsize=12)
        ax2.set_xlabel("Time (weeks)")
       
        ax2.title.set_text('Channel inventory')
        
        f.tight_layout(rect=[0, 0, .9, 1])

        plt.savefig("output/" + filename + ".png")
        plt.show()
    """

    py"heatmap"(used_cap_inv, used_cap_prod, channels, media, filename)

end

function chosenDestroyRepair(params)
    py"""
    # import pandas as pd
    # import numpy as np
    # import matplotlib.pyplot as plt
    # import seaborn as sns
    # from matplotlib import ticker
    
    def destroyRapairHist(params):
        plt.hist(params.destroys)

        
        plt.show()
    """
    py"destroyRapairHist"(params)
end



function plotScope(data, sol, filename)
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
    if Sys.isapple()
        savefig(p, "output/scope_" * filename * ".png")
    end

end

