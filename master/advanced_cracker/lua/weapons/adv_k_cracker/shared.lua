
SWEP.Author = "sOur";
SWEP.Instructions = "";
SWEP.Contact = "";
SWEP.Purpose = "";

SWEP.ViewModelFOV = 62;
SWEP.ViewModelFlip = false;
SWEP.ViewModel = Model("models/weapons/v_c4.mdl");
SWEP.WorldModel = Model("models/weapons/w_c4.mdl");

SWEP.Spawnable = true;
SWEP.AdminOnly = true;
SWEP.AnimPrefix = "python";

SWEP.idle = "slam";
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "";

SWEP.Sound = Sound("weapons/deagle/deagle-1.wav")

function SWEP:Initialize()
	self:SetHoldType(self.idle);
end

function SWEP:Reload()
	return true;
end

function SWEP:Think()
	return true;
end

if CLIENT then

	function SWEP:PrimaryAttack()
		self:SetNextPrimaryFire(CurTime() + 0.4)
	end

	function SWEP:SecondaryAttack()
		self:SetNextSecondaryFire(CurTime() + 0.4)
	end

end