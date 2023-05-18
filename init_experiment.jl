using HDF5

#define experiment name, scenario code, method
name = "exp_test.h5"
scenario_code = "water3x3"
method = "exact"

#(all dummy values for now)!!
#define horizon N, size of C
N = 10
size_C = 1000

#define X, Z, and C ranges 
#ensure upper limit on Z is maximum cost value
Xlim = hcat([0.0, 10.0], [0.0, 10.0], [0.0, 10.0])
Ulim = hcat([0.0, 1.0], [0.0, 1.0], [0.0, 1.0])
Zlim = [0.0, 5.0]

#define initial value function
#J_init should have dimension = dimX + 1
J_init = zeros((10,10,10,5)) 

#open the file in write-mode allows us to overwrite if the file exists
file = h5open("data/"*name, "w")

#create group and write in initial data
g_init = create_group(file, "init")
g_init["N"] = N
g_init["size_C"] = size_C
g_init["Xlim"] = Xlim
g_init["Ulim"] = Ulim
g_init["Zlim"] = Zlim
g_init["J_init"] = J_init

#write attributes to the file
attributes(file)["scenario_code"] = scenario_code
attributes(file)["method"] = method

close(file)