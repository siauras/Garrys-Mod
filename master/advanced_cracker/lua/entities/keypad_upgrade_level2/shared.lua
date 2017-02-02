ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Keypad Upgrade Level: 2"
ENT.Author = "sOur"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 1, "owning_ent")
end
