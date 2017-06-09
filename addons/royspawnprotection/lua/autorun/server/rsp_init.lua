-- Retrieve the spawn protection zone file.
local path = "rsp/" .. game.GetMap() .. ".txt"
local info = util.JSONToTable(file.Read(path, "DATA"))

-- Config.
RSP = {}

RSP.announce = true				-- If true, the player will be notified when they are and are not protected.
RSP.attackerAnnounce = true		-- If true, when somebody attacks somebody who is protected, it will notify them the player is protected.
RSP.attackerNoDamage = true		-- If true, players who are spawn protected cannot do damage to other players.

-- Global variables.
RSP_Protected = {}
RSP_FirstTouch = {}

-- Adds all the spawn protection zones.
local function addZones()
	-- Check if the table is valid.
	if not istable(info) then return end
	
	-- Loop through all the spawn protection zones.
	for k,v in pairs(info) do
		-- Spawn a "spawnprotect" entity.
		local ent = ents.Create("spawnprotect")
		
		-- Check if the entity is vali.
		if ent then
			-- Print a debug message.
			print("[RSP] Spawning a protection zone at: " .. v.pos[1] .. ", " .. v.pos[2] .. ", " .. v.pos[3] .. " with w: " .. v.width .. ", l: " .. v.length .. ", h: " .. v.height)
			
			-- Set the initialize function.
			function ent:Initialize()
				-- Set the entity's solid state.
				self:SetSolid(SOLID_BBOX)
			 
				-- Calculate the vectors for width, length, and height.
				local iMin = Vector(0 - (v.width /2 ), 0 - (v.length / 2), 0 - (v.height / 2))
				local iMax = Vector(v.width / 2, v.length / 2, v.height / 2)
				
				-- Set the entity's collision bounds (use "SetCollisionBounds" for "getpos", not "SetCollisionBoundsWS")
				self:SetCollisionBounds(iMin, iMax)
			end
			
			-- Set the entity's position.
			ent:SetPos(Vector(v.pos[1], v.pos[2], v.pos[3]))
			
			-- Make the entity a trigger so ENT:StartTouch() and ENT:EndTouch() works.
			ent:SetTrigger(true)
			
			-- Set an entity variable tied to the "retouch" key.
			ent.Retouch = v.retouch
			
			-- Spawn the entity.
			ent:Spawn()
			
			-- Activate the entity (not sure if this is needed).
			ent:Activate()
		end
	end
end

-- Checks for all the spawn protection zones.
concommand.Add("spawnzones", function (ply)
	-- Check if the client is an admin.
	if not ply:IsAdmin() then 
		-- Print them a message.
		ply:ChatPrint("[RSP] You do not have access to this command.")
		
		return
	end
	
	-- Print them a message.
	ply:ChatPrint("[RSP] Finding Spawn Protection entities:")
	
	-- Loop through all the "spawnprotect" entities.
	for k,v in pairs(ents.FindByClass("spawnprotect")) do
		-- Print each "spawnprotect" entity (for some reason v:GetPos() returns an error).
		ply:ChatPrint("[RSP] Found #" .. k)
	end
end)

-- Adds spawn protection zones.
concommand.Add("rsp_addzones", function (ply)
	-- Check if the client is an admin.
	if not ply:IsAdmin() then
		-- Print them a message.
		ply:ChatPrint("[RSP] You do not have access to this command.")
		
		return
	end
	
	-- Call the "addZones()" function.
	addZones()
	
	-- Print them a message.
	ply:ChatPrint("[RSP] Added spawn protect zone.")
end)

-- Post Entity hook.
hook.Add("InitPostEntity", "RSP_AddZones", function()
	-- Call the "addZones()" function.
	addZones()
end)

-- Player spawn hook.
hook.Add("PlayerSpawn", "RSP_PlayerSpawn", function(ply)
	-- Reset variables.
	RSP_FirstTouch[ply:EntIndex()] = false
	RSP_Protected[ply:EntIndex()] = false
end)

hook.Add("EntityTakeDamage", "RSP_EntityTakeDamage", function(ent, dmginfo)
	-- CHeck if the entity is a player and if they're protected.
	if (ent:IsPlayer() and RSP_Protected[ent:EntIndex()]) then 
		-- Check if the attacker is a player and if the attackerAnnounce variable is true.
		if (dmginfo:GetAttacker():IsPlayer() and RSP.attackerAnnounce) then
			-- Notify the attacker.
			dmginfo:GetAttacker():ChatPrint("[RSP] " .. ent:Nick() .. " is protected!")
		end
		
		-- Block the damage.
		return true
	end
	
	-- Check if the entity is a player, if the attacker is a player, and if the attacker is protected.
	if (ent:IsPlayer() and dmginfo:GetAttacker():IsPlayer() and RSP_Protected[dmginfo:GetAttacker():EntIndex()]) then
		-- Check if attackerAnnounce variable is true.
		if (RSP.attackerAnnounce) then
			-- Notify the attacker.
			dmginfo:GetAttacker():ChatPrint("[RSP] You are protected! You cannot do any damage!")
		end
		
		-- Block the damage.
		return true
	end
end)

--[[
concommand.Add("getarea", function(ply)
	local p1 = Vector(1228.444580, -7361.541504, -134.968750)
	local p2 = Vector(4020.968750, -4360.031250, -134.968750)
	local c = Vector((p1 + p2) / 2)
	
	print(c)
end)
]]--