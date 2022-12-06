using Luxor
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
    p_tv = findall(x -> x == "TV", data.campaign_type)
    unique_BC_names = unique(data.BC_names[p_tv])

    BC = []
    for bc in unique_BC_names
        priorities = []
        for i in p_tv
            if data.BC_names[i] == bc
                push!(priorities, i)
            end
        end
        push!(BC, priorities)
    end

    unique_P_names = unique(data.P_names)
    num_P_names = length(unique_P_names)
    
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
                    priority = data.P_names
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
    col = distinguishable_colors(length(unique_P_names)+1)[2:(length(unique_P_names)+1)]

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
        text(string(unique_BC_names[bc]), Point((0.5)*scalar,(c+0.5) * scalar), halign=:left)
        ends = ones(1)
        for t = 1:data.T
            for p in BC[bc]
                if sol.x[t,p] != 0
                    priority = data.P_names[p]
                    for n = 1:sol.x[t,p]
                        isPlaced = false
                        len_ends = length(ends)
                        for e = 1:len_ends
                            if (t+data.L_lower) >= ends[e]
                                for prio = 1:num_P_names
                                    if data.P_names[p] == unique_P_names[prio]
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
                                if data.P_names[p] == unique_P_names[prio]
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
    p_radio = findall(x -> x == "RADIO", data.campaign_type)
    unique_BC_names = unique(data.BC_names[p_radio])

    BC = []
    for bc in unique_BC_names
        priorities = []
        for i in p_radio
            if data.BC_names[i] == bc
                push!(priorities, i)
            end
        end
        push!(BC, priorities)
    end

    unique_P_names = unique(data.P_names)
    num_P_names = length(unique_P_names)
    
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
                    priority = data.P_names
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
    col = distinguishable_colors(length(unique_P_names)+1)[2:(length(unique_P_names)+1)]

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
        text(string(unique_BC_names[bc]), Point((0.5)*scalar,(c+0.5) * scalar), halign=:left)
        ends = ones(1)
        for t = 1:data.T
            for p in BC[bc]
                if sol.x[t,p] != 0
                    priority = data.P_names[p]
                    for n = 1:sol.x[t,p]
                        isPlaced = false
                        len_ends = length(ends)
                        for e = 1:len_ends
                            if (t+data.L_lower) >= ends[e]
                                for prio = 1:num_P_names
                                    if data.P_names[p] == unique_P_names[prio]
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
                                if data.P_names[p] == unique_P_names[prio]
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
        timesteps = np.arange(1,(len(used_inv)+1))
        df1 = pd.DataFrame(np.transpose(used_prod), index = media)#,  columns = timesteps)
        df2 = pd.DataFrame(np.transpose(used_inv), index = channels)#,  columns = timesteps)

        f,(ax1,ax2) = plt.subplots(2,1, figsize = (12,8), gridspec_kw={'height_ratios': [1, 2]})
        
        max_total = max(df1.max().max(),df2.max().max())
        cbar_ax = f.add_axes([.91, .05, .02, .92])
        
        #M = 15
        #xticks = ticker.MaxNLocator(nbins=M, integer=True)
        #print(xticks())
        
        p1 = sns.heatmap(df1, linewidths=.5, ax = ax1, vmin=0, vmax=max_total, cbar_ax = cbar_ax, cmap = 'viridis')
        ax1.xaxis.set_ticks(np.arange(0,len(used_inv),5))
        ax1.xaxis.set_major_formatter(ticker.FormatStrFormatter('%d'))
        ax1.tick_params(axis = 'x', labelsize=12, rotation=0)
        ax1.tick_params(axis = 'y', labelsize=12)
        ax1.set_xlabel("Time (weeks)")
        ax1.title.set_text('Production hours')
        ax1.set_xlim([0, len(used_inv)])
        
        

        p2 = sns.heatmap(df2, linewidths=.5, ax = ax2, vmin=0, vmax=max_total, cbar_ax = cbar_ax, cmap = 'viridis') 
        ax2.xaxis.set_ticks(np.arange(0,len(used_inv),5))
        ax2.xaxis.set_major_formatter(ticker.FormatStrFormatter('%d'))
        ax2.tick_params(axis = 'x', labelsize=12, rotation=0)
        ax2.tick_params(axis = 'y', labelsize=12)
        ax2.set_xlabel("Time (weeks)")
       
        ax2.title.set_text('Channel inventory')
        
        f.tight_layout(rect=[0, 0, .9, 1])

        plt.savefig("output/" + filename + ".png")
        # plt.show()
    """

    py"heatmap"(used_cap_inv, used_cap_prod, data.C_names, data.M_names, filename)

end

function solutionTracking(params, filename)

    rejected = findall(x -> x <= 1, params.status)
    accepted = findall(x -> x == 5, params.status)
    better = findall(x -> x == 10, params.status)
    
    py"""
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    import seaborn as sns
    from matplotlib import ticker
    
    def solutionPlot(params, rejected, accepted, better, filename):
        plt.figure()
        plt.plot(rejected[::10], np.array(params.current_obj)[rejected.astype(int)-1][::10], 'bo', markersize = 4)
        plt.plot(accepted[::10], np.array(params.current_obj)[accepted.astype(int)-1][::10], 'yo', markersize = 4)
        plt.plot(better, np.array(params.current_obj)[better.astype(int)-1], 'ro', markersize = 4)
        plt.plot(params.current_best, 'k-' , markersize = 4)
        plt.legend(["Rejected", "Accepted", "New best"])
        plt.savefig("output/" + filename + ".png")
        # plt.show()
    """
    py"solutionPlot"(params,rejected, accepted, better, filename)
end

function solutionTracking_all(params, filename)

    rejected = findall(x -> x <= 1, params.status)
    accepted = findall(x -> x == 5, params.status)
    better = findall(x -> x == 10, params.status)
    
    py"""
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    import seaborn as sns
    from matplotlib import ticker
    
    def solutionPlot(params, rejected, accepted, better, filename):
        plt.figure()
        plt.plot(rejected, np.array(params.current_obj)[rejected.astype(int)-1], 'bo', markersize = 4)
        plt.plot(accepted, np.array(params.current_obj)[accepted.astype(int)-1], 'yo', markersize = 4)
        plt.plot(better, np.array(params.current_obj)[better.astype(int)-1], 'ro', markersize = 4)
        plt.plot(params.current_best, 'k-' , markersize = 4)
        plt.legend(["Rejected", "Accepted", "New best"])
        plt.savefig("output/" + filename + ".png")
        # plt.show()
    """
    py"solutionPlot"(params,rejected, accepted, better, filename)
end



function temperatureTracking(params, filename)

   
    py"""
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    import seaborn as sns
    from matplotlib import ticker
    
    def tempPlot(params, filename):
        plt.figure()
        plt.plot(params.T_it)
        plt.savefig("output/" + filename + ".png")
        # plt.show()
    """
    py"tempPlot"(params, filename)
end

function probabilityTracking(params, filename)
   
    py"""
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    import seaborn as sns
    from matplotlib import ticker

    def progDR(params, filename):
        f,(ax1,ax2) = plt.subplots(2,1, figsize = (10,10))
        i = 0
        iter = range(1,len(params.prob_destroy_it[0]) + 1,10)
        while i < len(params.num_destroy):
            ax1.plot(iter, params.prob_destroy_it[i][::10])
            ax1.legend(params.destroy_names)
            ax1.set_xlabel("Iterations")
            ax1.title.set_text('Probability')
            ax1.title.set_text('Destroy')
            i += 1
        i = 0
        while i < len(params.num_repair):
            ax2.plot(iter, params.prob_repair_it[i][::10])
            ax2.legend(params.repair_names)
            ax2.set_xlabel("Iterations")
            ax2.title.set_text('Probability')
            ax2.title.set_text('Repair')
            i += 1
        plt.savefig("output/" + filename + ".png")
        # plt.show()
    """
    py"progDR"(params, filename)
end

function plotScope(data, sol, filename)
    total = sum(sol.x, dims=1)
    BC_names = unique(data.BC_names)
    num_BC = length(BC_names)
    campaign_names = unique(data.P_names)
    num_campaigns = length(campaign_names)
    output = zeros(Float64, length(BC_names), length(campaign_names))*NaN
    for p = 1:data.P
        for bc = 1:num_BC
            for campaign = 1:num_campaigns
                if data.BC_names[p] == BC_names[bc] && data.P_names[p] == campaign_names[campaign]
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

