import JSON
include("init_json.jl")
include("value_iteration.jl")

#setup
n_vals = [100] #[100,500,1000,5000,10000]
m_vals = [100] #[100,500,1000,5000,10000]
s_vals = [10] #[10,20,50,100,200,400,499]

#filename
fname = "json/exp_approx.json"
j = String(read(fname))
obj = JSON.parse(j)
name = "ker1"

#NB: use copy(obj) to clone obj, as obj_n = obj just defines obj_n as a pointer to obj
for n in n_vals
    obj_n = copy(obj)
    obj_n["n"] = n
    obj_n["name"] = name * "_n/" * string(n)

    initialize(obj_n)
    value_iteration(obj_n)
end

for m in m_vals
    obj_m = copy(obj)
    obj_m["m"] = m
    obj_m["name"] = name * "_m/" * string(m)

    initialize(obj_m)
    value_iteration(obj_m)
end

for s in s_vals
    obj_s = copy(obj)
    obj_s["s_num"] = s
    obj_s["name"] = name * "_s/" * string(s)

    initialize(obj_s)
    value_iteration(obj_s)
end

