--[[
 * Label    : The spinner scripted entity
 * Author   : DVD ( dvd_video )
 * Date     : 13-03-2017
 * Location : /lua/entities/sent_spinner.lua
 * Requires : /lua/weapons/gmod_tool/stools/spinner.lua
 * Created  : Using tool requirement
 * Defines  : Advanced motor scripted entity
]]--

AddCSLuaFile()

print("SENT:",SysTime(),RealTime(),CurTime())

local sysNow       = SysTime
local curNow       = CurTime
local gsSentHash   = "sent_spinner"
local gsSentName   = gsSentHash:gsub("sent_","")
local varMaxScale  = GetConVar("sbox_max"..gsSentName.."_scale")
local varMaxMass   = GetConVar("sbox_max"..gsSentName.."_mass")
local varMaxRadius = GetConVar("sbox_max"..gsSentName.."_radius")
local varBroadCast = GetConVar("sbox_max"..gsSentName.."_broad")
local varTickRate  = GetConVar("sbox_max"..gsSentName.."_tick")

ENT.Type            = "anim"
if (WireLib) then
  ENT.Base          = "base_wire_entity"
  ENT.WireDebugName = gsSentName:gsub("^%l",string.upper)
else
  ENT.Base          = "base_gmodentity"
end
ENT.PrintName       = gsSentName:gsub("^%l",string.upper)
ENT.Author          = "DVD"
ENT.Contact         = "dvd_video@abv.bg"
ENT.Editable        = true
ENT.Spawnable       = false
ENT.AdminSpawnable  = false

function ENT:GetPower()
  if(SERVER)     then local oSent = self[gsSentHash]; return oSent.Power
  elseif(CLIENT) then return self:GetNWFloat(gsSentHash.."_power") end
end

function ENT:GetLeverCount()
  if(SERVER)     then local oSent = self[gsSentHash]; return oSent.CLev
  elseif(CLIENT) then return self:GetNWInt(gsSentHash.."_lcnt") end
end

function ENT:GetLever()
  if(SERVER)     then local oSent = self[gsSentHash]; return oSent.Lever
  elseif(CLIENT) then return self:GetNWFloat(gsSentHash.."_lever") end
end

function ENT:GetTorqueAxis()
  if(SERVER)     then local oSent = self[gsSentHash]; return oSent.AxiL
  elseif(CLIENT) then return self:GetNWVector(gsSentHash.."_adir") end
end

function ENT:GetTorqueLever()
  if(SERVER)     then local oSent = self[gsSentHash]; return oSent.LevL
  elseif(CLIENT) then return self:GetNWVector(gsSentHash.."_ldir") end
end

function ENT:GetTorqueForce()
  if(SERVER)     then local oSent = self[gsSentHash]; return oSent.ForL
  elseif(CLIENT) then return self:GetNWVector(gsSentHash.."_fdir") end
end

function ENT:GetSpinCenter()
  if(SERVER)     then return self:GetPhysicsObject():GetMassCenter()
  elseif(CLIENT) then return self:GetNWVector(gsSentHash.."_cen") end
end

function ENT:IsToggled()
  if(SERVER)     then local oSent = self[gsSentHash]; return oSent.Togg
  elseif(CLIENT) then return self:GetNWVector(gsSentHash.."_togg") end
end

