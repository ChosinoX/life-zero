--!strict
local Util = {}
function Util.levelFromXP(xp: number): number return math.max(1, math.floor(math.sqrt(xp / 100)) + 1) end
function Util.copy(value: any): any
	if type(value) ~= "table" then return value end
	local out = {}; for k,v in pairs(value) do out[k] = Util.copy(v) end; return out
end
function Util.clampNumber(v: any, lo: number, hi: number): number? if type(v) ~= "number" or v ~= v then return nil end return math.clamp(v,lo,hi) end
return Util
