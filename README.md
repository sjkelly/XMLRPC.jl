# XMLRPC

Send and recieve [XMLRPC](https://xmlrpc.com/). The full
spec is currently supported except for fault handling.

## Example

```julia

using XMLRPC

const urlEndpoint = "http://betty.userland.com/RPC2"
proxy = XMLRPC.Proxy(urlEndpoint)

@test proxy["examples.getStateName"](23) == "Minnesota"

@test proxy["examples.getStateNames"](12, 22, 32, 42) == "Idaho\nMichigan\nNew York\nTennessee"

```
