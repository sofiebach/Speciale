include("ReadWrite.jl")
using Luxor


data, sol = readSolution("output/solution.txt")

function drawSolution(data, sol)
    scalar = 100
    height = 50
    c = 2
    w = data.L_upper
    Drawing((data.T+w)*scalar, height*scalar, "output/schedule.png")
    background("white") # color of background
    origin()

    BC = []
    BC = push!(BC, collect(1:7))
    BC = push!(BC, collect(8:11))
    BC = push!(BC, [13,14])
    BC = push!(BC, vcat(collect(15:17),[29]))
    BC = push!(BC, collect(18:21))
    BC = push!(BC, collect(22:25))
    BC = push!(BC, [26])
    BC = push!(BC, [27,28])  

    #transform([1 0 0 -1 0 0])
    translate(-(data.T+w)*scalar/2, -height*scalar/2)
    #colors = vcat(repeat(["blue"],7,), repeat(["red"], 5),repeat(["purple"], 2), repeat(["green"], 3),repeat(["pink"], 4), repeat(["yellow"], 4), repeat(["grey"], 1),repeat(["orange"], 2), repeat(["green"], 1))
    #colors = ["black", "blue", "red", "green", "yellow", "orange", "purple"]#, "cyan", "magenta", "lime", "grey", "white"]
    
    colors = ["blue", "red", "green", "yellow", "orange", "purple","cyan", "magenta", "lime"]

    rect(0,(c-1)*scalar,(data.T+w)*scalar,1, :fill)
  
    fontsize(70)
    sethue("black")
    #text("HEJ", Point(100,100), halign=:center, valign = :top)
    for t = 1:data.T+w
        time = t-data.start+1
        #rect((t-1) * scalar,(c-1) * scalar ,1,(height) * scalar, :fill)
        if time > 0
            text(string(time), Point((t)*scalar,1 * scalar), halign=:center)
        end
    end

    row_start = 2

    for bc = 1:length(BC)
        ends = ones(1)*w
        for t = 1:data.T
            for p in BC[bc]
                if sol.x[t,p] != 0
                    for n = 1:sol.x[t,p]
                        isPlaced = false
                        for e = 1:length(ends)
                            if t >= ends[e]
                                println("Put in same row: ", row_start+e-1)
                                println("TIME: ", t)
                                println("END: ", ends[e])
                                setcolor(colors[bc])
                                setopacity(0.5)
                                rect(t * scalar, (row_start+e-1) * scalar, w * scalar, 0.7  * scalar,:fill)
                                sethue("black")
                                rect(t * scalar, (row_start+e-1) * scalar, w * scalar, 0.7  * scalar,:stroke)
                                ends[e] = t + w
                                isPlaced = true
                                break
                            end
                        end
                        if isPlaced == false
                            c += 1
                            println("Put in new row : ", c)

                            sethue(colors[bc])
                            setopacity(0.5)
                            rect(t * scalar, (c) * scalar, w * scalar, 0.7  * scalar,:fill)
                            sethue("black")
                            rect(t * scalar, (c) * scalar, w * scalar, 0.7  * scalar,:stroke)

                            append!(ends,(t+w))
                            println("End of new row", ends[end])
                        end
                        #print(ends)
                    end
                end
            end
            
        end
        c = c+1    
        row_start = row_start + length(ends)
    end

    finish()
    preview()
    #transform([1 0 0 -1 0 0])

    #sethue("black")
#
    #transform([1 0 0 -1 0 0])
    #translate(-data.W*scale/2, -stripheight*scale/2)
    #setopacity(0.5)
#
    #colors = ["black", "blue", "red", "green", "yellow", "orange", "purple", "cyan", "magenta", "lime"]
#
    #for i in 1:data.n
    #    sethue(colors[i%10 + 1])
    #    rect(xcoord[i]*scale, ycoord[i]*scale, data.w[i]*scale, data.h[i]*scale,:fill)
    #    sethue("black")
    #    rect(xcoord[i]*scale, ycoord[i]*scale, data.w[i]*scale, data.h[i]*scale,:stroke)
    #end
#
    ##We need to flip the coordinate system back so numbers are written correctly
    #transform([1 0 0 -1 0 0])
    #fontsize(15)
    #for i in 1:data.n
    #    #Notice (x,-y+5). -y because items were drawn on flipped coordinate system
    #    #+5 to move the numbers closer to the center
    #    text(string(i), Point((xcoord[i]+data.w[i]/2)*scale, -(ycoord[i]+data.h[i]/2)*scale + 5), halign=:center)
    #end
    #scale(1,-1)
    #transform([1 0 0 -1 0 0])
    #terminates and commits the drawing
    #finish()
    #makes a preview in e.g. Atom plot pannel
    #preview()
end

drawSolution(data,sol)