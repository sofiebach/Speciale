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

function drawHeatmap(data, sol, filename, pdf=0, DR=false)  
    cap = deepcopy(sol.H_cap)

    if DR
        staff_incl_freelancer = data.H
    else
        staff_incl_freelancer = data.H + sol.f 
        cap[cap .< 0] .= 0
    end

    used_cap_inv = (data.I .- sol.I_cap) ./ data.I

    used_cap_prod = (staff_incl_freelancer .- cap) ./ staff_incl_freelancer

    if DR 
        used_cap_inv[used_cap_inv .> 1] .= 1.5
        used_cap_prod[used_cap_prod .> 1] .= 1.5
    end

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
    
    def heatmap(used_inv, used_prod, channels, media, filename, pdf):
        timesteps = np.arange(1,(len(used_inv)+1))
        df1 = pd.DataFrame(np.transpose(used_prod), index = media)#,  columns = timesteps)
        df2 = pd.DataFrame(np.transpose(used_inv), index = channels)#,  columns = timesteps)

        f,(ax1,ax2) = plt.subplots(2,1, figsize = (12,8), gridspec_kw={'height_ratios': [1, 2]})
        
        max_total = max(max(df1.max().max(),df2.max().max()),1)
        cbar_ax = f.add_axes([.91, .05, .02, .92])
        
        #M = 15
        #xticks = ticker.MaxNLocator(nbins=M, integer=True)
        #print(xticks())
        fontsize = 18
        
        p1 = sns.heatmap(df1,linewidths=.5, ax = ax1, vmin=0, vmax=max_total, cbar_ax = cbar_ax, cmap = 'viridis')
        ax1.xaxis.set_ticks(np.arange(0,len(used_inv),5))
        ax1.xaxis.set_major_formatter(ticker.FormatStrFormatter('%d'))
        ax1.tick_params(axis = 'x', labelsize=fontsize, rotation=0)
        ax1.tick_params(axis = 'y', labelsize=fontsize)
        ax1.set_xlabel("Time steps", fontsize = fontsize)
        ax1.title.set_text('Used media inventory')
        ax1.title.set_size(fontsize)
        ax1.set_xlim([0, len(used_inv)])
        cbar = ax1.collections[0].colorbar
        cbar.ax.tick_params(labelsize=fontsize)

        p2 = sns.heatmap(df2, linewidths=.5, ax = ax2, vmin=0, vmax=max_total, cbar_ax = cbar_ax, cmap = 'viridis') 
        ax2.xaxis.set_ticks(np.arange(0,len(used_inv),5))
        ax2.xaxis.set_major_formatter(ticker.FormatStrFormatter('%d'))
        ax2.tick_params(axis = 'x', labelsize=fontsize, rotation=0)
        ax2.tick_params(axis = 'y', labelsize=fontsize)
        ax2.set_xlabel("Time steps", fontsize = fontsize)
        cbar = ax2.collections[0].colorbar
        cbar.ax.tick_params(labelsize=fontsize)
       
        ax2.title.set_text('Used channel inventory')
        ax2.title.set_size(fontsize)
        
        f.tight_layout(rect=[0, 0, .9, 1])
        plt.savefig(filename)
        # plt.show()
        plt.close
    """

    py"heatmap"(used_cap_inv, used_cap_prod, data.C_names, data.M_names, filename, pdf)

end

function solutionTracking(params, filename)
    rejected = findall(x -> x <= 0, params.status)
    accepted = findall(x -> x == params.W[2] || x == params.W[3], params.status)
    better = findall(x -> x == params.W[1], params.status)
    
    py"""
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    import seaborn as sns
    from matplotlib import ticker
    
    def solutionPlot(params, rejected, accepted, better, filename):
        plt.figure()
        # plt.plot(rejected[::10], np.array(params.current_obj)[rejected.astype(int)-1][::10], 'bo', markersize = 4)
        plt.plot(accepted[::10], np.array(params.current_obj)[accepted.astype(int)-1][::10],'o',color='tab:blue',markersize = 6)
        plt.plot(better, np.array(params.current_obj)[better.astype(int)-1],'o',color='darkorange',markersize = 6)
        plt.plot(params.current_best,'-',color="black",markersize = 3)
        plt.plot(better, np.array(params.current_obj)[better.astype(int)-1],'o',color='darkorange',markersize = 6)
        # plt.legend(["Rejected", "Accepted", "New best"])
        plt.legend(["Accepted", "New best"], fontsize="15")
        plt.tick_params(axis='x', labelsize=15)
        plt.tick_params(axis='y', labelsize=15)
        plt.savefig(filename)
        # plt.show()
        plt.close
    """
    py"solutionPlot"(params,rejected, accepted, better, filename)
end

function solutionTracking_all(params, filename)
    rejected = findall(x -> x <= 0, params.status)
    accepted = findall(x -> x == params.W[2] || x == params.W[3], params.status)
    better = findall(x -> x == params.W[1], params.status)
    
    py"""
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    import seaborn as sns
    from matplotlib import ticker
    
    def solutionPlot(params, rejected, accepted, better, filename):
        plt.figure()
        #plt.plot(rejected, np.array(params.current_obj)[rejected.astype(int)-1], 'bo', markersize = 4)
        plt.plot(accepted, np.array(params.current_obj)[accepted.astype(int)-1],'o',color='tab:blue',markersize = 6)
        plt.plot(better, np.array(params.current_obj)[better.astype(int)-1],'o',color='darkorange',markersize = 6)
        plt.plot(params.current_best,'-',color="black",markersize = 3)
        plt.plot(better, np.array(params.current_obj)[better.astype(int)-1],'o',color='darkorange',markersize = 6)
        # plt.legend(["Rejected", "Accepted", "New best"])
        plt.legend(["Accepted", "New best"], fontsize="15")
        plt.tick_params(axis='x', labelsize=15)
        plt.tick_params(axis='y', labelsize=15)
        plt.savefig(filename)
        # plt.show()
        plt.close
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
        plt.savefig(filename)
        # plt.show()
        plt.close
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
        probs = params.prob_destroy_it[i][::params.segment]
        segments = range(1,len(probs)+1)
        while i < len(params.num_destroy):
            ax1.plot(segments, params.prob_destroy_it[i][::params.segment])
            ax1.legend(params.destroy_names)
            ax1.set_xlabel("Segments")
            ax1.title.set_text('Probability')
            ax1.title.set_text('Destroy')
            ax1.set_ylim(0,1)
            i += 1
        i = 0
        while i < len(params.num_repair):
            ax2.plot(segments, params.prob_repair_it[i][::params.segment])
            ax2.legend(params.repair_names)
            ax2.set_xlabel("Segments")
            ax2.title.set_text('Probability')
            ax2.title.set_text('Repair')
            ax2.set_ylim(0,1)
            i += 1
        plt.savefig(filename)
        # plt.show()
        plt.close
    """
    py"progDR"(params, filename)
end

function drawTVSchedule(data, sol, filename, plot_channel = 0)
    p_tv = findall(x -> x == "TV", data.campaign_type)
    unique_BC_names = unique(data.BC_names[p_tv])

    if plot_channel != 0
        unique_BC_names = [unique_BC_names[plot_channel]]
    end

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

    w = data.L_upper - data.L_lower + 1
    c = 2
    row_start = 2
    num_BC = length(BC)
    scalar = 100
    h = 0.8
    offset = 5 
    height = 0

    # Initialize height of plot
    c = 2
    row_start = 2
    for bc = 1:num_BC
        ends = ones(1)
        for p in BC[bc]
            if sum(sol.x[:,p]) == 0
                continue
            end
            for t = 1:data.T
                if sol.x[t,p] != 0
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
            ends = ones(1)
            c += 1
            row_start = c
            
        end
        c = c+2    
        row_start = row_start + length(ends) + 1
        height = row_start
    end

    unique_P_names = unique(data.P_names)
    num_P_names = length(unique_P_names)
    
    # width of box
    
    width = data.T+offset + 2
    col = distinguishable_colors(length(unique_P_names)+1)[2:(length(unique_P_names)+1)]

    Drawing(width*scalar, height*scalar, filename)

    background("white") # color of background
    origin() 

    translate(-width*scalar/2, -height*scalar/2)

    fontsize(70)
    sethue("black")

    
    for t = 1:data.T
        time = t
        #rect((t-1) * scalar,(c-1) * scalar ,1,(height) * scalar, :fill)
        if time > 0
            text(string(time), Point((offset + t)*scalar,1 * scalar), halign=:left)
        end
    end

    # Draw lines that indicate period
    sethue("grey50")
    setline(7)
    setdash([70])
   
    Luxor.line(Point((offset + data.start)*scalar, 2*scalar), Point((offset + data.start) *scalar, height*scalar), action = :stroke)
    Luxor.line(Point((offset + data.stop + 1)*scalar, 2*scalar), Point((offset + data.stop+1) *scalar, height*scalar), action = :stroke)
    
    setline(3)
    setdash("solid")

    c = 2
    row_start = 2
    fontsize(80)
    for bc = 1:num_BC
        sethue("black")
        setopacity(1)
        Luxor.rect(1*scalar,(c-0.5)*scalar,(width-2)*scalar,5, :fill)
        text(string(unique_BC_names[bc]), Point(1*scalar,(c+0.5) * scalar), halign=:left)
        ends = ones(1)
        for p in BC[bc]
            if sum(sol.x[:,p]) == 0
                continue
            end
            for t = 1:data.T
                if sol.x[t,p] != 0
                    priority = data.P_names[p]
                    for n = 1:sol.x[t,p]
                        isPlaced = false
                        len_ends = length(ends)
                        for e = 1:len_ends
                            if (t+data.L_lower) >= ends[e]
                                setopacity(1)
                                setcolor("white")
                                Luxor.rect((offset+t+data.L_lower)*scalar, (row_start+e-1)*scalar, w*scalar, h*scalar,:fill)
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
            ends = ones(1)
            c += 1
            row_start = c
            
        end
        c = c+2    
        row_start = row_start + length(ends) + 1
    end

    finish()
    preview()
end



function drawRadioSchedule(data, sol, filename, plot_channel = 0)
    p_radio = findall(x -> x == "RADIO", data.campaign_type)
    unique_BC_names = unique(data.BC_names[p_radio])
    
    if plot_channel != 0
        unique_BC_names = [unique_BC_names[plot_channel]]
    end

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

    w = data.L_upper - data.L_lower + 1
    c = 2
    row_start = 2
    num_BC = length(BC)
    scalar = 100
    h = 0.8
    offset = 5 
    height = 0 

    # Initialize height of plot
    c = 2
    row_start = 2
    for bc = 1:num_BC
        ends = ones(1)
        for p in BC[bc]
            if sum(sol.x[:,p]) == 0
                continue
            end
            for t = 1:data.T
                if sol.x[t,p] != 0
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
            ends = ones(1)
            c += 1
            row_start = c
            
        end
        c = c+2    
        row_start = row_start + length(ends) + 1
        height = row_start
    end

    unique_P_names = unique(data.P_names)
    num_P_names = length(unique_P_names)
    
    # width of box
    
    width = data.T+offset + 2
    col = distinguishable_colors(length(unique_P_names)+1)[2:(length(unique_P_names)+1)]

    Drawing(width*scalar, height*scalar, filename)

    background("white") # color of background
    origin() 

    translate(-width*scalar/2, -height*scalar/2)

    fontsize(70)
    sethue("black")

    
    for t = 1:data.T
        time = t
        #rect((t-1) * scalar,(c-1) * scalar ,1,(height) * scalar, :fill)
        if time > 0
            text(string(time), Point((offset + t)*scalar,1 * scalar), halign=:left)
        end
    end

    # Draw lines that indicate period
    sethue("grey50")
    setline(7)
    setdash([70])
   
    Luxor.line(Point((offset + data.start)*scalar, 2*scalar), Point((offset + data.start) *scalar, height*scalar), action = :stroke)
    Luxor.line(Point((offset + data.stop + 1)*scalar, 2*scalar), Point((offset + data.stop+1) *scalar, height*scalar), action = :stroke)
    
    setline(3)
    setdash("solid")

    c = 2
    row_start = 2
    fontsize(80)
    for bc = 1:num_BC
        sethue("black")
        setopacity(1)
        Luxor.rect(1*scalar,(c-0.5)*scalar,(width-2)*scalar,5, :fill)
        text(string(unique_BC_names[bc]), Point(1*scalar,(c+0.5) * scalar), halign=:left)
        ends = ones(1)
        for p in BC[bc]
            if sum(sol.x[:,p]) == 0
                continue
            end
            for t = 1:data.T
                if sol.x[t,p] != 0
                    priority = data.P_names[p]
                    for n = 1:sol.x[t,p]
                        isPlaced = false
                        len_ends = length(ends)
                        for e = 1:len_ends
                            if (t+data.L_lower) >= ends[e]
                                setopacity(1)
                                setcolor("white")
                                Luxor.rect((offset+t+data.L_lower)*scalar, (row_start+e-1)*scalar, w*scalar, h*scalar,:fill)
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
            ends = ones(1)
            c += 1
            row_start = c
            
        end
        c = c+2    
        row_start = row_start + length(ends) + 1
    end

    finish()
    preview()
end

function plotWparams(params, filename)
    py"""
    import matplotlib.pyplot as plt
    import numpy as np
    def wPlot(params, filename):
        # Repair plot
        labels = params.repair_names
        best = params.w_repair[:,0]
        improving = params.w_repair[:,1]
        accepted = params.w_repair[:,2]
        x = np.arange(len(labels))  # the label locations
        width = 0.2  # the width of the bars
        fig, ax = plt.subplots()
        rects1 = ax.bar(x - width, best, width, label='Best')
        rects2 = ax.bar(x, improving, width, label='Improving')
        rects3 = ax.bar(x + width, accepted, width, label='Accepted')
        ax.set_ylabel('Scores')
        ax.set_title('Scores of repair methods')
        ax.set_xticks(x, labels)
        plt.xticks(rotation=45)
        ax.legend()
        ax.bar_label(rects1, padding=3)
        ax.bar_label(rects2, padding=3)
        ax.bar_label(rects3, padding=3)
        fig.tight_layout()
        plt.savefig(filename)
        #plt.show()
        plt.close

        # Destroy plot
        labels = params.destroy_names
        best = params.w_destroy[:,0]
        improving = params.w_destroy[:,1]
        accepted = params.w_destroy[:,2]
        x = np.arange(len(labels))  # the label locations
        width = 0.2  # the width of the bars
        fig, ax = plt.subplots()
        rects1 = ax.bar(x - width, best, width, label='Best')
        rects2 = ax.bar(x, improving, width, label='Improving')
        rects3 = ax.bar(x + width, accepted, width, label='Accepted')
        ax.set_ylabel('Scores')
        ax.set_title('Scores of repair methods')
        ax.set_xticks(x, labels)
        plt.xticks(rotation=45)
        ax.legend()
        ax.bar_label(rects1, padding=3)
        ax.bar_label(rects2, padding=3)
        ax.bar_label(rects3, padding=3)
        fig.tight_layout()
        plt.savefig(filename)
        #plt.show()
        plt.close
    """
    py"wPlot"(params, filename)
end

function plotWparamsInput(params, w_destroy, w_repair, filename)
    py"""
    import matplotlib.pyplot as plt
    import numpy as np
    def wPlot(params, w_destroy, w_repair, filename):
        # Repair plot
        labels = params.repair_names
        best = w_repair[:,0]
        improving = w_repair[:,1]
        accepted = w_repair[:,2]
        x = np.arange(len(labels))  # the label locations
        width = 0.2  # the width of the bars
        fig, ax = plt.subplots()
        rects1 = ax.bar(x - width, best, width, label='Best')
        rects2 = ax.bar(x, improving, width, label='Improving')
        rects3 = ax.bar(x + width, accepted, width, label='Accepted')
        ax.set_ylabel('Scores')
        ax.set_title('Scores of repair methods')
        ax.set_xticks(x, labels)
        plt.xticks(rotation=45)
        ax.legend()
        ax.bar_label(rects1, padding=3)
        ax.bar_label(rects2, padding=3)
        ax.bar_label(rects3, padding=3)
        fig.tight_layout()
        plt.savefig(filename)
        #plt.show()
        plt.close

        # Destroy plot
        labels = params.destroy_names
        best = w_destroy[:,0]
        improving = w_destroy[:,1]
        accepted = w_destroy[:,2]
        x = np.arange(len(labels))  # the label locations
        width = 0.2  # the width of the bars
        fig, ax = plt.subplots()
        rects1 = ax.bar(x - width, best, width, label='Best')
        rects2 = ax.bar(x, improving, width, label='Improving')
        rects3 = ax.bar(x + width, accepted, width, label='Accepted')
        ax.set_ylabel('Scores')
        ax.set_title('Scores of repair methods')
        ax.set_xticks(x, labels)
        plt.xticks(rotation=45)
        ax.legend()
        ax.bar_label(rects1, padding=3)
        ax.bar_label(rects2, padding=3)
        ax.bar_label(rects3, padding=3)
        fig.tight_layout()
        plt.savefig(filename)
        #plt.show()
        plt.close
    """
    py"wPlot"(params,w_destroy, w_repair, filename)
end


