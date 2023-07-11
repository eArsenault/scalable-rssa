import JSON
include("init_json.jl")

#=
(i) This code assumes the original state space S is 2-dimensional, and hence \aug is 3-dimensional
=#

#filename
fname = "json/exp_test.json"
j = String(read(fname))
obj = JSON.parse(j)

function cvar(obj)
   fname = obj["name"]*".h5" 
   s_ids = ["s*"*string(i) for i in 1:(obj["s_num"] + 1)] 

   Zlim = convert(Array{Float64}, obj["Z"])
   s_vals = collect(range(Zlim[1], Zlim[2], obj["s_num"] + 1))
end