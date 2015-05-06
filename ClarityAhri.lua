
--[[Ahri by Team Clarity]]



if myHero.charName ~= 'Ahri' then return end



--draws Q+W enemy HPbar
--lag free circles
--draws and alert u if someone is gankable
--combo logic 
--change card from red to blue if low mana in farm mode
--auto gold card when uld
--ks with q and w
--R range in the mini map

--needs auto zhonya

--[[		Auto Update		]]

local Version = "1.1"
local AutoUpdate = true

function ScriptMsg(msg)
  print("<font color=\"#daa520\"><b>Clarity Ahri:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end


local Host = "raw.github.com"

local ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

local ScriptPath = "/FukDaPolice/scripts/blob/master/ClarityAhri.lua".."?rand="..math.random(1,10000)
local UpdateURL = "https://"..Host..ScriptPath

local VersionPath = "/FukDaPolice/scripts/blob/master/ClarityAhri.version".."?rand="..math.random(1,10000)
local VersionData = tonumber(GetWebResult(Host, VersionPath))

if AutoUpdate then

  if VersionData then
  
    ServerVersion = type(VersionData) == "number" and VersionData or nil
    
    if ServerVersion then
    
      if tonumber(Version) < ServerVersion then
        ScriptMsg("New version available: v"..VersionData)
        ScriptMsg("Updating, please don't press F9.")
        DelayAction(function() DownloadFile(UpdateURL, ScriptFilePath, function () ScriptMsg("Successfully updated.: v"..Version.." => v"..VersionData..", Press F9 twice to load the updated version.") end) end, 3)
      else
        ScriptMsg("You've got the latest version: v"..Version)
      end
      
    end
    
  else
    ScriptMsg("Error downloading version info.")
  end
  
else
  ScriptMsg("AutoUpdate: false")
end

------------------------------------------------------------------------------------------------------------------------------------------



require "SxOrbWalk"
require "VPrediction"

if FileExist(LIB_PATH.."DivinePred.lua") then
	divinePredLoaded = true
	require "DivinePred"
end 

local AA = Aa
local Q = {range = 880, delay = 0.25, speed = 1600, width = 90,IsReady = function() return myHero:CanUseSpell(_Q) == READY end}
local W = {range = 550, IsReady = function() return myHero:CanUseSpell(_W) == READY end}
local E = {range = 975, delay = 0.25, speed = 1500, width = 100,IsReady = function() return myHero:CanUseSpell(_E) == READY end}
local R = {range = 450, delay = 0.25, speed = 1500, width = 80,IsReady = function() return myHero:CanUseSpell(_R) == READY end}
local ignite = nil
local iDmg = 0
local informationTable = {}
local spellExpired = true
local ts
local ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1300, DAMAGE_MAGIC, true)
local myTarget = nil
local Killable = false
local LastAlert = 0


---------------------DPred---------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------



