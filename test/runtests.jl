using XMLRPC
using LightXML
using Requests
using Base.Test

# Use the Odoo demo instance for testing

v = XMLRPCProxy("http://demo.odoo.com/")
@test v.url == "http://demo.odoo.com/"


a = v["test"](23,10)
@test a.method.name == "test"
@test a.parameters == (23,10)


b = v["test"]("foo", Any[])
@test b.parameters == ("foo", Any[])

@show string(XMLDocument(b))

@show res = post(XMLRPCProxy("https://odoo.ultimachine.com/xmlrpc/2/common")["version"]())
@show readall(res)
res = post(XMLRPCProxy("https://odoo.ultimachine.com/xmlrpc/2/common")["version"]())
@show typeof(res)
