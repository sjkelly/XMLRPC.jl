using XMLRPC
using LightXML
using Requests
using Base.Test

# http://validator.xmlrpc.com/

v = XMLRPCProxy("http://validator.xmlrpc.com/")
@test v.url == "http://validator.xmlrpc.com/"


a = v["test"](23,10)
@test a.method.name == "test"
@test a.parameters == [23,10]


b = v["test"]("foo")
@test b.parameters == ["foo"]

@show string(XMLDocument(b))

@show res = post(XMLRPCProxy("https://odoo.ultimachine.com/xmlrpc/2/common")["version"]())
@show readall(res)
