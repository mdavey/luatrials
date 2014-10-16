

-- Take a string, break into bytes, and return them
-- as a string seperated by a space
local function string_to_hex(s)
    local bytes = {}

    for i = 1, s:len(), 1 do
        local code = s:sub(i, i):byte()
        local hex  = string.format("%02X", code)

        table.insert(bytes, hex)
    end

    return table.concat(bytes, ' ')
end


-- given a file and the number of bytes to read at a time
-- returns a string of the hex and safe to print ascii characters
local read_as_hex = coroutine.create(function(f, size)
    while true do
        local buf = f:read(size)

        if buf == nil then break end

        hex_string = string_to_hex(buf)

        -- remove control (%c) characters
        ascii_string = buf:gsub('%c', '?')

        -- If the number of bytes requested is less than the amount read
        -- (e.g. end of file) then pad the hex string before appending
        -- the ascii text
        if buf:len() < size then
            hex_string = hex_string .. string.rep(' ', 3 * (size - buf:len()))
        end

        coroutine.yield(hex_string .. '  ' .. ascii_string)
    end
end)


-- prints a hex dump of a file
local function print_hex_dump(filename)
    f = io.open(filename, 'rb')

    if not f then
        print("Error opening file:", filename)
        os.exit(1)
    end

    while coroutine.status(read_as_hex) ~= 'dead' do
        local _, value = coroutine.resume(read_as_hex, f, 8)

        if value == nil then break end

        print(value)
    end

    f:close()
end


print_hex_dump('01_hello_world.lua')
