-- Reporter by Tyguy

util.AddNetworkString("reporter_sendtext")
util.AddNetworkString("reporter_openmenu")
util.AddNetworkString("reporter_sendreport")

file.CreateDir("reporter")
file.CreateDir("reporter/crashrestartlog")
file.CreateDir("reporter/reports")
file.CreateDir("reporter/damagelog")
file.Write("reporter/damagelog/damagelog.txt", " ")
file.Write("reporter/crashrestartlog/crashlog.txt", " ")

hook.Add("Initialize", "reporter_callcrashedorrestart", function()
file.Append("reporter/crashrestartlog/crashlog.txt", os.date().." - The server crashed or was restarted")
end )

hook.Add("PlayerInitialSpawn", "reporter_playerjoined", function(ply)
ply.PropKillAttemptWarnings = 0
net.Start("reporter_sendtext")
net.WriteString(AdvertReporter)
net.Send(ply)

	for k,v in pairs(player.GetAll()) do
		if v:IsSuperAdmin() then
		net.Start("reporter_sendtext")
		net.WriteString("Player "..ply:Nick().." has joined with the SteamID "..ply:SteamID().." ("..ply:IPAddress()..")")
		net.Send(v)
		elseif v:IsAdmin() then
		net.Start("reporter_sendtext")
		net.WriteString("Player "..ply:Nick().." has joined with the SteamID "..ply:SteamID())
		net.Send(v)
		end
	end
end )

hook.Add("PlayerSpawnedProp", "reporter_savepropowner", function(ply, model, ent)
	if !ply.ReporterBlockedProps then
	ent.ReporterOwner = ply
	ent.ReporterOwnerName = ply:Nick()
	ent.ReporterOwnerID = ply:SteamID()
	ent.ReporterOwnerIP = ply:IPAddress()
	else
	ent:Remove()
	end
end )

hook.Add("PlayerShouldTakeDamage", "reporter_playertookdamage", function(victim, attacker)
	if PropKillReporter:GetInt() == 1 then 
	local propowner = attacker.ReporterOwner
		if attacker:IsProp() then 
		attacker:Remove()
			for o,d in pairs(player.GetAll()) do
				if d == propowner then
				d.PropKillAttemptWarnings = d.PropKillAttemptWarnings + 1
					if d.PropKillAttemptWarnings != PropKillWarnings:GetInt() then
					net.Start("reporter_sendtext")
					net.WriteString("Please don't propkill! "..d.PropKillAttemptWarnings.."/"..PropKillWarnings:GetInt())
					net.Send(d)
						for e,r in pairs(player.GetAll()) do
							if r:IsAdmin() and r != d then
							net.Start("reporter_sendtext")
							net.WriteString("Player "..d:Nick().." has attempted to propkill and is now on "..d.PropKillAttemptWarnings.."/"..PropKillWarnings:GetInt().." warnings")
							net.Send(r)
							end
						end
					elseif d.PropKillAttemptWarnings >= PropKillWarnings:GetInt() and Reporter.KickPlayer then
					d:Kick(d.PropKillAttemptWarnings.."/"..PropKillWarnings:GetInt().." propkill warnings.")
						for k,v in pairs(player.GetAll()) do
						net.Start("reporter_sendtext")
						net.WriteString("Player "..d:Nick().." has been kicked for reaching the propkill warnings limit ("..d:SteamID()..")")
						net.Send(v)
						end
					elseif d.PropKillAttemptWarnings >= PropKillWarnings:GetInt() and Reporter.AlertAdmins then
						for k,v in pairs(player.GetAll()) do
							if v:IsAdmin() then
							net.Start("reporter_sendtext")
							net.WriteString(d:Nick().." has reached over the propkill warnings!")
							net.Send(v)
							end
						end
					end
				end
			end
		return false
		end
	end
end )

-- Derma

local ChatLogs = 
{}

