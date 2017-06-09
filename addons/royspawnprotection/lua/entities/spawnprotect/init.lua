-- Add files and such.
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-- Start Touch entity function.
function ENT:StartTouch(ent)
	-- Check if the entity is valid.
	if not IsValid(ent) or not ent:IsPlayer() or RSP_Protected[ent:EntIndex()] then return end
	
	if not self.Retouch and RSP_FirstTouch[ent:EntIndex()] then return end
	
	-- They're protected!
	RSP_Protected[ent:EntIndex()] = true
	
	-- Set FirstTouch to true if it isn't already.
	if not RSP_FirstTouch[ent:EntIndex()] then
		RSP_FirstTouch[ent:EntIndex()] = true
	end
	
	-- Check if announce is set to true.
	if RSP.announce then
		-- Print them a message!
		ent:ChatPrint("[RSP] You are protected!")
	end
end

-- End Touch entity function.
function ENT:EndTouch(ent)
	-- Check if the entity is valid.
	if not IsValid(ent) or not ent:IsPlayer() or not RSP_Protected[ent:EntIndex()] then return end

	-- They're no longer protected!
	RSP_Protected[ent:EntIndex()] = false
	
	-- Check if announce is set to true!
	if RSP.announce then
		-- Print them a message!
		ent:ChatPrint("[RSP] You are no longer protected!")
	end
end