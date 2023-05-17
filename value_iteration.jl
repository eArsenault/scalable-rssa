using HDF5

#basic data for testing
name = "exp_1"
N = 10
J_init = zeros((10,10))

#if value iteration was half-way completed, start at the latest iterate
if isfile("data/"*name)
    #open the file
    file = h5open("data/"*name,"r")
    func_strings = keys(file["vfuncs"])
    
    #find the most recent iterate (i.e., smallest t)
    t_min = minimum(map(v -> parse(Int64,v[2:end]), func_strings))
    J = read(file["vfuncs"], "J"*string(t_min))
    close(file)
else
    t_min = N
    J = J_init
    
    println("Saving iterate J"*string(N)*".")
    h5write("data/"*name, "vfuncs/J"*string(N), J)
    
end

for t=(t_min-1):-1:0
    #dummy version of Bellman update
    J_new = J + ones((10,10))
    global J = J_new
    println("Bellman Update complete.")

    println("Saving iterate J"*string(t)*".")
    h5write("data/"*name, "vfuncs/J"*string(t), J)
end

