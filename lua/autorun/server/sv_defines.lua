tagre = "reporter" --The tag, don't bother changing it.
PropKillReporter = CreateClientConVar(tagre.."_propkillreporter", 1, true, false) --The ConVar to enable or disable the anti-propkill
PropKillWarnings = CreateClientConVar(tagre.."_propkillwarnings", 3, true, false) --If the anti-propkill is enabled, this is how much warnings you will have before getting kicked.
BombPropsBlocked = CreateClientConVar(tagre.."_blockbombs", 1, true, false) --Enable/disable to block bombs
DamageLog = CreateClientConVar(tagre.."_damagelogcons", 1, true, false) --Enable/disable to log damage
DamageLogSaving = CreateClientConVar(tagre.."_damagelogsaving", 1, true, false) --If logging damage, enable this to save it in a file.

Reporter = {}
Reporter.KickPlayer = false --Should the player be kicked if he has over 3/#propkillwarnings propkill warnings
Reporter.AlertAdmins = true --Should the admins be alerted? (RECOMMENDED)

AdvertReporter = "This server is running Tyguy's Reporter System" --Don't change this please.

local Ent = FindMetaTable("Entity") --Meta Table of Entity

function Ent:IsProp() --Meta function
return self:GetClass() == "prop_physics"
end
