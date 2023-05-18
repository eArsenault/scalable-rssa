using HDF5

#basic data for testing
name = "exp_test.h5"

#if value iteration was half-way completed, start at the latest iterate
#must ensure experiment file has been initialized, however
if isfile("data/"*name)
    #open the file
    file = h5open("data/"*name,"r")
    if "vfuncs" in keys(file)
        println("Initialized experiment located.")
        func_strings = keys(file["vfuncs"])
    
        #find the most recent iterate (i.e., smallest t)
        t_min = minimum(map(v -> parse(Int64,v[2:end]), func_strings))
        J = read(file["vfuncs"], "J"*string(t_min))
        close(file)
    else
        println("Initialized experiment located.")
        t_min = read(file["init"], "N")
        J = read(file["init"], "J_init")
        close(file)
        
        println("Saving iterate J"*string(N)*".")
        h5write("data/"*name, "vfuncs/J"*string(N), J)
    end
else
    error("Experiment not initialized.")
end

for t=(t_min-1):-1:0
    #dummy version of Bellman update
    J_new = J + ones((10,10,10,5))
    global J = J_new
    
    println("Bellman Update complete.")

    println("Saving iterate J"*string(t)*".")
    h5write("data/"*name, "vfuncs/J"*string(t), J)
end