local ToInterrupt = {}
local InterruptList = {
    { charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
    { charName = "FiddleSticks", spellName = "Crowstorm"},
    { charName = "FiddleSticks", spellName = "DrainChannel"},
    { charName = "Galio", spellName = "GalioIdolOfDurand"},
    { charName = "Karthus", spellName = "FallenOne"},
    { charName = "Katarina", spellName = "KatarinaR"},
    { charName = "Lucian", spellName = "LucianR"},
    { charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
    { charName = "MissFortune", spellName = "MissFortuneBulletTime"},
    { charName = "Nunu", spellName = "AbsoluteZero"},                            
    { charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
    { charName = "Shen", spellName = "ShenStandUnited"},
    { charName = "Urgot", spellName = "UrgotSwap2"},
    { charName = "Varus", spellName = "VarusQ"},
	{ charName = "Warwick", spellName = "InfiniteDuress"},
	{ charName = "Velkoz", spellName = "VelkozR"}
}



TextList = {"", "Kill Him!"}
KillText = {}
colorText = ARGB(255,255,204,0)


function GetCustomTarget()
	ts:update()
	if _G.AutoCarry and ValidTarget(_G.AutoCarry.Crosshair:GetTarget()) then return _G.AutoCarry.Crosshair:GetTarget() end
	if not _G.Reborn_Loaded then return ts.target end
	return ts.target
end

function OnLoad()
     
	  
	PrintChat("<font color=\"#00FF00\">Ahri by Team Clarity.</font>")
	ItemNames				= {
		[3303]				= "ArchAngelsDummySpell",
		[3007]				= "ArchAngelsDummySpell",
		[3144]				= "BilgewaterCutlass",
		[3188]				= "ItemBlackfireTorch",
		[3153]				= "ItemSwordOfFeastAndFamine",
		[3405]				= "TrinketSweeperLvl1",
		[3411]				= "TrinketOrbLvl1",
		[3166]				= "TrinketTotemLvl1",
		[3450]				= "OdinTrinketRevive",
		[2041]				= "ItemCrystalFlask",
		[2054]				= "ItemKingPoroSnack",
		[2138]				= "ElixirOfIron",
		[2137]				= "ElixirOfRuin",
		[2139]				= "ElixirOfSorcery",
		[2140]				= "ElixirOfWrath",
		[3184]				= "OdinEntropicClaymore",
		[2050]				= "ItemMiniWard",
		[3401]				= "HealthBomb",
		[3363]				= "TrinketOrbLvl3",
		[3092]				= "ItemGlacialSpikeCast",
		[3460]				= "AscWarp",
		[3361]				= "TrinketTotemLvl3",
		[3362]				= "TrinketTotemLvl4",
		[3159]				= "HextechSweeper",
		[2051]				= "ItemHorn",
		--[2003]			= "RegenerationPotion",
		[3146]				= "HextechGunblade",
		[3187]				= "HextechSweeper",
		[3190]				= "IronStylus",
		[2004]				= "FlaskOfCrystalWater",
		[3139]				= "ItemMercurial",
		[3222]				= "ItemMorellosBane",
		[3042]				= "Muramana",
		[3043]				= "Muramana",
		[3180]				= "OdynsVeil",
		[3056]				= "ItemFaithShaker",
		[2047]				= "OracleExtractSight",
		[3364]				= "TrinketSweeperLvl3",
		[2052]				= "ItemPoroSnack",
		[3140]				= "QuicksilverSash",
		[3143]				= "RanduinsOmen",
		[3074]				= "ItemTiamatCleave",
		[3800]				= "ItemRighteousGlory",
		[2045]				= "ItemGhostWard",
		[3342]				= "TrinketOrbLvl1",
		[3040]				= "ItemSeraphsEmbrace",
		[3048]				= "ItemSeraphsEmbrace",
		[2049]				= "ItemGhostWard",
		[3345]				= "OdinTrinketRevive",
		[2044]				= "SightWard",
		[3341]				= "TrinketSweeperLvl1",
		[3069]				= "shurelyascrest",
		[3599]				= "KalistaPSpellCast",
		[3185]				= "HextechSweeper",
		[3077]				= "ItemTiamatCleave",
		[2009]				= "ItemMiniRegenPotion",
		[2010]				= "ItemMiniRegenPotion",
		[3023]				= "ItemWraithCollar",
		[3290]				= "ItemWraithCollar",
		[2043]				= "VisionWard",
		[3340]				= "TrinketTotemLvl1",
		[3090]				= "ZhonyasHourglass",
		[3154]				= "wrigglelantern",
		[3142]				= "YoumusBlade",
		[3157]				= "ZhonyasHourglass",
		[3512]				= "ItemVoidGate",
		[3131]				= "ItemSoTD",
		[3137]				= "ItemDervishBlade",
		[3352]				= "RelicSpotter",
		[3350]				= "TrinketTotemLvl2",
	}
	_G.ITEM_1				= 06
	_G.ITEM_2				= 07
	_G.ITEM_3				= 08
	_G.ITEM_4				= 09
	_G.ITEM_5				= 10
	_G.ITEM_6				= 11
	_G.ITEM_7				= 12
	
	___GetInventorySlotItem	= rawget(_G, "GetInventorySlotItem")
	_G.GetInventorySlotItem	= GetSlotItem
	
	checkDistance = 3000 * 3000
	IgniteCheck()
	FLoadLib()
	VP = VPrediction(true)
	if divinePredLoaded then
		DP = DivinePred() 
	end
    _G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	
	Minions = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_ASC)
	JungleMinions = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
end


function OnTick()
	target = GetCustomTarget()
	Checks()
	
	if isSX then
		SxOrb:ForceTarget(target)
	end
	  
   
end

function OnDraw()
	if HazMenu.Draw.drawq then
		DrawCircle(myHero.x,myHero.y,myHero.z,870,0xFFFF0000)
	end 			
	if HazMenu.Draw.draww then
		DrawCircle(myHero.x,myHero.y,myHero.z,550,0xFFFF0000)
	end
	if HazMenu.Draw.drawe then
		DrawCircle(myHero.x,myHero.y,myHero.z,975,0xFFFF0000)
	end
	if HazMenu.Draw.drawr then
		DrawCircle(myHero.x,myHero.y,myHero.z,450,0xFFFF0000)
	end
	--if HazMenu.Draw.drawt and Target ~= nil then
		--DrawCircle(Target.x, Target.y, Target.z, 80,0xFFFF0000)
	--end
	if  HazMenu.Draw.drawHP then
			for i, enemy in ipairs(GetEnemyHeroes()) do
       			if ValidTarget(enemy) then
			       DrawIndicator(enemy)
			    end
	        end
	end		
	
	if HazMenu.Misc.killtext then
		for i = 1, heroManager.iCount do
			local target = heroManager:GetHero(i)
			if ValidTarget(target) and target ~= nil then
			    if ValidTarget(target) and target ~= nil then
				local barPos = WorldToScreen(D3DXVECTOR3(target.x, target.y, target.z))
				local PosX = barPos.x - 35
				local PosY = barPos.y - 10
				
				DrawText(TextList[KillText[i]], 16, PosX, PosY, colorText)
			
			    end
			end
		end
	end   
end


function Checks()
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	calcDmg()
	LFCfunc()
	SpellExpired()
	
	if ValidTarget(target) then
		if HazMenu.Misc.KS then KS(target) end
		if HazMenu.Misc.Ignite then AutoIgnite(target) end
	    
	   
	end
		
	if HazMenu.Misc.zhonya then 
    Zhonya()
    end	
	if HazMenu.Farm.Mana then end
	if HazMenu.Harass.Mana then end
	
	if HazMenu.combokey then
		Combo()
    end	
   if HazMenu.harasskey then
		Poke()
   end
   if HazMenu.farmkey then
		Farm()
   end
    if HazMenu.More.moveto then
        moveto()			
	end	
    	
end

function IgniteCheck()
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
		ignite = SUMMONER_2
	end
end

function FLoadLib()
	FMenu()
end

function FMenu()
	HazMenu = scriptConfig("Clarity Ahri", "Ahri")
		HazMenu:addParam("combokey", "Combo key(Space)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		HazMenu:addParam("harasskey", "Harass key(C)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		HazMenu:addParam("farmkey", "Farm key(V)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	    	
	HazMenu:addTS(ts)
		
	HazMenu:addSubMenu("Combo", "Combo")
		HazMenu.Combo:addParam("comboQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		HazMenu.Combo:addParam("comboW", "Use W", SCRIPT_PARAM_ONOFF, true)
		HazMenu.Combo:addParam("comboE", "Use E", SCRIPT_PARAM_ONOFF, true)
		HazMenu.Combo:addParam("comboR", "Use R", SCRIPT_PARAM_ONOFF, true)
		HazMenu.Combo:addParam("comboRm", "R to mouse", SCRIPT_PARAM_ONOFF, true)
		--HazMenu.Combo:addParam("stunQ", "Use Q only if Charmed", SCRIPT_PARAM_ONOFF, true)
		
   	HazMenu:addSubMenu("Harass", "Harass")
		HazMenu.Harass:addParam("harassQ", "Use Q", SCRIPT_PARAM_ONOFF, true)		
		HazMenu.Harass:addParam("harassW", "Use W", SCRIPT_PARAM_ONOFF, true)
	    HazMenu.Harass:addParam("harassE", "Use E", SCRIPT_PARAM_ONOFF, true)
		HazMenu.Harass:addParam("Mana", "Mana Manager %", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
	
	HazMenu:addSubMenu("More", "More")
	    HazMenu.More:addParam("moveto", "Escape/Chase Q (Z)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
		if divinePredLoaded then
		HazMenu.More:addParam("Pred", "Use DPred", SCRIPT_PARAM_ONOFF, true)
	    end
	
    HazMenu:addSubMenu("Farm", "Farm")
	    HazMenu.Farm:addParam("farmQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		HazMenu.Farm:addParam("farmW", "Use W", SCRIPT_PARAM_ONOFF, true)
	    HazMenu.Farm:addParam("Mana", "Mana Manager %", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
	
	HazMenu:addSubMenu("Misc", "Misc")
		HazMenu.Misc:addParam("KS", "KillSteal with Q", SCRIPT_PARAM_ONOFF, true)
		HazMenu.Misc:addParam("Ignite", "Use Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	    HazMenu.Misc:addParam("killtext", "Kill Text", SCRIPT_PARAM_ONOFF, true)
		HazMenu.Misc:addParam("zhonya", "Auto Zhonyas", SCRIPT_PARAM_ONOFF, true)
	    HazMenu.Misc:addParam("zhonyaHP", "Use Zhonyas at % health", SCRIPT_PARAM_SLICE, 20, 0, 100 , 0)
		HazMenu.Misc:addParam("Amount", "Zhonya if x Enemies", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
		
	HazMenu:addSubMenu("Draw","Draw")
	  HazMenu.Draw:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
	  HazMenu.Draw:addParam("draww", "Draw W", SCRIPT_PARAM_ONOFF, true)
	  HazMenu.Draw:addParam("drawe", "Draw E", SCRIPT_PARAM_ONOFF, true)
	  HazMenu.Draw:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, true)
	  HazMenu.Draw:addParam("drawHP", "Draw Dmg on HPBar", SCRIPT_PARAM_ONOFF, true)
	  --HazMenu.Draw:addParam("drawt", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
	  
	  
	HazMenu:addParam("AGP", "Auto E gapclosers", SCRIPT_PARAM_ONOFF, true)	
	HazMenu:addParam("Interrupt", "interrupt with E", SCRIPT_PARAM_ONOFF, true)
	
	
	HazMenu:addSubMenu("LagFreeCircles", "LFC")
	  HazMenu.LFC:addParam("LagFree", "Activate Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
	  HazMenu.LFC:addParam("CL", "Length before Snapping", SCRIPT_PARAM_SLICE, 350, 75, 2000, 0)
	  HazMenu.LFC:addParam("CLinfo", "Higher length = Lower FPS Drops", SCRIPT_PARAM_INFO, "")
	
	for i = 1, heroManager.iCount, 1 do
		local enemy = heroManager:getHero(i)
		if enemy.team ~= myHero.team then
			for _, champ in pairs(InterruptList) do
				if enemy.charName == champ.charName then
					table.insert(ToInterrupt, champ.spellName)
				end
			end
		end
	end
	
	if _G.Reborn_Loaded then
	DelayAction(function()
		PrintChat("<font color = \"#FFFFFF\">[Ahri] </font><font color = \"#FF0000\">SAC Status:</font> <font color = \"#FFFFFF\">Successfully integrated.</font> </font>")
		HazMenu:addParam("SACON","[Ahri] SAC:R support is active.", 5, "")
		isSAC = true
	end, 10)
	elseif not _G.Reborn_Loaded then
		PrintChat("<font color = \"#FFFFFF\">[Ahri] </font><font color = \"#FF0000\">Orbwalker not found:</font> <font color = \"#FFFFFF\">SxOrbWalk integrated.</font> </font>")
		HazMenu:addSubMenu("Orbwalker", "SxOrb")
		SxOrb:LoadToMenu(HazMenu.SxOrb)
		isSX = true
	end
	HazMenu:permaShow("combokey")
	HazMenu:permaShow("harasskey")
	HazMenu:permaShow("farmkey")
end



function KS(enemy)  
	if Q.IsReady() and getDmg("Q", enemy, myHero) > enemy.health then
		if GetDistance(enemy) <= Q.range and HazMenu.Misc.KS then 
			local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, Q.delay, Q.width, Q.range, Q.speed, myHero, false)
			if HitChance >= 2 and GetDistance(CastPosition) <= Q.range and Q.IsReady() then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
		    end
		end
	end
    if E.IsReady() and getDmg("E", enemy, myHero) > enemy.health then
		if GetDistance(enemy) <= E.range and HazMenu.Misc.KS then 
			local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, E.delay, E.width, E.range, E.speed, myHero, true)
			if HitChance >= 2 and GetDistance(CastPosition) <= E.range and GetDistance(CastPosition) >= 600 and E.IsReady() then
				CastSpell(_E, CastPosition.x, CastPosition.z)
		    end
		end
	end
end

function AutoIgnite(enemy)
  	iDmg = ((IREADY and getDmg("IGNITE", enemy, myHero)) or 0) 
	if enemy.health <= iDmg and GetDistance(enemy) <= 600 and ignite ~= nil
		then
			if IREADY then CastSpell(ignite, enemy) end
	end
end


--Big TNX to Manciuzz for this part


function OnProcessSpell(unit, spell) 
    if unit == myHero and spell.name=="OrbofDeceptionBack" or spell.name=="OrbofDeception" then
        if HazMenu.combokey and R.IsReady() and GetDistance(target) <= 900 then 
		    if HazMenu.Combo.comboRm then
			   DelayAction(function()  castRm()   end, 0.75)
			end
            elseif not HazMenu.Combo.comboRm then	
               DelayAction(function() castR() end, 1)	
			end   
	 end
		
	if HazMenu.Interrupt and E.IsReady() and #ToInterrupt > 0 then
		for _, ability in pairs(ToInterrupt) do
			if spell.name == ability and unit.team ~= myHero.team then
				if GetDistance(unit) <= 800 then CastSpell(_E, unit.x, unit.z) end
			end
		end
	end
	if HazMenu.AGP and E.IsReady() then
	        local jarvanAddition = unit.charName == "JarvanIV" and unit:CanUseSpell(_Q) ~= READY and _R or _Q
			local isAGapcloserUnit = {
				['Aatrox']      = {true, spell = _Q,                  range = 1000,  projSpeed = 1200, },
				['Akali']       = {true, spell = _R,                  range = 800,   projSpeed = 2200, }, 
				['Alistar']     = {true, spell = _W,                  range = 650,   projSpeed = 2000, }, 
				['Diana']       = {true, spell = _R,                  range = 825,   projSpeed = 2000, }, 
				['Gragas']      = {true, spell = _E,                  range = 600,   projSpeed = 2000, },
				['Hecarim']     = {true, spell = _R,                  range = 1000,  projSpeed = 1200, },
				['Irelia']      = {true, spell = _Q,                  range = 650,   projSpeed = 2200, }, 
				['JarvanIV']    = {true, spell = jarvanAddition,      range = 770,   projSpeed = 2000, }, 
				['Jax']         = {true, spell = _Q,                  range = 700,   projSpeed = 2000, }, 
				['Jayce']       = {true, spell = 'JayceToTheSkies',   range = 600,   projSpeed = 2000, }, 
				['Khazix']      = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
				['Leblanc']     = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
				['LeeSin']      = {true, spell = 'blindmonkqtwo',     range = 1300,  projSpeed = 1800, },
				['Leona']       = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
				['Malphite']    = {true, spell = _R,                  range = 1000,  projSpeed = 1500 + unit.ms},
				['Maokai']      = {true, spell = _Q,                  range = 600,   projSpeed = 1200, }, 
				['MonkeyKing']  = {true, spell = _E,                  range = 650,   projSpeed = 2200, }, 
				['Pantheon']    = {true, spell = _W,                  range = 600,   projSpeed = 2000, }, 
				['Poppy']       = {true, spell = _E,                  range = 525,   projSpeed = 2000, }, 
				['Renekton']    = {true, spell = _E,                  range = 450,   projSpeed = 2000, },
				['Sejuani']     = {true, spell = _Q,                  range = 650,   projSpeed = 2000, },
				['Shen']        = {true, spell = _E,                  range = 575,   projSpeed = 2000, },
				['Tristana']    = {true, spell = _W,                  range = 900,   projSpeed = 2000, },
				['Tryndamere']  = {true, spell = 'Slash',             range = 650,   projSpeed = 1450, },
				['XinZhao']     = {true, spell = _E,                  range = 650,   projSpeed = 2000, }, 
			}
			if unit.type == myHero.type and unit.team ~= myHero.team and isAGapcloserUnit[unit.charName] and GetDistance(unit) < 2000 and spell ~= nil then
				if spell.name == (type(isAGapcloserUnit[unit.charName].spell) == 'number' and unit:GetSpellData(isAGapcloserUnit[unit.charName].spell).name or isAGapcloserUnit[unit.charName].spell) then
					if spell.target ~= nil and spell.target.isMe or isAGapcloserUnit[unit.charName].spell == 'blindmonkqtwo' then
						if E.IsReady() then
							E.target = unit
							CastSpell(_E, unit.x, unit.z)
						end
					else
						spellExpired = false
						informationTable = {
							spellSource = unit,
							spellCastedTick = GetTickCount(),
							spellStartPos = Point(spell.startPos.x, spell.startPos.z),
							spellEndPos = Point(spell.endPos.x, spell.endPos.z),
							spellRange = isAGapcloserUnit[unit.charName].range,
							spellSpeed = isAGapcloserUnit[unit.charName].projSpeed
						}
					end
				end
			end
		
    end
    
end			



function SpellExpired()
	if HazMenu.AGP and not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange / informationTable.spellSpeed) * 1000 then
		local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
		local spellStartPosition = informationTable.spellStartPos + spellDirection
		local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
		local heroPosition = Point(myHero.x, myHero.z)
		local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
	
			local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
			

			if lineSegment:distance(heroPosition) <= 400 and E.IsReady() then
				E.target = unit
				CastSpell(_E, unit.x, unit.z)
			end

		else
			spellExpired = true
			informationTable = {}
		end
        
               
               
    
end


--combo-----------------------------------------------------------------------------------------------------------------


function Combo()
	if ValidTarget(target) then
        	if W.IsReady() and HazMenu.Combo.comboW then
			    if GetDistance(myHero, target) <=  550 then
			       CastSpell(_W)
			    end
			end
			
			    if R.IsReady() and HazMenu.Combo.comboR then
			        if HazMenu.Combo.comboRm then
				      castRm()
				     
			     elseif not HazMenu.Combo.comboRm then
                     castR()  	
			        end
				end
			if E.IsReady() and HazMenu.Combo.comboE then
			  if GetDistance(target) <= E.range then 
				if HazMenu.More.Pred then
		            
			        divineE()
                
				elseif not HazMenu.More.Pred then		
			         local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, E.delay, E.width, E.range, E.speed, myHero, true)
			         if HitChance >= 2 and GetDistance(CastPosition) <= E.range and E.IsReady() then
				        CastSpell(_E, CastPosition.x, CastPosition.z)
		             end
		        end
			end	
			end	
                if Q.IsReady() and HazMenu.Combo.comboQ then
				      if HazMenu.More.Pred then
					  divineQ()
					  
					  elseif not HazMenu.More.Pred then
				  	    local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, Q.delay, Q.width, Q.range, Q.speed, myHero, false)
			            if HitChance >= 2 and GetDistance(CastPosition) <= Q.range then			 
				           CastSpell(_Q, CastPosition.x, CastPosition.z)				
			            end           
				
				end	
			--elseif not HazMenu.Combo.stunQ then
			    end 
	        
	end	
end



--harass------------------------------------------------------------------------------------------------------------



function Poke()
	if ValidTarget(target) then
	    if E.IsReady() and HazMenu.Harass.harassE then
			     if GetDistance(target) <= E.range then 
				    if HazMenu.More.Pred then
		            
			        divineE()
                    
				elseif not HazMenu.More.Pred then					         
			         local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, E.delay, E.width, E.range, E.speed, myHero, true)
			         if HitChance >= 2 and GetDistance(CastPosition) <= E.range and E.IsReady() then
				        CastSpell(_E, CastPosition.x, CastPosition.z)
		             end
		            end
			    end	
		end		
		if Q.IsReady() and HazMenu.Harass.harassQ and myHero.mana / myHero.maxMana > HazMenu.Harass.Mana /100 then
		    if HazMenu.More.Pred then
				 divineQ()
			
			elseif not HazMenu.More.Pred then
		    local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, Q.delay, Q.width, Q.range, Q.speed, myHero, false)
			if HitChance >= 2 and GetDistance(CastPosition) <= Q.range then				 
			   CastSpell(_Q, CastPosition.x, CastPosition.z)				
			end
		    end
		end	
		if W.IsReady() and HazMenu.Harass.harassW then
		    if myHero.mana / myHero.maxMana > HazMenu.Harass.Mana /100 then
		       if GetDistance(myHero, target) <= 550 then
			     CastSpell(_W)
			    end  		    
		    end
	    end
    end
end



--farm--------------------------------------------------------------------------------------------------------------------



function Farm()
	Minions:update()
	
	for i, Minion in pairs(Minions.objects) do
		if Q.IsReady() and HazMenu.Farm.farmQ and #Minions.objects > 2 then
			if myHero.mana / myHero.maxMana > HazMenu.Farm.Mana /100 then
			    if ValidTarget(Minion) then
			        local AOECastPosition, MainTargetHitChance, nTargets = VP:GetLineAOECastPosition(Minion, Q.delay, Q.width, 750, Q.speed, myHero)
			        if nTargets >= 1 and Q.IsReady() then
			           CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
			        end
				end	
			end
   		end
		if  W.IsReady() and HazMenu.Farm.farmW then
		    if myHero.mana / myHero.maxMana > HazMenu.Farm.Mana /100 then
		       if GetDistance(myHero, Minion) <= W.range then
			     CastSpell(_W)
			    end
   		    
		    end
	    end
	end	
    JungleMinions:update()
	for i, Minion in pairs(JungleMinions.objects) do
	    if Q.IsReady() and HazMenu.Farm.farmQ then
			if myHero.mana / myHero.maxMana > HazMenu.Farm.Mana /100 then
			    local AOECastPosition, MainTargetHitChance, nTargets = VP:GetLineAOECastPosition(Minion, Q.delay, Q.width, E.range, Q.speed, myHero)
			     if nTargets >= 1 then
			        CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
			    end
			end
   		end
		if  W.IsReady() and HazMenu.Farm.farmW then
		    if myHero.mana / myHero.maxMana > HazMenu.Farm.Mana /100 then
		       
			     CastSpell(_W)
			       		    
		    end
	    end
	end	
end


----------------------------------------DivineE-------------------------------

function divineE()
local target = DPTarget(target)
			        local AhriE = LineSS(E.speed, E.range, E.width, E.delay, 0)
			        local State, Position, perc = DP:predict(target, AhriE)
			        if State == SkillShot.STATUS.SUCCESS_HIT then 
				
                      CastSpell(_E, Position.x, Position.z)

				    end
end


function divineQ()
local target = DPTarget(target)
			        local AhriQ = LineSS(Q.speed, Q.range, Q.width, Q.delay, math.huge)
			        local State, Position, perc = DP:predict(target, AhriQ)
			        if State == SkillShot.STATUS.SUCCESS_HIT then 
				
                      CastSpell(_Q, Position.x, Position.z)

				    end
end


--calcdmg----------------------------------------------------------------------------------------------------------

function calcDmg()
	for i=1, heroManager.iCount do
		local Target = heroManager:GetHero(i)
		if ValidTarget(Target) and Target ~= nil then
			qDmg = ((QREADY and getDmg("Q", Target, myHero)) or 0)
			wDmg = ((WREADY and getDmg("W", Target, myHero)) or 0)
			eDmg = ((EREADY and getDmg("E", Target, myHero)) or 0)
			rDmg = ((RREADY and getDmg("R", Target, myHero)) or 0)
			allDmg = ((qDmg)*2) + ((wDmg)*3) + (eDmg) + ((rDmg)*3)
			
			if Target.health > allDmg then
				KillText[i] = 1
			elseif Target.health <= allDmg then
				KillText[i] = 2
			end
		end
	end	
end

function LFCfunc()
	if not HazMenu.LFC.LagFree then _G.DrawCircle = _G.oldDrawCircle end
    if HazMenu.LFC.LagFree then _G.DrawCircle = DrawCircle2 end
end

-- Barasia, vadash, viseversa

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
	if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
		DrawCircleNextLvl(x, y, z, radius, 1, color, HazMenu.LFC.CL) 
	end
end


--HPbar draws-------------------------------------------------------------------------------------------------


for i, enemy in ipairs(GetEnemyHeroes()) do
    enemy.barData = {PercentageOffset = {x = 0, y = 0} }
end

function GetEnemyHPBarPos(enemy)

    if not enemy.barData then
        return
    end

    local barPos = GetUnitHPBarPos(enemy)
    local barPosOffset = GetUnitHPBarOffset(enemy)
    local barOffset = Point(enemy.barData.PercentageOffset.x, enemy.barData.PercentageOffset.y)
    local barPosPercentageOffset = Point(enemy.barData.PercentageOffset.x, enemy.barData.PercentageOffset.y)

    local BarPosOffsetX = 169
    local BarPosOffsetY = 47
    local CorrectionX = 16
    local CorrectionY = 4

    barPos.x = barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + CorrectionX
    barPos.y = barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY 

    local StartPos = Point(barPos.x, barPos.y)
    local EndPos = Point(barPos.x + 103, barPos.y)

    return Point(StartPos.x, StartPos.y), Point(EndPos.x, EndPos.y)

end


function DrawIndicator(enemy)
	local Qdmg, Wdmg, Edmg, Rdmg, AAdmg = getDmg("Q", enemy, myHero), getDmg("W", enemy, myHero), getDmg("E", enemy, myHero), getDmg("R", enemy, myHero), getDmg("AD", enemy, myHero)
	
	Qdmg = ((Q.IsReady and Qdmg) or 0)
	Wdmg = ((W.IsReady and Wdmg) or 0)
	Edmg = ((E.IsReady and Edmg) or 0)
	Rdmg = ((R.IsReady and Rdmg) or 0)
	AAdmg = ((Aadmg) or 0)

    local damage = ((Qdmg)*2) + ((Wdmg)*3) + (Edmg) + ((Rdmg)*3)

    local SPos, EPos = GetEnemyHPBarPos(enemy)

    if not SPos then return end

    local barwidth = EPos.x - SPos.x
    local Position = SPos.x + math.max(0, (enemy.health - damage) / enemy.maxHealth) * barwidth

	DrawText("|", 16, math.floor(Position), math.floor(SPos.y + 8), ARGB(255,0,255,0))
    DrawText("HP: "..math.floor(enemy.health - damage), 12, math.floor(SPos.x + 25), math.floor(SPos.y - 15), (enemy.health - damage) > 0 and ARGB(255, 0, 255, 0) or  ARGB(255, 255, 0, 0))
end


--single spells-------------------------------------------------------------------------------------------------


function castQ()
    if ValidTarget(Target) then
   	    if Q.IsReady() then
	        local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, Q.delay, Q.width, Q.range, Q.speed, myHero, false)
			if HitChance >= 2 and GetDistance(CastPosition) <= Q.range then
				 --if HazMenu.Misc.Pak and VIP_USER then
				     --packetCast(_Q, CastPosition.x, CastPosition.z)
					--else
				    CastSpell(_Q, CastPosition.x, CastPosition.z)
				--end
			end   
		end
    end
end



function castE()
    if ValidTarget(target) then 
	    if E.IsReady() then
			     if GetDistance(enemy) <= E.range then 
			         local CastPosition, HitChance, CastPos = VP:GetLineCastPosition(target, E.delay, E.width, E.range, E.speed, myHero, true)
			         if HitChance >= 2 and GetDistance(CastPosition) <= E.range and E.IsReady() then
				        CastSpell(_E, CastPosition.x, CastPosition.z)
		             end
		        end
		end	
	end
	    
	
end



function castR()
    if ValidTarget(target) then 
	    if R.IsReady() then
			    if GetDistance(target) <= Q.range then 
			        CastSpell(_R, target.x, target.z)
		        end
		end	
	end
end


function castRm()
    if ValidTarget(target) then 
	    if R.IsReady() then
            if GetDistance(target) <= Q.range then 
			local Mouse = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
			CastSpell(_R, Mouse.x, Mouse.z) 
			end   
	    end
	end	
end
------------------------------------------------------Zhonya--------------------------------------------------


function GetSlotItem(id, unit)
	
	unit 		= unit or myHero

	if (not ItemNames[id]) then
		return ___GetInventorySlotItem(id, unit)
	end

	local name	= ItemNames[id]
	
	for slot = ITEM_1, ITEM_7 do
		local item = unit:GetSpellData(slot).name
		if ((#item > 0) and (item:lower() == name:lower())) then
			return slot
		end
	end

end



function Zhonya()
	local Slot = GetInventorySlotItem(3157)
		if Slot ~= nil and myHero:CanUseSpell(Slot) == READY then
			local Range = 900
			local Amount = HazMenu.Misc.Amount
			local health = myHero.health
			local maxHealth = myHero.maxHealth
				if ((health/maxHealth)*100) <= HazMenu.Misc.zhonyaHP and CountEnemyHeroInRange(Range) >= Amount then
			CastSpell(Slot)
		end
	end
end


function CountEnemyHeroInRange(range)
	local enemyInRange = 0
		for i = 1, heroManager.iCount, 1 do
			local hero = heroManager:getHero(i)
				if ValidTarget(hero,range) then
			enemyInRange = enemyInRange + 1
			end
		end
	return enemyInRange
end



------------------------------------------------------------------------------------------------


function moveto()
    if Q.IsReady() and HazMenu.More.moveto then 
	  MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
        HeroPos = Vector(myHero.x, myHero.y, myHero.z)
        DashPos = HeroPos + ( HeroPos - MPos )*(500/GetDistance(mousePos))
        myHero:MoveTo(mousePos.x, mousePos.z)
        CastSpell(_Q,DashPos.x, DashPos.z)
        myHero:MoveTo(mousePos.x, mousePos.z)
    end
end

