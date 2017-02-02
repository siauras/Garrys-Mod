AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function update_client( ply, tbl )
	net.Start( "advkc_communication" )
		net.WriteTable( tbl )
	net.Send( ply )
end

function ENT:Initialize()
    self:SetModel("models/props_lab/reciever01d.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()

    phys:Wake()

    self.damage = 10
end

function ENT:OnTakeDamage(dmg)
    self.damage = self.damage - dmg:GetDamage()

    if (self.damage <= 0) then
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetMagnitude(2)
        effectdata:SetScale(2)
        effectdata:SetRadius(3)
        util.Effect("Sparks", effectdata)
        self:Remove()
    end
end

function ENT:Use(activator, caller)
	if ( (caller.inform_timer or 0) < CurTime() ) then
		update_client( activator, {command = "inform", message = "Level 2 Security chipset. Apply to keypad.", msgType = "neutral"} )
		caller.inform_timer = CurTime() + 2 
	end
end

function ENT:Touch( ent )
	if ( !ent.IsKeypad ) then return end
	if ( ent.advkc_security_level == 2 or ent.advkc_security_level == 3 ) then 
		if ( IsValid(ent:GetTable().KeypadData.Owner)) then
			update_client( ent:GetTable().KeypadData.Owner, {command = "inform", message = "Keypad already has Security Level: 2 or higher.", msgType = "negative"} )
		end
		return
	end
	
	if ( IsValid(ent:GetTable().KeypadData.Owner)) then
		update_client( ent:GetTable().KeypadData.Owner, {command = "inform", message = "Keypad upgraded to Security Level: 2", msgType = "positive"} )
	end
	
	ent.advkc_security_level = 2;

	self:Remove();
end
