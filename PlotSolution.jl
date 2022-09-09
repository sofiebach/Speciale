include("ReadWrite.jl")
using Luxor


data, sol = readSolution("output/solution.txt")

function drawSolution(data, sol)
    scalar = 100
    height = 50#sum(sol.x)+2
    c = 2
    w = data.L_upper
    Drawing((data.T+w)*scalar, height*scalar, "output/schedule.png")
    background("white") # color of background
    origin()

    

    #transform([1 0 0 -1 0 0])
    translate(-(data.T+w)*scalar/2, -height*scalar/2)
    #colors = vcat(repeat(["blue"],7,), repeat(["red"], 5)),repeat(["purple"], 2), repeat(["green"], 3),repeat(["pink"], 4), repeat(["yellow"], 4), repeat(["grey"], 1),repeat(["orange"], 2),repeat(["green"], 1)) 
    colors = ["black", "blue", "red", "green", "yellow", "orange", "purple", "cyan", "magenta", "lime", "grey", "white"]
    
    rect(0,(c-1)*scalar,(data.T+w)*scalar,1, :fill)
  
    
    fontsize(70)
    sethue("black")
    #text("HEJ", Point(100,100), halign=:center, valign = :top)
    for t = 1:data.T+w
        time = t-data.start+1
        rect((t-1) * scalar,(c-1) * scalar ,1,(height) * scalar, :fill)
        if time > 0
            text(string(time), Point((t-1)*scalar,1 * scalar), halign=:center)
        end
    end

    row_start = 3
    for p = 2:2
        ends = ones(1)*5
        for t = 1:data.T
            if sol.x[t,p] != 0
                for n = 1:sol.x[t,p]
                    isPlaced = false
                    for e in 1:length(ends)
                        if t >= ends[e]
                            println("Ends: ", ends[e])
                            println("T: ", t)
                            setcolor(colors[p])
                            setopacity(0.5)
                            rect((t-1) * scalar, (row_start+e-1) * scalar, w * scalar, 0.7  * scalar,:fill)
                            sethue("black")
                            rect((t-1) * scalar, (row_start+e-1) * scalar, w * scalar, 0.7  * scalar,:stroke)
                            ends[e] = ends[e] + w
                            isPlaced = true
                            break
                        end
                    end
                    if isPlaced == false    
                        sethue(colors[p])
                        setopacity(0.5)
                        rect((t-1) * scalar, (c) * scalar, w * scalar, 0.7  * scalar,:fill)
                        sethue("black")
                        rect((t-1) * scalar, (c) * scalar, w * scalar, 0.7  * scalar,:stroke)
                        c += 1
                        append!(ends,(t-1+w))
                    end
                    #print(ends)
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