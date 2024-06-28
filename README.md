# XMLRPC

Send and recieve [XMLRPC](https://xmlrpc.com/). The full
spec is currently supported except for fault handling.

## Example

```julia

# https://www.odoo.com/documentation/9.0/api_integration.html

v = XMLRPCProxy("http://demo.odoo.com/start")


res = v["start"]() # call the "start" method on the server

url = res["host"]
pw = res["password"]
db = res["database"]
un = res["user"]

# Call authetication method

common = XMLRPCProxy(url*"/xmlrpc/2/common")

uid = common["authenticate"](db, un, pw, [])

models = XMLRPCProxy(url*"/xmlrpc/2/object")

models["execute_kw"](db, uid, pw,
    "res.partner", "check_access_rights",
    ["read"], Dict("raise_exception"=> false))

models["execute_kw"](db, uid, pw,
    "res.partner", "search",
    Any[Any[Any["is_company", "=", true], Any["customer", "=", true]]])
```
