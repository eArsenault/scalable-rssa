import JSON
include("init_json.jl")
include("value_iteration.jl")

#filename
fname = "json/exp_test.json"
j = String(read(fname))
obj = JSON.parse(j)

initialize(obj)
value_iteration(obj)