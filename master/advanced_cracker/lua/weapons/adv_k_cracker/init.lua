
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua"); 
include("shared.lua")
 
 resource.AddWorkshop( "810743320" ) // Contains required image for UI
 resource.AddFile("content/resource/fonts/lato-regular.ttf");
 
//*******//
//CONVARS//
CreateConVar( "sv_advkc_security_level_1_pins", 3, { FCVAR_ARCHIVE }, "Set how many pins stage one security should have. 6max." );
CreateConVar( "sv_advkc_security_level_2_pins", 4, { FCVAR_ARCHIVE }, "Set how many pins stage two security should have. 6max." );
CreateConVar( "sv_advkc_security_level_3_pins", 6, { FCVAR_ARCHIVE }, "Set how many pins stage three security should have. 6max." );

CreateConVar( "sv_advkc_security_level_2_wanted", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Should player get wanted on security level 2? 1-yes; 0-no" );
CreateConVar( "sv_advkc_security_level_2_wanted_time", 12, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of time that has to pass before player get wanted. [seconds]" );

CreateConVar( "sv_advkc_distance", 50, FCVAR_ARCHIVE, "How far cracker should reach." ); 
CreateConVar( "sv_advkc_alarm_volume", 70, FCVAR_ARCHIVE, "How loud alarm should be. [%]" ); 
//*******//

//*****************
// Helper functions
//*****************
 
// Function for server and client communication
util.AddNetworkString( "advkc_communication" )
local function update_client( ply, tbl )
	net.Start( "advkc_communication" )
		net.WriteTable( tbl )
	net.Send( ply )
end

//Updates player with replicated convars
hook.Add("PlayerInitialSpawn", "sv_advkc_update_replicated", function(ply) update_client( ply, {command = "initial_spawn"}) end);

// Generating crackable code for keypad
// Everytime someone attemps to crack there will be new code generated
local function generateCode( keypad )

	local securityLevel = keypad.advkc_security_level or 1;
	local pinNumber = GetConVar( "sv_advkc_security_level_"..securityLevel.."_pins" ):GetInt(); // Each pins represents separate code number.
	if ( pinNumber > 6 ) then pinNumber = 6 end
	local letters = { "A", "B", "C", "D", "E", "F" };
	
	// Let's assemble our code
	local codeHolder = ""; // At first we set it to string, easier to work with, then we will convert it to variable
	for i = 1, pinNumber do
		if ( math.random(1,2) == 2)then
			local rnd = math.random( 1, 9 );
			codeHolder = codeHolder..""..rnd; 
		else
			codeHolder = codeHolder..""..table.Random(letters)
		end
	end

	// Lets update keypad security code
	keypad.advkc_security_code = codeHolder;
	
	// Lets return our generated integer
	return ( codeHolder );
	
end

// Did player entered correct code?
local function checkCode( keypad, code)
	if ( keypad.advkc_security_code == code ) then
		return true;
	end
	
	return false;
end

//**************
//SWEP FUNCTIONS
//**************
function SWEP:Initialize()
	self:SetHoldType(self.idle)
end	

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.4)
	local tr = self.Owner:GetEyeTrace();
	local ent = tr.Entity;
	local maxDist = GetConVar( "sv_advkc_distance" ):GetInt();

	// Checks
	if ( !self.Owner:Alive() ) then return end
	if ( self.Owner.advkc_isCracking ) then return end
	
	if IsValid(ent) and tr.HitPos:Distance(self.Owner:GetShootPos()) <= maxDist and ent.IsKeypad and !ent.advkc_beingCracked then
		self:SetWeaponHoldType("pistol");

		ent.advkc_beingCracked = true;
		self.Owner.advkc_isCracking = ent;
		
		//Let's inform clientside. Cracking has begun and code has been generated
		update_client( self.Owner, {command="start", keypad = ent, code=generateCode(ent), security = ( ent.advkc_security_level or 1 )});
	end
end


//****************************
// PROOFING
//****************************
local function onDeath( ply )
	if ( IsValid(ply.advkc_isCracking)) then
		ply.advkc_isCracking.advkc_beingCracked = false;
		ply.advkc_isCracking = false;
		
		update_client( ply, {command="cancel"} );
	end
end
hook.Add("PlayerDeath", "advkc_proofing_death", onDeath);

if (GetConVar( "sv_advkc_security_level_2_wanted" ):GetInt() >= 1) then
	//Again hook name didn't changed
	hook.Add("playerArrested", "advkc_proofing_death", onDeath);
end
	
//****************************
// SERVER-CLIENT COMMUNICATION
//****************************
net.Receive( "advkc_communication", function(_, ply)

	local info = net.ReadTable();
	local command = info.command;
	local keypad = info.keypad;

	if ( command == "injection") then
		if ( checkCode(keypad, info.code) ) then
		
			//If player gets pushed or moved somewhere while cracking keypad, do not allow him to succeed cracking
			//This function should prevent from bugging
			if ( ply:GetShootPos():Distance(keypad:GetPos()) > GetConVar( "sv_advkc_distance" ):GetInt() + 100 ) then return end
			keypad:Process( true );
		end
		
		keypad.advkc_beingCracked = false;
		ply.advkc_isCracking = false;
		
	elseif( command == "closed_menu") then
	
		keypad.advkc_beingCracked = false;
		ply.advkc_isCracking = false;
		
	elseif( command == "dur_expired") then
	
		if ( keypad.KeypadData.Owner == ply ) then return end // Cracking own keypads won't make you wanted
				
		//Alarm
		if ( keypad.advkc_security_level == 3) then
			if ( keypad.advkc_beingCracked == true ) then
				local pitchModifier = pitchModifier or 0;
				timer.Create( "keypad_alarm:"..keypad:EntIndex(), 0.5, 0, function()
					pitchModifier = pitchModifier + 1;
					if ( keypad.advkc_beingCracked == false ) then
						timer.Destroy("keypad_alarm:"..keypad:EntIndex())
					end
					
					keypad:EmitSound(Sound("buttons/blip2.wav"), GetConVar("sv_advkc_alarm_volume"):GetInt(), 100*(0.75-0.10*(pitchModifier%2)));
				
				end)
			end
		end
		
		// Owners that will be running this script on different gamemodes ( not on DarkRP ) 
		// should make 'sv_advkc_security_level_2_wanted 0' otherwise wanted function will be called 
		// and will return lua error ( if such function doesn't exist or args doesn't match )
		if (GetConVar( "sv_advkc_security_level_2_wanted" ):GetInt() >= 1) then
			ply:wanted(nil, "Keypad cracking", 120); 
			// Should work for all DarkRP versions because wanted function didn't change much. In 2.5.0 they added new 'time' argument.
			// Sadly nil will make players set wanted by "Disconnected Player". But it is DarkRP internal functions.
		end
	end

end)