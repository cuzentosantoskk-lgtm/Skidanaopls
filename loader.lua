local pastefy_raw = "https://pastefy.app/0NhYgFqH/raw"
local key_part_a = "0+;p-%d>#*3"

local function getRaw(url)
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not ok then
        warn("Erro HttpGet: "..tostring(res))
        return nil
    end
    return res
end

local bxor = bit32.bxor

local function xor_decode(data, key)
    local result = {}
    local key_len = #key

    for i = 1, #data do
        local byte = string.byte(data, i)
        local key_byte = string.byte(key, ((i - 1) % key_len) + 1)
        result[i] = string.char(bxor(byte, key_byte))
    end

    return table.concat(result)
end

warn("1: Pegando Pastefy")

local data = getRaw(pastefy_raw)
if not data then return end

data = data:gsub("\r",""):gsub("\n","")

warn("2: Lendo ID|KEY")

local pastebin_id, key_part_b = data:match("^([^|]+)|(.+)$")
if not pastebin_id then
    warn("Formato errado no Pastefy: "..data)
    return
end

local key = key_part_a .. key_part_b

warn("3: Pegando Pastebin")

local encrypted = getRaw("https://pastebin.com/raw/"..pastebin_id)
if not encrypted then return end

warn("4: Decodificando")

local ok, decoded = pcall(function()
    return xor_decode(encrypted, key)
end)

if not ok then
    warn("Erro XOR")
    return
end

warn("5: Executando")

local success, err = pcall(function()
    loadstring(decoded)()
end)

if not success then
    warn("Erro final: "..tostring(err))
end