hook.Add("PlayerSay", "reporter_chatcommands", function(ply, text)
	if text == "!report" then
	net.Start("reporter_openmenu")
	net.WriteString(ply:Nick())
	net.WriteString(ply:SteamID())
	net.WriteString(ply:IPAddress())
	net.Send(ply)
	end
	if text == "!reports" and ply:IsAdmin() then
	local toread = file.Find("reporter/reports/*.txt", "DATA")
		for k,v in pairs(toread) do
		local read = "reporter/reports/"..v
		ply:PrintMessage(HUD_PRINTCONSOLE, file.Read(read, "DATA"))
		end
	end
table.insert(ChatLogs, os.date().." - "..ply:SteamID().." - "..ply:Nick()..": "..text)
end )

net.Receive("reporter_sendreport", function()
local name = net.ReadString()
local idplay = net.ReadString()
local namefield = net.ReadString()
local idfield = net.ReadString()
local reasonfield = net.ReadString()


local towrite1 = "-"..os.date().."-".." Player "..name.." sent in a report ("..idplay..") \n Name: "..namefield.."\n SteamID: "..idfield.."\n Reason: "..reasonfield
local towrite = "reporter/reports/"..string.gsub(idplay, ":", "-").."-"..tostring(CurTime())..".txt"
file.Write(towrite, towrite1)
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
		net.Start("reporter_sendtext")
		net.WriteString(towrite1)
		net.Send(v)
		end
	end
end )


--Bombs (ConVar enabled/disabled)

local BombProps =
{
"models/props_phx/mk-82.mdl",
"models/props_phx/torpedo.mdl",
"models/props_phx/ww2bomb.mdl",
"models/props_phx/oildrum001_explosive.mdl",
"models/props_phx/cannonball.mdl",
"models/props_c17/oildrum001_explosive.mdl",
"models/props_junk/gascan001a.mdl",
"models/props_junk/propane_tank001a.mdl",
}

hook.Add("PlayerSpawnProp", "reporter_blockbadprops", function(ply, mdl)
	if BombPropsBlocked:GetInt() == 1 then
		for k,v in pairs(BombProps) do
			if mdl == v then
			net.Start("reporter_sendtext")
			net.WriteString("You cannot spawn bomb props")
			net.Send(ply)
				for o,d in pairs(player.GetAll()) do
					if d:IsAdmin() and d != ply then
					d:PrintMessage(HUD_PRINTCONSOLE, "Player "..ply:Nick().." has attempted to spawn a bomb prop")
					end
				return false
				end
			end
		end
	end
end )

-- AI

concommand.Add("reporter_execute", function(ply, cmd, args)
if #args != 2 then return end
if not ply:IsSuperAdmin() then return end
	if args[1] == "freeze" then
		for k,v in pairs(player.GetAll()) do
			if v:Nick() == args[2] then
			v:Lock()
			net.Start("reporter_sendtext")
			net.WriteString("Player frozen.")
			net.Send(ply)
			end
		end
	end
	if args[1] == "unfreeze" then
		for k,v in pairs(player.GetAll()) do
			if v:Nick() == args[2] then
			v:UnLock()
			net.Start("reporter_sendtext")
			net.WriteString("Player Unfrozen.")
			net.Send(ply)
			end
		end
	end
	if args[1] == "stopprops" then
		for k,v in pairs(player.GetAll()) do
			if v:Nick() == args[2] then
			v.ReporterBlockedProps = true
			net.Start("reporter_sendtext")
			net.WriteString("Player Prop Spawn Blocked.")
			net.Send(ply)
			end
		end
	end
	if args[1] == "allowprops" then
		for k,v in pairs(player.GetAll()) do
			if v:Nick() == args[2] then
			v.ReporterBlockedProps = false
			net.Start("reporter_sendtext")
			net.WriteString("Player Prop Spawn Unblocked.")
			net.Send(ply)
			end
		end
	end
end )

--Damagelog

local DamageLogTable = 
{}


