VERSION >= v"0.4.0-dev+6521" && __precompile__(true)

module XMLRPC

using LightXML, Requests
export XMLRPCProxy, XMLRPCMethodCall, XMLRPCCall, xmlrpc_parse


"""
An XML RPC Proxy wrapper type for the server URL.
"""
immutable XMLRPCProxy
    url::AbstractString
end

"""
An XMLRPC call used for dispatch.
"""
immutable XMLRPCMethodCall
    proxy::XMLRPCProxy
    name::AbstractString
end

XMLRPCArguments = Union{Int32, Bool, AbstractString, Float64, DateTime, Dict, Vector} # base64 ommited

"""
A fully determined XMLRPC call with parameters specified
"""
immutable XMLRPCCall
    method::XMLRPCMethodCall
    parameters::Tuple
end


function Base.getindex(proxy::XMLRPCProxy, s::AbstractString)
    function _(m...)
        res = post(XMLRPCCall(XMLRPCMethodCall(proxy, ASCIIString(s)), m))
        h = headers(res)
        h["Content-Type"] == "text/xml" || error("Content is not text/xml!\n"*readall(res))
        r = readall(res)
        xmlrpc_parse(r)
    end
end

"""
Execute an XMLRPC call via HTTP POST.
"""
function Requests.post(x::XMLRPCCall)
    xdoc = XMLDocument(x)
    post(url(x); headers=Dict("Content-type" => "text/xml"), data=string(xdoc))
end

url(x::XMLRPCCall) = x.method.proxy.url

"""
Convert a `XMLRPCCall` into XML.
"""
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

"""
Convert a value, Dict, or Vector into an XMLRPC snippet.
"""
function rpc_arg(x::XMLElement, p::Int32)
    add_text(new_child(new_child(x, "value"), "int"), string(p))
end

function rpc_arg(x::XMLElement, p::Int64)
    add_text(new_child(new_child(x, "value"), "int"), string(Int32(p)))
end

function rpc_arg(x::XMLElement, p::Bool)
    add_text(new_child(new_child(x, "value"), "boolean"), p?"1":"0")
end

function rpc_arg(x::XMLElement, p::Float64)
    add_text(new_child(new_child(x, "value"), "double"), string(p))
end

function rpc_arg(x::XMLElement, p::AbstractString)
    add_text(new_child(new_child(x, "value"), "string"), p)
end

function rpc_arg(x::XMLElement, p::DateTime)
    add_text(new_child(new_child(x, "value"), "dateTime.iso8601"), string(p))
end

# TODO new_child for base64

function rpc_arg(x::XMLElement, p::Vector)
    d = new_child(new_child(x, "array"), "data")
    for e in p
        rpc_arg(d, e)
    end
end

function rpc_arg(x::XMLElement, d::Dict)
    s = new_child(x, "struct")
    for p in d
        rpc_arg(s, p)
    end
end

function rpc_arg(x::XMLElement, p::Pair)
    m = new_child(x, "member")
    n = new_child(m, "name")
    add_text(n, string(p.first))
    rpc_arg(m, p.second)
end

function xmlrpc_parse(s::AbstractString)
    x = parse_string(s)
    xroot = root(x)
    name(xroot) == "methodResponse" || error("malformed XMLRPC response")
    xmlrpc_parse(collect(child_elements(xroot))[1])
end

function xmlrpc_parse(x::XMLElement)
    if name(x) == "value"
        c = collect(child_elements(x))[1]
        if name(c) == "i4" || name(c) == "int"
            return parse(Int32, content(c))
        elseif name(c) == "dateTime.iso8601"
            return DateTime(content(c))
        elseif name(c) == "boolean"
            return content(c) == "true" || content(c) == "1"
        elseif name(c) == "double"
            return parse(Float64, content(c))
        elseif name(c) == "base64"
            return base64decode(content(c))
        elseif name(c) == "string"
            return content(c)
        elseif name(c) == "array"
            c = collect(child_elements(c))[1] # <data>
            arr = []
            for elt in child_elements(c)
                push!(arr, xmlrpc_parse(elt))
            end
            return arr
        elseif name(c) == "struct"
            d = Dict()
            for elt in child_elements(c)
                push!(d, xmlrpc_parse(elt))
            end
            return d
        end
    elseif name(x) == "member"
        c = collect(child_elements(x))
        n = content(c[1]) # name
        v = xmlrpc_parse(c[2]) # value
        return Pair(n,v)
    elseif name(x) == "params" || name(x) == "param" # always one param on return
        return xmlrpc_parse(collect(child_elements(x))[1])
    elseif name(x) == "fault"
        error("XMLRPC Fault:\n$x")
    end
end




end # module
