include("ValidateSolution.jl")
using Luxor


x, obj = readSolution("output/solution.txt")
start = 4
stop = 13
T = 14
P = 6

function drawSolution(x, obj, start, stop)
    scale = 100
    height = sum(x)
    c = 1
    w = 4
    Drawing((T+w)*scale, height*scale, "output/schedule.png")
    background("gray80") # color of background
    origin()

    

    #transform([1 0 0 -1 0 0])
    translate(-(T+w)*scale/2, -height*scale/2)
    colors = ["blue", "blue", "red", "red", "green", "green"]
  
    for t = 1:T+w
        rect((t-1) * scale,0,1,(T+w) * scale, :fill)
    end

    for t = 1:T
        for p = 1:P
            if x[t,p] != 0
                for n = 1:x[t,p]
                    sethue(colors[p])
                    rect((t-1) * scale, (c-1) * scale, w * scale, 0.7  * scale,:fill)
                    sethue("black")
                    rect((t-1) * scale, (c-1) * scale, w * scale, 0.7  * scale,:stroke)
                    c += 1
                end
            end
        end    
    end
    #transform([1 0 0 -1 0 0])
    finish()
    preview()

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

drawSolution(x, obj, start, stop)