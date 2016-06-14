module XMLRPC

using LightXML, Requests
export XMLRPCProxy, XMLRPCMethodCall, XMLRPCCall


"""
An XML RPC Proxy wrapper type for the server URL
"""
immutable XMLRPCProxy
    url::AbstractString
end

"""

"""
immutable XMLRPCMethodCall
    proxy::XMLRPCProxy
    name::AbstractString
end

XMLRPCArguments = Union{Int32, Bool, AbstractString, Float64, DateTime, Dict, Vector} # base64 ommited

"""


"""
immutable XMLRPCCall
    method::XMLRPCMethodCall
    parameters::Vector
end


function Base.getindex(proxy::XMLRPCProxy, s::AbstractString)
    function _(m...)
        XMLRPCCall(XMLRPCMethodCall(proxy, ASCIIString(s)), [m...])
    end
end

function Requests.post(x::XMLRPCCall)
    xdoc = XMLDocument(x)
    post(url(x); headers=Dict("Content-type" => "text/xml"), data=string(xdoc))
end

url(x::XMLRPCCall) = x.method.proxy.url

function LightXML.XMLDocument(x::XMLRPCCall)
    xdoc = XMLDocument()
    xroot = create_root(xdoc, "methodCall")
    xs1 = new_child(xroot, "methodName")
    add_text(xs1, x.method.name)
    params = new_child(xroot, "params")
    for p in x.parameters
        rpc_arg(new_child(params, "param"), p)
    end
    xdoc
end

function rpc_arg(x::XMLElement, p::Int32)
    add_text(new_child(new_child(x, "value"), "i4"), p)
end

function rpc_arg(x::XMLElement, p::Bool)
    add_text(new_child(new_child(x, "value"), "boolean"), p?"true":"false")
end

function rpc_arg(x::XMLElement, p::AbstractString)
    add_text(new_child(new_child(x, "value"), "string"), p)
end

function rpc_arg(x::XMLElement, p::DateTime)
    add_text(new_child(new_child(x, "value"), "dateTime.iso8601"), p)
end

# TODO new_child for base64


end # module
