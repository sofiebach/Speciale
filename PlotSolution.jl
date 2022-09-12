include("ReadWrite.jl")
using Luxor


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

    scalar = 100
    height = 50
    c = 2
    w = data.L_upper
    Drawing((data.T+w)*scalar, height*scalar, "output/schedule.png")
    background("white") # color of background
    origin() 

    translate(-(data.T+w)*scalar/2, -height*scalar/2)

    colors = ["blue", "red", "green", "yellow", "orange", "purple","cyan", "magenta", "lime"]
  
    fontsize(70)
    sethue("black")

    for t = 1:data.T+w
        time = t-data.start+1
        #rect((t-1) * scalar,(c-1) * scalar ,1,(height) * scalar, :fill)
        if time > 0
            text(string(time), Point((t)*scalar,1 * scalar), halign=:center)
        end
    end

    row_start = 2

    fontsize(80)
    for bc = 1:length(BC)
        rect(0,(c-0.5)*scalar,(data.T+w)*scalar,5, :fill)
        text(string(BC_names[bc]), Point((0.5)*scalar,(c+0.5) * scalar), halign=:left)
        ends = ones(1)*w
        for t = 1:data.T
            for p in BC[bc]
                if sol.x[t,p] != 0
                    priority = mapping[p,2]
                    for n = 1:sol.x[t,p]
                        isPlaced = false
                        for e = 1:length(ends)
                            if t >= ends[e]
                                setcolor(colors[bc])
                                setopacity(0.5)
                                rect(t*scalar, (row_start+e-1)*scalar, w*scalar, 0.8*scalar,:fill)
                                sethue("black")
                                rect(t*scalar, (row_start+e-1)*scalar, w*scalar, 0.8*scalar,:stroke)
                                text(string(priority), Point(t*scalar, (row_start+e-1)*scalar), halign=:left)
                                ends[e] = t + w
                                isPlaced = true
                                break
                            end
                        end
                        if isPlaced == false
                            c += 1
                            sethue(colors[bc])
                            setopacity(0.5)
                            rect(t*scalar, c*scalar, w*scalar, 0.8*scalar,:fill)
                            sethue("black")
                            rect(t*scalar, c*scalar, w*scalar, 0.8*scalar,:stroke)
                            text(string(priority), Point(t*scalar, c*scalar), halign=:left)
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