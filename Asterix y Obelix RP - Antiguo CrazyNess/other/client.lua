handsup = false
DecorRegister("Handsup", 2)
DecorSetBool(GetPlayerPed(-1), "Handsup", false)

Citizen.CreateThread(function()
 while true do
  Citizen.Wait(50)
  local lPed = GetPlayerPed(-1)
  RequestAnimDict("random@mugging3")
  if not IsPedInAnyVehicle(lPed, false) and not IsPedSwimming(lPed) and not IsPedShooting(lPed) and not IsPedClimbing(lPed) and not IsPedCuffed(lPed) and not IsPedDiving(lPed) and not IsPedFalling(lPed) and not IsPedJumping(lPed) and not IsPedJumpingOutOfVehicle(lPed) and IsPedOnFoot(lPed) and not IsPedRunning(lPed) and not IsPedUsingAnyScenario(lPed) and not IsPedInParachuteFreeFall(lPed) then
   if IsControlPressed(1, 73) then
    if DoesEntityExist(lPed) then
     SetCurrentPedWeapon(lPed, 0xA2719263, true)
     Citizen.CreateThread(function()
      RequestAnimDict("random@mugging3")
      while not HasAnimDictLoaded("random@mugging3") do
       Citizen.Wait(100)
      end

      if not handsup then
       handsup = true
       TaskPlayAnim(lPed, "random@mugging3", "handsup_standing_base", 8.0, -8, -1, 49, 0, 0, 0, 0)
       DecorSetBool(GetPlayerPed(-1), "Handsup", true)
      end   
     end)
    end
   end
  else 
   Citizen.Wait(250)
  end
  if IsControlReleased(1, 73) then
   if DoesEntityExist(lPed) then
    Citizen.CreateThread(function()
     RequestAnimDict("random@mugging3")
     while not HasAnimDictLoaded("random@mugging3") do
      Citizen.Wait(100)
     end

     if handsup then
      handsup = false
      ClearPedSecondaryTask(lPed)
      DecorSetBool(GetPlayerPed(-1), "Handsup", false)
     end
    end)
   end
  else 
   Citizen.Wait(250)
  end
 end
end)

local mp_pointing = false
local keyPressed = false

local function startPointing()
    local ped = GetPlayerPed(-1)
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
    local ped = GetPlayerPed(-1)
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local oldval = false
local oldvalped = false

Citizen.CreateThread(function()
 while true do
  Wait(20)
  if not keyPressed then
   if IsControlPressed(0, 29) and not mp_pointing and IsPedOnFoot(PlayerPedId()) then
    Wait(200)
    if not IsControlPressed(0, 29) then
     keyPressed = true
     startPointing()
     mp_pointing = true
    else
     keyPressed = true
     while IsControlPressed(0, 29) do
      Wait(50)
     end
    end
   elseif (IsControlPressed(0, 29) and mp_pointing) or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
    keyPressed = true
    mp_pointing = false
    stopPointing()
   end
  end

  if keyPressed then
   if not IsControlPressed(0, 29) then
    keyPressed = false
   end
  end
  if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) and not mp_pointing then
   stopPointing()
  end
  if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
   if not IsPedOnFoot(PlayerPedId()) then
    stopPointing()
   else
    local ped = GetPlayerPed(-1)
    local camPitch = GetGameplayCamRelativePitch()
    if camPitch < -70.0 then
     camPitch = -70.0
    elseif camPitch > 42.0 then
     camPitch = 42.0
    end
    camPitch = (camPitch + 70.0) / 112.0

    local camHeading = GetGameplayCamRelativeHeading()
    local cosCamHeading = Cos(camHeading)
    local sinCamHeading = Sin(camHeading)
    if camHeading < -180.0 then
     camHeading = -180.0
    elseif camHeading > 180.0 then
     camHeading = 180.0
    end
    camHeading = (camHeading + 180.0) / 360.0

    local blocked = 0
    local nn = 0

    local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
    local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
    nn,blocked,coords,coords = GetRaycastResult(ray)

    Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
    Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
    Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
    Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

   end
  end
 end
end)

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

RegisterCommand('k', function(source, args, rawCommand)
  local player = GetPlayerPed( -1 )
  if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
   loadAnimDict( "random@arrests" )
   loadAnimDict( "random@arrests@busted" )
   if ( IsEntityPlayingAnim( player, "random@arrests@busted", "idle_a", 3 ) ) then 
    TaskPlayAnim( player, "random@arrests@busted", "exit", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
    Wait (3000)
    TaskPlayAnim( player, "random@arrests", "kneeling_arrest_get_up", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )
   else
    TaskPlayAnim( player, "random@arrests", "idle_2_hands_up", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
    Wait (4000)
    TaskPlayAnim( player, "random@arrests", "kneeling_arrest_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
    Wait (500)
    TaskPlayAnim( player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
    Wait (1000)
    TaskPlayAnim( player, "random@arrests@busted", "idle_a", 8.0, 1.0, -1, 9, 0, 0, 0, 0 )
   end     
  end
end)