--Copy and paste this after the last file.Append to make a new statement:
--if target:IsPlayer() and killer:IsPlayer() and IsValid(target) and IsValid(killer) then
--And then put your result.

hook.Add("EntityTakeDamage", "reporter_damagelog", function(target, dmginfo)
	if DamageLog:GetInt() == 1 then
	local killer = dmginfo:GetAttacker()
	local damage = dmginfo:GetDamage()
		if target:IsPlayer() and killer:IsPlayer() and IsValid(target) and IsValid(killer) then
		local toinsert_damagelog = os.date().." - "..target:Nick().." took "..damage.." damage from "..killer:Nick()
		table.insert(DamageLogTable, toinsert_damagelog)
			if DamageLogSaving:GetInt() == 1 then
			file.Append("reporter/damagelog/damagelog.txt", toinsert_damagelog.."\n")
			end
		end
		if target:IsPlayer() and dmginfo:IsFallDamage() and IsValid(target) then
		local toinsert_damagelogfall = os.date().." - "..target:Nick().." took "..damage.." damage from Fall Damage"
		table.insert(DamageLogTable, toinsert_damagelogfall)
			if DamageLogSaving:GetInt() == 1 then
			file.Append("reporter/damagelog/damagelog.txt", toinsert_damagelogfall.."\n")
			end
		end
		if target:IsPlayer() and killer:IsProp() and IsValid(target) then
		local toinsert_damagelogprop = os.date().." - "..target:Nick().." took "..damage.." damage from a prop (Model: "..killer:GetModel().." - Owned by "..killer.ReporterOwnerName.." - "..killer.ReporterOwnerID..")"
		table.insert(DamageLogTable, toinsert_damagelogprop)
			if DamageLogSaving:GetInt() == 1 then
			file.Append("reporter/damagelog/damagelog.txt", toinsert_damagelogprop.."\n")
			end
		end
	end
end )

hook.Add("PlayerDeath", "reporter_adddamagelogdeath", function(killer, victim)
	if DamageLog:GetInt() == 1 then
	table.insert(DamageLogTable, os.date().." - "..killer:Nick().." died.")
		if DamageLogSaving:GetInt() == 1 then
		file.Append("reporter/damagelog/damagelog.txt", os.date().." - "..killer:Nick().." died.")
		end
	end
end )

concommand.Add("reporter_damagelog", function(ply, cmd, args)
if not ply:IsSuperAdmin() then return end
	for k,v in pairs(DamageLogTable) do
	ply:PrintMessage(HUD_PRINTCONSOLE, v)
	end
end )

concommand.Add("reporter_cleardamagelog", function(ply, cmd, args)
if not ply:IsSuperAdmin() then return end
table.Empty(DamageLogTable)
net.Start("reporter_sendtext")
net.WriteString("Damagelogs cleared")
net.Send(ply)
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() and v != ply then
		net.Start("reporter_sendtext")
		net.WriteString("Damagelogs cleared by "..ply:Nick().. " ("..ply:SteamID()..")")
		net.Send(v)
		end
	end
end )

--Chat Logs
concommand.Add("reporter_chatlogs", function(ply)
if not ply:IsSuperAdmin() then return end
	for k,v in pairs(ChatLogs) do
	ply:PrintMessage(HUD_PRINTCONSOLE, v)
	end
end )

concommand.Add("reporter_clearchatlogs", function(ply)
if not ply:IsSuperAdmin() then return end
table.Empty(ChatLogs)
net.Start("reporter_sendtext")
net.WriteString("Chatlogs cleared")
net.Send(ply)
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() and v != ply then
		net.Start("reporter_sendtext")
		net.WriteString("Chatlogs cleared by "..ply:Nick().. " ("..ply:SteamID()..")")
		net.Send(v)
		end
	end
end )

--

timer.Create("reporter_running", 400, 0, function()
	for k,v in pairs(player.GetAll()) do
	net.Start("reporter_sendtext")
	net.WriteString(AdvertReporter)
	net.Send(v)
	end
end )

--



	
