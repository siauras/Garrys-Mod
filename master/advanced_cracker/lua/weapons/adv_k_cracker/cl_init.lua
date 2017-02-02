
include("shared.lua")

SWEP.PrintName = "Advanced Keypad Cracker";
SWEP.Slot = 4;
SWEP.SlotPos = 1;
SWEP.DrawAmmo = false;
SWEP.DrawCrosshair = true;

local function INIT()
	surface.CreateFont( "Lato_Regular_20", {
		font = "Lato Regular", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		size = 20,
		weight = 500,
		antialias = true,
	} )
	
	surface.CreateFont( "Lato_Regular_16", {
		font = "Lato Regular", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		size = 16,
		weight = 500,
		antialias = true,
	} )
end
hook.Add("Initialize", "adv_k_c_font", INIT)



// TODO: Level 2 and Level 3 keypad upgrades. Level 2 more pins and sound. Level 3 more pins, sound and fail timer.
// TODO: Minimum code number count. 6 would be alright

local function update_server( tbl )
	net.Start("advkc_communication")
		net.WriteTable( tbl );
	net.SendToServer();
end

// Menu holder
local menu = {};
menu.pinScreen = function()
	local ps = vgui.Create("DPanel", menu.main_panel);
	ps:SetSize( menu.main_panel:GetWide() - 10, menu.main_panel:GetTall() - 45 );
	
	// Transition
	ps:SetPos( menu.main_panel:GetWide(), 40 );
	ps:MoveTo( menu.main_panel:GetWide()/2 - ps:GetWide()/2, 40, 0.15, 0, -1 );
	ps:SetAlpha( 0 );
	ps:AlphaTo( 255, 0.3, 0);
		
	local ki = vgui.Create("DImage", ps)
	ki:SetPos( 10, 3 );
	ki:SetSize(116, 200)
	ki:SetImage("keypad.png");
	ki:SetAlpha( 150 );
	
	menu.current_code = {};
	menu.holders = {};
	menu.allValues = {1, 2, 3, 4, 5, 6, 7, 8, 9, "A", "B", "C", "D", "E", "F"};
	for i = 1, string.len(menu.code) do
		local holder = vgui.Create("Panel", ps)
		holder:SetSize( 30, 100 );
		holder:SetPos( ps:GetWide()/2 + 5 + 35*i - 70, ps:GetTall()/2 - 50 );
		
		// To make things more interesting
		local function setStartingValue()
			local rnd = math.random(1, 15);
			if ( tostring(menu.allValues[rnd]) == tostring(menu.code[i]) ) then
				setStartingValue();
				return
			end
			
			holder.curValue = rnd;
		end
		setStartingValue()
		
		
		holder.Paint = function()
			surface.SetDrawColor(  Color(236,239,241) );
			if ( tostring(menu.allValues[holder.curValue]) == tostring(menu.code[i]) ) then 
				surface.SetDrawColor(  Color(129,199,132) );
			end
			surface.DrawRect(0, 0, ps:GetWide(), ps:GetTall() );
			draw.SimpleText(menu.allValues[holder.curValue], "Lato_Regular_20", holder:GetWide()/2, holder:GetTall()/2, Color(69,90,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		
		local function changeCurVal( dir )
			if ( dir == "up") then
				if (holder.curValue + 1 == 16 ) then holder.curValue = 1; return end
				holder.curValue = holder.curValue + 1;
			else
				if (holder.curValue - 1 == 0 ) then holder.curValue = 15; return end
				holder.curValue = holder.curValue - 1;
			end
		end
		
		local bUp = vgui.Create("DButton", holder)
		bUp:SetText("");
		bUp:SetSize( 30, 30 );
		bUp:SetPos(0, 0);
		
		bUp.DoClick = function()
			changeCurVal("up");
		end
		
		bUp.OnCursorEntered = function() bUp.hovered = true end
		bUp.OnCursorExited = function() bUp.hovered = false end
		
		bUp.Paint = function()
			if ( bUp.hovered ) then
				surface.SetDrawColor(  Color(207,216,220) );
				surface.DrawRect(0, 0, ps:GetWide(), ps:GetTall() );
			else
				surface.SetDrawColor(  Color(236,239,241) );
				surface.DrawRect(0, 0, ps:GetWide(), ps:GetTall() );
			end
		
			draw.SimpleText("+", "Lato_Regular_20", bUp:GetWide()/2, bUp:GetTall()/2, Color(69,90,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		
		local bDown = vgui.Create("DButton", holder)
		bDown:SetText("");
		bDown:SetSize( 30, 30 );
		bDown:SetPos(0, 70);
		
		bDown.DoClick = function()
			changeCurVal("down");
		end
		
		bDown.OnCursorEntered = function() bDown.hovered = true end
		bDown.OnCursorExited = function() bDown.hovered = false end
		
		bDown.Paint = function()
			if ( bDown.hovered ) then
				surface.SetDrawColor(  Color(207,216,220) );
				surface.DrawRect(0, 0, ps:GetWide(), ps:GetTall() );
			else
				surface.SetDrawColor(  Color(236,239,241) );
				surface.DrawRect(0, 0, ps:GetWide(), ps:GetTall() );
			end
			
			draw.SimpleText("-", "Lato_Regular_20", bDown:GetWide()/2, bDown:GetTall()/2, Color(69,90,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		
		menu.holders[i] = holder;
	end
	
	local function formCurrentCode()
		local code = "";
		for i = 1, string.len(menu.code) do			
			code = code..""..menu.allValues[menu.holders[i].curValue];
		end
		
		return code;
	end
	
	local bInj = vgui.Create("DButton", ps)
	bInj:SetText("");
	bInj:SetPos( ps:GetWide()/2 + 5 + 35 - 70, ps:GetTall()/2 + 55 );
	bInj:SetSize( string.len(menu.code)*35 - 5, 30 );
	
	bInj.OnCursorEntered = function() bInj.hovered = true end
	bInj.OnCursorExited = function() bInj.hovered = false end
	
	bInj.Paint = function()
		if ( bInj.hovered ) then
			surface.SetDrawColor(  Color(244,67,54) );
			surface.DrawRect(0, 0, ps:GetWide(), ps:GetTall() );
			draw.SimpleText("INJECT", "Lato_Regular_20", bInj:GetWide()/2, bInj:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			surface.SetDrawColor(  Color(236,239,241) );
			surface.DrawRect(0, 0, ps:GetWide(), ps:GetTall() );
			draw.SimpleText("INJECT", "Lato_Regular_20", bInj:GetWide()/2, bInj:GetTall()/2, Color(244,67,54), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	
	bInj.DoClick = function()
		ps:MoveTo( menu.main_panel:GetWide(), 40, 0.10, 0, -1, function()
			update_server( {command = "injection", keypad = menu.keypad, code = formCurrentCode()} );
			menu.main_panel:Remove();
		end);
		ps:AlphaTo( 0, 0.6, 0);
	end
	
	local canWanted = GetConVar( "sv_advkc_security_level_2_wanted" ):GetInt();
	local dur = GetConVar( "sv_advkc_security_level_2_wanted_time" ):GetInt();
	
	// Security Level 2 wanted bar
	if( tonumber(menu.security) == 3 ) then
		update_server({command = "dur_expired", keypad = menu.keypad})
	elseif ( tonumber(menu.security) == 2 and tonumber(canWanted) >= 1  ) then	
		local bg = vgui.Create("DPanel", ps)
		bg:SetSize( ps:GetWide()/2 + 25, 10 );
		bg:SetPos( ps:GetWide()/2 - 30, 25 );
		
		bg.Paint = function()
			surface.SetDrawColor(  Color(207,216,220, 255) );
			surface.DrawRect(0, 0, bg:GetWide(), bg:GetTall() );
		end
		
		local wBar = vgui.Create("DPanel", ps)
		wBar:SetSize( 0, 10 );
		wBar:SetPos( ps:GetWide()/2 - 30, 25 );
		wBar:SizeTo( ps:GetWide()/2 + 25, 10, dur, 0, -1, function()
			update_server({command = "dur_expired", keypad = menu.keypad})
		end)
		
		wBar.Paint = function()
			local glow = math.abs(TimedSin( 2, 1, 2, 0));
			surface.SetDrawColor(  Color(244,67,54, 255*glow) );
			surface.DrawRect(0, 0, wBar:GetWide(), wBar:GetTall() );
		end
		
		
	end
	
	//Paint
	ps.Paint = function()
		surface.SetDrawColor(  Color(236,239,241) );
		surface.DrawRect(0, 0, ps:GetWide(), ps:GetTall() );
		
		if ( menu.security == 3) then
			draw.SimpleText("Breach detected! Cause identified.", "Lato_Regular_16", ps:GetWide()/2 - 30, 15, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		elseif ( menu.security == 2 ) then
			draw.SimpleText("Breach detected! Identifying cause:", "Lato_Regular_16", ps:GetWide()/2 - 30, 15, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end
	
end

menu.loadScreen = function()
	local ls = vgui.Create("DPanel", menu.main_panel)
	ls:SetSize(150, 160 );
	
	// Transition
	ls:SetPos( menu.main_panel:GetWide(), menu.main_panel:GetTall()/2 - ls:GetTall()/2 );
	ls:MoveTo( menu.main_panel:GetWide()/2 - ls:GetWide()/2, menu.main_panel:GetTall()/2 - ls:GetTall()/2, 0.15, 0, -1 );
	ls:SetAlpha( 0 );
	ls:AlphaTo( 255, 0.8, 0);
		
	local lb = vgui.Create("DPanel", ls)
	lb:SetSize(0, 10);
	lb:SetPos( 5, ls:GetTall()/2 - lb:GetTall()/2 + 50 );
	lb:SizeTo( 140, 10, 3.5, 0.15, -1, function()
		menu.pinScreen(); // Loading finished lets start playing with pins
		ls:AlphaTo( 0, 0.15, 0, function()
			ls:Remove()
		end);
	end	);
	
	//Paint. Loading bar
	lb.Paint = function()		
		surface.SetDrawColor(  Color(139,195,74) );
		surface.DrawRect(0, 0, ls:GetWide(), ls:GetTall() );
	end
	
	//Paint. Loading Screen
	ls.Paint = function()
		surface.SetDrawColor(  Color(236,239,241) );
		surface.DrawRect(0, 0, ls:GetWide(), ls:GetTall() );
		
		local x, _ = lb:GetSize();

		draw.SimpleText(math.ceil((x*100/140)).."%", "Lato_Regular_20", ls:GetWide()/2, 50, Color(69,90,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		if ( x > 40 ) then draw.SimpleText("Data Extraction chip. Ready", "default", 5, 80, Color(69,90,100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER ) end
		if ( x > 80 ) then draw.SimpleText("Manipulation chip. Ready", "default", 5, 90, Color(69,90,100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
		if ( x > 120 ) then draw.SimpleText("Code Injector chip. Ready", "default", 5, 100, Color(69,90,100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
	end
end

menu.main = function( keypad, code, security )
	
	
	local mp = vgui.Create("DFrame");
	mp:SetTitle("");
	mp:SetAlpha( 0 );
	mp:SetSize(400, 250);
	mp:Center();
	mp:MakePopup();
	mp:ShowCloseButton( true );
	mp:SetDraggable( false );
	
	//Let's store some data
	menu.main_panel = mp;
	menu.keypad = keypad;
	menu.code = code;
	menu.security = security;
	
	mp.OnRemove = function()
		update_server( {command="closed_menu", keypad = menu.keypad} )
		LocalPlayer().advkc_inmenu = false;
	end
	
	//Paint
	mp.Paint = function()
		surface.SetDrawColor(Color(207,216,220));
		surface.DrawRect(0, 0, mp:GetWide(), mp:GetTall());
	end
	
	//Transition
	mp:AlphaTo( 255, 0.7, 0, function()
		menu.loadScreen();
	end);
	
	return mp;
end

local function inform( msg, msgType )
	surface.SetFont( "Lato_Regular_20" );
	local textSize = surface.GetTextSize( msg );
	
	local holder = vgui.Create("DPanel");
	holder:SetSize( textSize + 10, 25);
	holder:SetPos(ScrW()/2 - holder:GetWide()/2, ScrH()*0.3);
	holder:SetAlpha( 0 );
	
	//Transition
	holder:AlphaTo(255, 0.6, 0);
	
	local color;
	if (msgType == "neutral") then
		color = Color(136,139,141, 100);
	elseif ( msgType == "positive") then
		color = Color(139,195,74, 100);
	else
		color = Color(244,67,54, 100);
	end
		
	holder.Paint = function()
		draw.SimpleText(msg, "Lato_Regular_20", 5, holder:GetTall()/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	
		surface.SetDrawColor( color );
		surface.DrawRect( 0, 0, holder:GetWide(), holder:GetTall() );
	end
	
	timer.Simple( 4, function()
		holder:Remove();
		LocalPlayer().inform_holder = nil;
	end)
	
	LocalPlayer().inform_holder = holder;
end

net.Receive("advkc_communication", function()
	local info = net.ReadTable();
	local command = info.command;
	
	if ( command == "start" ) then
		local keypad = info.keypad;
		local code = info.code;
		local securityLevel = info.security;
		
		LocalPlayer().advkc_inmenu = menu.main( keypad, code, securityLevel );
	elseif( command == "inform") then
		if ( (LocalPlayer().inform_time or 0) > CurTime() ) then return end
		local message = info.message;
		local msgType = info.msgType;
		if ( LocalPlayer().inform_holder != nil ) then
			LocalPlayer().inform_holder:Remove();
		end
		inform( message, msgType );
		LocalPlayer().inform_time = CurTime() + 4;
	elseif( command == "initial_spawn") then
		timer.Simple(0, function()
			CreateConVar( "sv_advkc_security_level_2_wanted", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Should player get wanted on security level 2? 1-yes; 0-no" );
			CreateConVar( "sv_advkc_security_level_2_wanted_time", 12, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of time that has to pass before player get wanted. [seconds]" );
		end)
	elseif( command == "cancel" ) then
		// Will receive this message when player dies or get's arrested
		if ( LocalPlayer().advkc_inmenu != false )then
			LocalPlayer().advkc_inmenu:Remove();
		end
	end
end)