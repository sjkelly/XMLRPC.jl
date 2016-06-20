using XMLRPC
using Base.Test

# Use the Odoo demo instance for testing

v = XMLRPCProxy("http://demo.odoo.com/start")
v.url == "http://demo.odoo.com/start"

res = v["start"]()

@test typeof(res) == Dict{Any, Any}

url = res["host"]
pw = res["password"]
db = res["database"]
un = res["user"]

common = XMLRPCProxy(url*"/xmlrpc/2/common")

uid = common["authenticate"](db, un, pw, [])

models = XMLRPCProxy(url*"/xmlrpc/2/object")

b = models["execute_kw"](db, uid, pw,
    "res.partner", "check_access_rights",
    ["read"], Dict("raise_exception"=> false))

@test b == true

c = models["execute_kw"](db, uid, pw,
    "res.partner", "search",
    Any[Any[Any["is_company", "=", true], Any["customer", "=", true]]])

@test typeof(c) == Vector{Any}
@test typeof(c[1]) == Int32
