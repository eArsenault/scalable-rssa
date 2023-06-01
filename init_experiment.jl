using HDF5

#=
(i) This code initializes an experiment in the form of an HDF5 file.
(ii) These files are then used in value_iteration.jl.
=#

#define experiment name, scenario code, method
name = "exp_test.h5"
scenario_code = "test"
method = "exact"
kernel = "null" #if not using a kernel method, leave as "null" (empty valued attributes aren't supported)

#(all dummy values for now)!!
#define horizon N, size of C as integers
N = 10
size_C = 10

#sampling points for EVL
n = 1000
m = 100

#define X, Z, and C ranges 
#ensure upper limit on Z is maximum cost value
Xlim = hcat([0.0, 10.0], [0.0, 10.0], [0.0, 10.0])
Ulim = hcat([0.0, 1.0], [0.0, 1.0], [0.0, 1.0])
Zlim = [0.0, 5.0]

#how many grid points in Z do we allocate in the file system? number of times VI is run
#we'll have z_grid + 1 vfuncs in the end, but the result for s == bar c is identically zero 
s_num = 20 
s_vals = collect(range(Zlim[1], Zlim[2], s_num + 1))

#define initial value function
#J_init should have dimension = dimX + 1
J_init = 5.0 * ones((10,10,10,5)) 

#open the file in write-mode allows us to overwrite if the file exists
h5open("data/"*name, "w") do file
    #create group and write in initial data
    g_init = create_group(file, "init")
    g_init["size_C"] = size_C
    g_init["Xlim"] = Xlim
    g_init["Ulim"] = Ulim
    g_init["Zlim"] = Zlim
    g_init["n"] = n
    g_init["m"] = m

    file["progress"] = "s1/J"*string(N)
    file["complete"] = "no"

    #create a group for each s-value
    for i in 1:(s_num + 1)
        s = s_vals[i]

        g = create_group(file, "s"*string(i))
        g["J"*string(N)] = max.(J_init .- s, 0.0)
        attributes(g)["value"] = s
    end

    #write attributes to the file
    attributes(file)["scenario_code"] = scenario_code
    attributes(file)["method"] = method
    attributes(file)["kernel"] = kernel
    attributes(file)["s_num"] = s_num
    attributes(file)["N"] = N
end

println("Experiment "*name*" initialized.")