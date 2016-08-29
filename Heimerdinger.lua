local ver = "0.06"

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end

if GetObjectName(GetMyHero()) ~= "Heimerdinger" then return end

require("DamageLib")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat('<font color = "#00FFFF">New version found! ' .. data)
        PrintChat('<font color = "#00FFFF">Downloading update, please wait...')
        DownloadFileAsync('https://raw.githubusercontent.com/allwillburn/Heimerdinger/master/Heimerdinger.lua', SCRIPT_PATH .. 'Heimerdinger.lua', function() PrintChat('<font color = "#00FFFF">Update Complete, please 2x F6!') return end)
    else
        PrintChat('<font color = "#00FFFF">No updates found!')
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/allwillburn/Heimerdinger/master/Heimerdinger.version", AutoUpdate)


GetLevelPoints = function(unit) return GetLevel(unit) - (GetCastLevel(unit,0)+GetCastLevel(unit,1)+GetCastLevel(unit,2)+GetCastLevel(unit,3)) end
local SetDCP, SkinChanger = 0
local HeimerdingerW = {delay = .5, range = 1100, width = 200, speed = 902}
local HeimerdingerE = {delay = .5, range = 1000, width = 925, speed = 2500}


local HeimerdingerMenu = Menu("Heimerdinger", "Heimerdinger")

HeimerdingerMenu:SubMenu("Combo", "Combo")

HeimerdingerMenu.Combo:Boolean("Q", "Use Q in combo", true)
HeimerdingerMenu.Combo:Boolean("W", "Use W in combo", true)
HeimerdingerMenu.Combo:Slider("Wpred", "W Hit Chance", 3,0,10,1)
HeimerdingerMenu.Combo:Boolean("E", "Use E in combo", true)
HeimerdingerMenu.Combo:Slider("Epred", "E Hit Chance", 3,0,10,1)
HeimerdingerMenu.Combo:Boolean("R", "Use R in combo", true)
HeimerdingerMenu.Combo:Boolean("Gunblade", "Use Gunblade", true)
HeimerdingerMenu.Combo:Boolean("GLP800", "Use GLP800", false) 
HeimerdingerMenu.Combo:Boolean("Protobelt", "Use Protobelt", false) 


HeimerdingerMenu:SubMenu("AutoMode", "AutoMode")
HeimerdingerMenu.AutoMode:Boolean("Level", "Auto level spells", false)
HeimerdingerMenu.AutoMode:Boolean("Ghost", "Auto Ghost", false)
HeimerdingerMenu.AutoMode:Boolean("Q", "Auto Q", false)
HeimerdingerMenu.AutoMode:Boolean("W", "Auto W", false)
HeimerdingerMenu.AutoMode:Boolean("E", "Auto E", false)
HeimerdingerMenu.AutoMode:Boolean("R", "Auto R", false)

HeimerdingerMenu:SubMenu("LaneClear", "LaneClear")
HeimerdingerMenu.LaneClear:Boolean("Q", "Use Q", true)
HeimerdingerMenu.LaneClear:Boolean("W", "Use W", true)
HeimerdingerMenu.LaneClear:Boolean("E", "Use E", true)

HeimerdingerMenu:SubMenu("Harass", "Harass")
HeimerdingerMenu.Harass:Boolean("Q", "Use Q", true)
HeimerdingerMenu.Harass:Boolean("W", "Use W", true)
HeimerdingerMenu.Harass:Slider("Wpred", "W Hit Chance", 3,0,10,1)
HeimerdingerMenu.Harass:Boolean("E", "Use E", true)

HeimerdingerMenu:SubMenu("KillSteal", "KillSteal")
HeimerdingerMenu.KillSteal:Boolean("Q", "KS w Q", true)
HeimerdingerMenu.KillSteal:Boolean("W", "KS w W", true)
HeimerdingerMenu.KillSteal:Boolean("E", "KS w E", true)

HeimerdingerMenu:SubMenu("AutoIgnite", "AutoIgnite")
HeimerdingerMenu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)

HeimerdingerMenu:SubMenu("Drawings", "Drawings")
HeimerdingerMenu.Drawings:Boolean("DQ", "Draw Q Range", true)
HeimerdingerMenu.Drawings:Boolean("DW", "Draw W Range", true)
HeimerdingerMenu.Drawings:Boolean("DE", "Draw E Range", true)



HeimerdingerMenu:SubMenu("SkinChanger", "SkinChanger")
HeimerdingerMenu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
HeimerdingerMenu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 1, 0, 6, 1, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

