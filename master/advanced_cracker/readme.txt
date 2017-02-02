
First of all I want to thank you for finding this script interesting, it really means a lot.

// To instal just extract folder: "advanced_cracker" to your addons ( garrysmod/garrysmod/addons/ ) folder.
// Have questions? Contact me 	via Script Fodder: https://scriptfodder.com/users/view/76561198005641246
				via Steam: http://steamcommunity.com/profiles/76561198005641246/

// Console commands
sv_advkc_security_level_1_pins Sets digit number on default keypad. (1-6: default: 3)
sv_advkc_security_level_2_pins Sets digit number on Level 2 keypad. (1-6: default: 4)
sv_advkc_security_level_3_pins Sets digit number on Level 3 keypad. (1-6: default: 6)
sv_advkc_security_level_2_wanted Enables/disables autowanted. (On: 1, Off: 0, default: 1 )
sv_advkc_security_level_2_wanted_time Sets delay that has to pass before player gets wanted. ( in seconds, default: 12 sec. )
sv_advkc_distance Set keypad cracker active distance. ( default: 50 gmod units. )
sv_advkc_alarm_volume Sets volume of keypad cracker alarm. Applies only to Level 3 keypads. ( default: 70. Max: 100 )


// Code example for DarkRP server owners ( addentities.lua )
// Advanced Keypad Cracker and Upgrades 

DarkRP.createEntity("Keypad Upgrade Level: 2", {
    ent = "keypad_upgrade_level2",
    model = "models/props_lab/reciever01d.mdl",
    price = 500,
    max = 1,
    cmd = "buy_upgrade_2",
})

DarkRP.createEntity("Keypad Upgrade Level: 3", {
    ent = "keypad_upgrade_level3",
    model = "models/props_lab/reciever01d.mdl",
    price = 500,
    max = 1,
    cmd = "buy_upgrade_3",
})

DarkRP.createShipment("Advanced Keypad Cracker", {
    model = "models/weapons/w_c4.mdl",
    entity = "adv_k_cracker",
    price = 3750,
    amount = 10,
    separate = false,
    pricesep = nil,
    noship = false,
    allowed = {TEAM_GUN},
})

