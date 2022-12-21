-- Format
-- Jonesloto
-- 2022-04-06

local Format = {}

local FormatTable = {
    "K"; -- 1,000; Example: 1K
    "M"; -- 1,000,000; Example: 1M
    "B"; -- 1,000,000,000; Example: 1B
    "T"; -- 1,000,000,000,000; Example: 1T
    "Q"; -- 1,000,000,000,000,000; Example: 1Q
    "E"; -- 1 * 10 ^ 18 ; Example: 1E
    "Z"; -- 1 * 10 ^ 21 ; Example: 1C
    "Y"; -- 1 * 10 ^ 24 ; Example: 1A
    "X"; -- 1 * 10 ^ 27 ; Example: 1S
    "N"; -- 1 * 10 ^ 30 ; Example: 1X
    "D"; -- 1 * 10 ^ 33 ; Example: 1XK
    "UD"; -- 1 * 10 ^ 36 ; Example: 1XM
    "DD"; -- 1 * 10 ^ 39 ; Example: 1XB
    "TD"; -- 1 * 10 ^ 42 ; Example: 1XT
    "QD"; -- 1 * 10 ^ 45 ; Example: 1XQ
    "PD"; -- 1 * 10 ^ 48 ; Example: 1XE
    "HD"; -- 1 * 10 ^ 51 ; Example: 1XC
    "SD"; -- 1 * 10 ^ 54 ; Example: 1XA
    "OD"; -- 1 * 10 ^ 57 ; Example: 1XS
    "ND"; -- 1 * 10 ^ 60 ; Example: 1Y
    "V"; -- 1 * 10 ^ 63 ; Example: 1YK
    "UV"; -- 1 * 10 ^ 66 ; Example: 1YM
    "DV"; -- 1 * 10 ^ 69 ; Example: 1YB
    "TV"; -- 1 * 10 ^ 72 ; Example: 1YT
    "QV"; -- 1 * 10 ^ 75 ; Example: 1YQ
    "PV"; -- 1 * 10 ^ 78 ; Example: 1YE
    "HV"; -- 1 * 10 ^ 81 ; Example: 1YC
    "SV"; -- 1 * 10 ^ 84 ; Example: 1YA
    "OV"; -- 1 * 10 ^ 87 ; Example: 1YS
    "NV"; -- 1 * 10 ^ 90 ; Example: 1Z
    "TRIG"; -- 1 * 10 ^ 93 ; Example: 1ZK
    "UTRIG"; -- 1 * 10 ^ 96 ; Example: 1ZM
    "DTRIG"; -- 1 * 10 ^ 99 ; Example: 1ZT
    "G^100"; -- 1 * 10 ^ 102 ; Example: 1ZQ
    "G^1K"; -- 1 * 10 ^ 108 ; Example: 1ZE
    "G^1M"; -- 1 * 10 ^ 111 ; Example: 1ZC
    "G^1B"; -- 1 * 10 ^ 114 ; Example: 1ZA
    "G^1T"; -- 1 * 10 ^ 117 ; Example: 1ZS
    "G^1Q"; -- 1 * 10 ^ 120 ; Example: 1G+
}

local function handle_negatives(formattedString, isNegative)
    local newString = formattedString

    if isNegative then
        newString = "-"..formattedString
    end

    return newString
end

local function format_number(n)
    local isNegative = false

    if n < 0 then 
        isNegative = true
        n = math.abs(n)
    end

    if n < 0.01 then return string.format("%g", n) end

	local function decimals(o)
        local numberString = string.format("%.2f", o)
        local decimalString = numberString:reverse():sub(1, 3):reverse()

        if (math.floor(o) + 0.005 > o) or (math.ceil(o) - 0.005 <= o) then
            decimalString = nil
            o = math.floor(o)
        end

        numberString = numberString:reverse():sub(4, #numberString)

        local newString = ""

        for i = 1, #numberString do
            newString ..= numberString:sub(i, i)

            if (i % 3 == 0) and (i ~= #numberString) then
                newString ..= ","
            end
        end

        newString = newString:reverse()

        if decimalString then
            if decimalString:sub(#decimalString, #decimalString) == "0" then
                decimalString = decimalString:sub(1, #decimalString - 1)
            end

            newString ..= decimalString
        end

        return newString
	end
	
	if n < 1e3 then
        return handle_negatives(decimals(n), isNegative)
	else
		local count = 0

		while (n >= 1e3) and (count < #FormatTable) do
			n /= 1000
			count += 1
		end

		return handle_negatives(decimals(n)..FormatTable[count], isNegative)
	end
end

function Format:FormatNum(x: number)
    return format_number(x)
end

return Format