if(SERVER) then

  function ENT:Initialize()
    self[gsSentHash] = {}; local oSent = self[gsSentHash]
    oSent.Dir  = 0        -- Power sign for reverse support
    oSent.CLev = 0        -- How many spinner levers do we have (allocate)
    oSent.Radi = 0        -- Collision radius
    oSent.DAng = 0        -- Store the angle delta to avoid calculating it every frame on SV
    oSent.Tick = 5        -- Entity ticking interval ( milliseconds )
    oSent.Rate = {}       -- This holds the time rates for the entity
    oSent.Rate[1] = varTickRate:GetFloat()  -- Entity tick rate [ms]
    oSent.Rate[2] = varBroadCast:GetFloat() -- Client broadcast interval [ms]
    oSent.Rate[3] = 0                       -- Start system time [s]
    oSent.Rate[4] = 0                       -- Time execution delta [ms]
    oSent.Rate[5] = 0                       -- Time delta sum for broadcasting [ms]
    oSent.Rate[6] = 0                       -- The actual time reached for broadcasting [ms]
    oSent.Rate[7] = 0                       -- Duty cycle (0-100)% of tick rate used for calculations []
    oSent.On   = false    -- Enable/disable working
    oSent.Togg = false    -- Toggle the spinner
    oSent.LAng = Angle()  -- Temporary angle server-side used for rotation
    oSent.PowT = Vector() -- Temporary power vector
    oSent.LevT = Vector() -- Temporary lever vector
    oSent.ForL = Vector() -- Local force spin direction list (forward)
    oSent.LevL = Vector() -- Local lever list (right)
    oSent.AxiL = Vector() -- Local spin axis ( Up )
    oSent.LevW = Vector() -- World lever (right)(allocate memory)(temporary)
    oSent.ForW = Vector() -- World force spin direction (forward)(allocate memory)(temporary)
    oSent.AxiW = Vector() -- World spin axis ( Up ) allocate memory
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid  (SOLID_VPHYSICS)
    if(WireLib)then
      WireLib.CreateSpecialInputs(self,{
        "On",
        "Power",
        "Lever",
        "Force"
      }, { "NORMAL", "NORMAL", "NORMAL", "VECTOR"}, {
        " Start/Stop ",
        " Force spin magnitude ",
        " Force spin leverage ",
        " Center force vector "
      })
      WireLib.CreateSpecialOutputs(self,{
        "RPM" ,
        "Axis",
        "Rate"
      }, { "NORMAL", "VECTOR", "ARRAY"}, {
        " Revolutions per minute ",
        " Spinner rotation axis ",
        " Benchmark times and events "
      })
    end; return true
  end

  local function getPower(vRes, vVec, nNum)
    vRes:Set(vVec); vRes:Mul(nNum); return vRes end

  local function getLever(vRes, vPos, vVec, nNum)
    vRes:Set(vVec); vRes:Mul(nNum); vRes:Add(vPos); return vRes end

  function ENT:SetPhysRadius(nRad)
    local nRad = math.Clamp(tonumber(nRad) or 0, 0, varMaxRadius:GetFloat())
    if(nRad > 0) then
      local oSent = self[gsSentHash]
      local vMin  = Vector(-nRad,-nRad,-nRad)
      local vMax  = Vector( nRad, nRad, nRad)
      self:PhysicsInitSphere(nRad)
      self:SetCollisionBounds(vMin, vMax)
      self:PhysWake(); oSent.Radi = nRad
    end; return true
  end

  function ENT:SetPower(nPow)
    local oSent = self[gsSentHash] -- Magnitude of the spinning force
    oSent.Power = math.Clamp((tonumber(nPow) or 0), -varMaxScale:GetFloat(), varMaxScale:GetFloat())
    self:SetNWFloat(gsSentHash.."_power", oSent.Power); return true
  end

  function ENT:SetLever(nLev)
    local oSent = self[gsSentHash] -- Magnitude of the spinning force
    oSent.Lever = math.Clamp((tonumber(nLev) or 0), 0, varMaxScale:GetFloat())
    if(oSent.Lever == 0) then -- Use the half of the bounding box size
      vMin, vMax = self:OBBMins(), self:OBBMaxs()
      oSent.Lever = ((vMax - vMin):Length()) / 2
    end
    self:SetNWFloat(gsSentHash.."_lever", oSent.Lever); return true
  end

  function ENT:SetTorqueAxis(vDir)
    local oSent = self[gsSentHash]
    if(vDir:Length() == 0) then
      ErrorNoHalt("ENT.SetTorqueAxis: Spinner axis invalid\n"); self:Remove(); return false end
    oSent.AxiL:Set(vDir); oSent.AxiL:Normalize()
    self:SetNWVector(gsSentHash.."_adir",oSent.AxiL); return true
  end

  function ENT:SetTorqueLever(vDir, nCnt)
    local oSent = self[gsSentHash]
    local nCnt  = (tonumber(nCnt) or 0)
    if(nCnt <= 0) then
      ErrorNoHalt("ENT.SetTorqueLever: Spinner lever count invalid\n"); self:Remove(); return false end
    if(vDir:Length() == 0) then
      ErrorNoHalt("ENT.SetTorqueLever: Spinner force lever invalid\n"); self:Remove(); return false end
    oSent.CLev = nCnt
    oSent.DAng = (360 / nCnt)
    oSent.LevL:Set(vDir) -- Lever direction matched to player right
    oSent.ForL:Set(oSent.AxiL:Cross(oSent.LevL)) -- Force
    oSent.LevL:Set(oSent.ForL:Cross(oSent.AxiL)) -- Lever
    oSent.ForL:Normalize(); oSent.LevL:Normalize()
    self:SetNWInt(gsSentHash.."_lcnt",oSent.CLev)
    self:SetNWVector(gsSentHash.."_ldir",oSent.LevL); return true
  end

  function ENT:SetToggled(bTogg)
    local oSent = self[gsSentHash]; oSent.Togg = tobool(bTogg or false)
    self:SetNWBool(gsSentHash.."_togg", oSent.Togg) end

  function ENT:Setup(stSpinner)
    self:SetPhysRadius(stSpinner.Radi)         -- Set the radius if given
    local oPhys = self:GetPhysicsObject()
    if(oPhys and oPhys:IsValid()) then
      self:SetToggled(stSpinner.Togg)          -- Is it going to be toggled
      self:SetTorqueAxis(stSpinner.AxiL)       -- Axis direction
      self:SetPower(stSpinner.Power)           -- Torque amount
      self:SetTorqueLever(stSpinner.LevL, stSpinner.CLev) -- Lever direction and count
      self:SetLever(stSpinner.Lever)           -- Leverage length
      self:SetNWVector(gsSentHash.."_cen", oPhys:GetMassCenter())
      local oSent = self[gsSentHash]
      local nMass = math.Clamp(tonumber(stSpinner.Mass) or 1, 1, varMaxMass:GetFloat())
      oPhys:SetMass(nMass); oSent.Mass = nMass -- Mass
      oSent.Prop = stSpinner.Prop              -- Model
      oSent.KeyF = stSpinner.KeyF              -- Forward spin key ( positive power )
      oSent.KeyR = stSpinner.KeyR              -- Forward spin key ( negative power )
    else ErrorNoHalt("ENT.Setup: Spinner physics invalid\n"); self:Remove(); return false end
    collectgarbage(); return true -- Everything is fine !
  end

  -- In Wiremod this is done in /registerOperator("iwc", "", "n", function(self, args)/
  -- https://facepunch.com/showthread.php?t=1566053&p=52298677#post52298677
  -- https://github.com/wiremod/wire/blob/master/lua/entities/gmod_wire_expression2/core/core.lua#L232
  function ENT:HasWire(sIn)
    local tIn = (sIn and self.Inputs[sIn] or nil)
    return ((tIn and IsValid(tIn.Src)) and tIn or nil)
  end

  function ENT:ReadWire(sIn)
    local tIn = self:HasWire(sIn)
    return (tIn and tIn.Value or nil)
  end

  function ENT:WriteWire(sOut, anyVal)
    WireLib.TriggerOutput(self, sOut, anyVal); return self
  end

  function ENT:TimeTic()
    local tmRate  = self[gsSentHash].Rate
    local nxTime  = (tmRate[1] / 1000) -- Entity sampling time [s]
    self:NextThink(curNow() + nxTime) -- Add apples to apples. Thanks Applejack !
    local goTime  = sysNow(); tmRate[3] = goTime -- Start time [s]
  end

  function ENT:TimeToc()
    local tmRate = self[gsSentHash].Rate
    local toTime = tmRate[1] -- Entity tick rate [ms]
    local goTime = tmRate[3] -- Start time [s]
    local snTime = tmRate[5] -- Current time internal for broadcast [ms]
    local dtTime = (1000 * (sysNow() - goTime)); tmRate[4] = dtTime -- Time execution delta [ms]   
    if(dtTime > toTime) then
      ErrorNoHalt("ENT.Think: Spinner out of time margin\n"); self:Remove(); end
    tmRate[7] = ((dtTime / toTime) * 100) -- Benchmarking duty cycle
    snTime = snTime + dtTime; tmRate[5] = snTime
  end

  function ENT:TimeNetwork(...)
    local tmRate = self[gsSentHash].Rate
    local bcTime = tmRate[2] -- Broadcast interval [ms]
    local snTime = tmRate[5] -- Current time internal for broadcast [ms]
    if(snTime >= bcTime) then
      local val = {...} -- Values stack for networking
      self:SetNWFloat(gsSentHash.."_power", val[1])
      self:SetNWFloat(gsSentHash.."_lever", val[2])
      tmRate[5] = 0      -- Register that we are at the beginning and waiting for another event
      tmRate[6] = snTime -- How much time is actually matched to the interval chosen
    end
  end

  function ENT:Think()
    self:TimeTic()
    local oSent = self[gsSentHash]
    local oPhys, Pw, Le = self:GetPhysicsObject(), 0, 0
    if(oPhys and oPhys:IsValid()) then
      local vCn, wFr = self:LocalToWorld(oPhys:GetMassCenter()), nil
      if(WireLib) then wFr = self:ReadWire("Force")
        local wOn = self:ReadWire("On")
        local wPw = self:ReadWire("Power")
        local wLe = self:ReadWire("Lever")
        if(wLe ~= nil) then oSent.Lever = wLe end
        if(wOn ~= nil) then oSent.On = (wOn ~= 0) end
        if(wPw ~= nil) then oSent.Power, oSent.Dir = wPw, 1 end
      end -- Do not change internal setting with a peak when wire is disconnected
      if(oSent.On) then -- Disable toggling via numpad if wire is connected
        local vPwt, vLvt, eAng = oSent.PowT, oSent.LevT, self:GetAngles()
        local vLew, vAxw, aLev = oSent.LevW, oSent.AxiW, oSent.LAng
        Le, Pw = oSent.Lever, (oSent.Power * oSent.Dir)
        vAxw:Set(oSent.AxiL); vAxw:Rotate(eAng)
        vLew:Set(oSent.LevL); vLew:Rotate(eAng)
        aLev:Set(vLew:AngleEx(vAxw))
        for ID = 1, oSent.CLev do
          local cLev, cFor = aLev:Forward(), aLev:Right(); cFor:Mul(-1)
          oPhys:ApplyForceOffset(getPower(vPwt, cFor, Pw), getLever(vLvt, vCn, cLev, Le))
          aLev:RotateAroundAxis(vAxw, oSent.DAng)
        end
        if(WireLib) then -- Take the down-force into account ( if given )
          if(wFr and wFr:Length() > 0) then oPhys:ApplyForceCenter(wFr) end
          self:WriteWire("Axis", vAxw)
        end
      end
      if(WireLib) then
        self:WriteWire("RPM", oPhys:GetAngleVelocity():Dot(oSent.AxiL) / 6) end
    else ErrorNoHalt("ENT.Think: Spinner physics invalid\n"); self:Remove(); end
    if(WireLib) then self:WriteWire("Rate", oSent.Rate) end
    self:TimeToc(); self:TimeNetwork(Pw, Le); return true
  end

  local function spinForward(oPly, oEnt)
    if(not (oEnt and oEnt:IsValid())) then return end
    if(not (oEnt:GetClass() == gsSentHash)) then return end
    local Data = oEnt[gsSentHash]
    if(Data.On and oEnt:IsToggled()) then Data.On = false
    else Data.Dir, Data.On = 1, true end
  end

  local function spinReverse(oPly, oEnt)
    if(not (oEnt and oEnt:IsValid())) then return end
    if(not (oEnt:GetClass() == gsSentHash)) then return end
    local Data = oEnt[gsSentHash]
    if(Data.On and oEnt:IsToggled()) then Data.On = false
    else Data.Dir, Data.On = -1, true end
  end

  local function spinStop(oPly, oEnt)
    if(not (oEnt and oEnt:IsValid())) then return end
    if(not (oEnt:GetClass() == gsSentHash)) then return end
    local Data = oEnt[gsSentHash]
    if(not oEnt:IsToggled()) then Data.Dir, Data.On = 0, false end
  end

  numpad.Register(gsSentHash.."_spinForward_On" , spinForward)
  numpad.Register(gsSentHash.."_spinForward_Off", spinStop)
  numpad.Register(gsSentHash.."_spinReverse_On" , spinReverse)
  numpad.Register(gsSentHash.."_spinReverse_Off", spinStop)

end