OnTick(function (myHero)
	local target = GetCurrentTarget()
        local Gunblade = GetItemSlot(myHero, 3146)
        local GLP800 = GetItemSlot(myHero, 3030)
        local Protobelt = GetItemSlot(myHero, 3152)
        local HeimerdingerW = {delay = .5, range = 1100, width = 200, speed = 902}
        local HeimerdingerE = {delay = .5, range = 1000, width = 925, speed = 2500}


	--AUTO LEVEL UP
	if HeimerdingerMenu.AutoMode.Level:Value() then

			spellorder = {_Q, _E, _W, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			end
	end
        
        --Harass
                if Mix:Mode() == "Harass" then
            if HeimerdingerMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 450) then			
                                CastSkillShot(_Q, target.pos)
                                end
            
            if HeimerdingerMenu.Harass.W:Value() and ValidTarget(target, 1100) then
		   local WPred = GetPrediction(target,HeimerdingerW)
                       if WPred.hitChance > (HeimerdingerMenu.Harass.Wpred:Value() * 0.1) and not WPred:mCollision(1) then
                                 CastSkillShot(_W,WPred.castPos)
                       end		
            end		

            if HeimerdingerMenu.Harass.E:Value() and ValidTarget(target, 1100) then
				CastSkillShot(_E, target.pos)
                                end     
            end

	--COMBO
		if Mix:Mode() == "Combo" then
            if HeimerdingerMenu.Combo.Gunblade:Value() and Gunblade > 0 and Ready(Gunblade) and ValidTarget(target, 700) then
			      CastTargetSpell(target, Gunblade)
                              end
            if HeimerdingerMenu.Combo.GLP800:Value() and GLP800 > 0 and Ready(GLP800) and ValidTarget(target, 700) then
			      CastSkillShot(target, GLP800)
                              end
            if HeimerdingerMenu.Combo.Protobelt:Value() and Protobelt > 0 and Ready(Protobelt) and ValidTarget(target, 700) then
			      CastSkillShot(target, Protobelt)
                              end

            if HeimerdingerMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 450) then 
                               CastSkillShot(_Q, target.pos)                                    
                               end

	    if HeimerdingerMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 925) then
		local EPred = GetPrediction(target,HeimerdingerE)
                       if EPred.hitChance > (HeimerdingerMenu.Combo.Wpred:Value() * 0.1) then
                                 CastSkillShot(_E,EPred.castPos)
                       end		
            end	

            if HeimerdingerMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 1100) then
		local WPred = GetPrediction(target,HeimerdingerW)
                       if WPred.hitChance > (HeimerdingerMenu.Combo.Wpred:Value() * 0.1) and not WPred:mCollision(1) then
                                 CastSkillShot(_W,WPred.castPos)
                       end		
            end			
	    
            if HeimerdingerMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 700) then CastSpell(_R) 
				
                               if target.distance > 600 then CastTargetSpell(target, _W) elseif target.distance < 600 then CastTargetSpell(target, _Q) 
                               end
                    end
            end
                    
            

         --AUTO IGNITE
	for _, enemy in pairs(GetEnemyHeroes()) do
		
		if GetCastName(myHero, SUMMONER_1) == 'SummonerDot' then
			 Ignite = SUMMONER_1
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end

		elseif GetCastName(myHero, SUMMONER_2) == 'SummonerDot' then
			 Ignite = SUMMONER_2
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end
		end

	end

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if IsReady(_Q) and ValidTarget(enemy, 450) and HeimerdingerMenu.KillSteal.Q:Value() and GetHP(enemy) < getdmg("Q",enemy) then 
                                      CastSkillShot(_Q, target.pos)	         
                                      end 
                if IsReady(_W) and ValidTarget(enemy, 1100) and HeimerdingerMenu.KillSteal.W:Value() and GetHP(enemy) < getdmg("W",enemy) then 
                                      CastTargetSpell(target, _W)
                                      end
                if IsReady(_E) and ValidTarget(enemy, 925) and HeimerdingerMenu.KillSteal.E:Value() and GetHP(enemy) < getdmg("E",enemy) then 
                                      CastSkillShot(_E, target.pos)
                
                end
      end

      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if HeimerdingerMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 450) then
	        	CastSkillShot(_Q, closeminion)
                end
                if HeimerdingerMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 925) then
	        	CastSkillShot(_E, closeminion)
	        end
                if HeimerdingerMenu.LaneClear.W:Value() and Ready(_W) and ValidTarget(closeminion, 1100) then
	        	CastSkillShot(_W, closeminion)
	        end
                
          end
      end
        --AutoMode
        if HeimerdingerMenu.AutoMode.Q:Value() then        
          if Ready(_Q) and ValidTarget(target, 450) then
		      CastSkillShot(_Q, target.pos)
          end
        end 
        if HeimerdingerMenu.AutoMode.W:Value() then        
          if Ready(_W) and ValidTarget(target, 1100) then
	  	      CastTargetSpell(target, _W)
          end
        end
        if HeimerdingerMenu.AutoMode.E:Value() then        
	  if Ready(_E) and ValidTarget(target, 925) then
		      CastSkillShot(_E, target.pos)
	  end
        end
        if HeimerdingerMenu.AutoMode.R:Value() then        
	  if Ready(_R) and ValidTarget(target, 1100) then
		      CastSpell(_R)
	  end
        end
                
	--AUTO GHOST
	if HeimerdingerMenu.AutoMode.Ghost:Value() then
		if GetCastName(myHero, SUMMONER_1) == "SummonerHaste" and Ready(SUMMONER_1) then
			CastSpell(SUMMONER_1)
		elseif GetCastName(myHero, SUMMONER_2) == "SummonerHaste" and Ready(SUMMONER_2) then
			CastSpell(Summoner_2)
		end
	end
end)

OnDraw(function (myHero)
        
         if HeimerdingerMenu.Drawings.DQ:Value() then
		DrawCircle(GetOrigin(myHero), 700, 0, 200, GoS.Red)
	 end

         if HeimerdingerMenu.Drawings.DW:Value() then
		DrawCircle(GetOrigin(myHero), 1100, 0, 200, GoS.Yellow)
         end
         if HeimerdingerMenu.Drawings.DE:Value() then
		DrawCircle(GetOrigin(myHero), 925, 0, 200, GoS.Blue)
	 end

end)

local function SkinChanger()
	if HeimerdingerMenu.SkinChanger.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end


print('<font color = "#01DF01"><b>Heimerdinger</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')

