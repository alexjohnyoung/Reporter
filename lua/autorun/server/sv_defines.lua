tagre = "reporter" --The tag, don't bother changing it.
PropKillReporter = CreateConVar(tagre.."_propkillreporter", 1, true, false) --The ConVar to enable or disable the anti-propkill
PropKillWarnings = CreateConVar(tagre.."_propkillwarnings", 3, true, false) --If the anti-propkill is enabled, this is how much warnings you will have before getting kicked.
BombPropsBlocked = CreateConVar(tagre.."_blockbombs", 1, true, false) --Enable/disable to block bombs
DamageLog = CreateConVar(tagre.."_damagelogcons", 1, true, false) --Enable/disable to log damage
DamageLogSaving = CreateConVar(tagre.."_damagelogsaving", 1, true, false) --If logging damage, enable this to save it in a file.

AdvertReporter = "This server is running Tyguy's Reporter System" --Don't change this please.

local Ent = FindMetaTable("Entity") --Meta Table of Entity

function Ent:IsProp() --Meta function
return self:GetClass() == "prop_physics"
end
