using XMLRPC
using Test

const urlEndpoint = "http://betty.userland.com/RPC2"
proxy = XMLRPC.Proxy(urlEndpoint)

@test proxy["examples.getStateName"](23) == "Minnesota"

#@show proxy["examples.getStateList"]([15, 25, 35, 45]) #TODO

@test proxy["examples.getStateNames"](12, 22, 32, 42) == "Idaho\nMichigan\nNew York\nTennessee"

@show proxy["examples.getStateStruct"](Dict("a" => 22, "b" => 48)) == "" #TODO

@test_throws Exception proxy["doesNotExist"]()

