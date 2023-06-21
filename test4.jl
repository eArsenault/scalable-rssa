using HDF5
import JSON
include("scenarios.jl")

#=
(i) This code initializes an experiment in the form of an HDF5 file.
(ii) These files are then used in value_iteration.jl.
=#

function compute_J_init(obj)
    #this function takes the scenario_code, gets the appropriate cost function
    #the cost function is then mapped to a grid over the state space with appropriate size

    #read data from pars
    (Xl, Zl) = ([obj["X"][j][i] for i=1:2, j=1:length(obj["X"])], obj["Z"])
    dimS = size(Xl)[2] + 1 #plus one for dimension Z

    #generate a linear interpolator object on X using values in J
    nJ = obj["J"] #number of grid points along each dim
    X = [[collect(range(Xl[1,i], Xl[2,i], nJ[i])) for i=1:(dimS - 1)]; [collect(range(Zl[1], Zl[2], nJ[dimS]))]]
    J = zeros(Tuple(nJ))

    cost = get_cost(obj["scenario_code"])
    u = zeros(dimS)

    for xc in CartesianIndices(J)
        #convert index into corresponding x-value
        coords = Tuple(xc)
        x = [X[i][coords[i]] for i=1:dimS]

        J[xc] = cost(x,u)
    end

    return J
end

#filename
fname = "json/exp_test.json"
j = String(read(fname))
obj = JSON.parse(j)

name = obj["name"]*".h5"

#(all dummy values for now)!!
#define horizon N, size of C as integers
N = obj["N"]
s_num = obj["s_num"]

#define X, Z, and C ranges 
#ensure upper limit on Z is maximum cost value
Zlim = convert(Array{Float64}, obj["Z"])

#how many grid points in Z do we allocate in the file system? number of times VI is run
#we'll have z_grid + 1 vfuncs in the end, but the result for s == bar c is identically zero 
s_vals = collect(range(Zlim[1], Zlim[2], s_num + 1))

#define initial value function
#J_init should have dimension = dimX + 1
J_init = 5.0 * ones((10,10,10,5)) 

#open the file in write-mode allows us to overwrite if the file exists
h5open("data/"*name, "w") do file
    #create group and write in initial data
    g_init = create_group(file, "init")
    g_init["size_C"] = obj["size_C"]
    g_init["Xlim"] = [obj["X"][j][i] for i=1:2, j=1:length(obj["X"])]
    g_init["Ulim"] = [obj["U"][j][i] for i=1:2, j=1:length(obj["U"])]
    g_init["Zlim"] = Zlim
    g_init["n"] = obj["n"]
    g_init["m"] = obj["m"]

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
    attributes(file)["scenario_code"] = obj["scenario_code"]
    attributes(file)["method"] = obj["method"]
    attributes(file)["kernel"] = obj["kernel"]
    attributes(file)["s_num"] = s_num
    attributes(file)["N"] = N
end

println("Experiment "*name*" initialized.")