util.AddNetworkString("Notify")

local Entity = FindMetaTable("Entity")

function SendUsrMsg(strName, plyTarget, tblArgs)
	umsg.Start(strName, plyTarget)
	for _, value in pairs(tblArgs or {}) do
		if type(value) == "string" then umsg.String(value)
		elseif type(value) == "number" then umsg.Long(value)
		elseif type(value) == "boolean" then umsg.Bool(value)
		elseif type(value) == "Entity" or type(value) == "Player" then umsg.Entity(value)
		elseif type(value) == "Vector" then umsg.Vector(value)
		elseif type(value) == "Angle" then umsg.Angle(value)
		elseif type(value) == "table" then umsg.String(Json.Encode(value)) end
	end
	umsg.End()
end

function CreateWorldItem(strItem, intAmount, vecPostion)
	local tblItemTable = ItemTable(strItem)
	if tblItemTable then
		local entWorldProp = ents.Create("prop_physics_multiplayer")
		entWorldProp:SetModel( "models/props_junk/cardboard_box004a.mdl" )
		entWorldProp.Item = strItem
		entWorldProp.Amount = intAmount or 1
		entWorldProp:Spawn()
		entWorldProp:SetPos(vecPostion or Vector(0, 0, 0))
		if !tblItemTable.QuestItem then 
			timer.Simple(15 ,function() if IsValid(entWorldProp) then entWorldProp:SetOwner(nil) end end)
		end
		SafeRemoveEntityDelayed(entWorldProp, 30)
		entWorldProp:SetNWString("ItemName", strItem)
		entWorldProp:SetNWInt("Amount", entWorldProp.Amount)
		entWorldProp:SetCollisionGroup( COLLISION_GROUP_WEAPON  )
		if !util.IsValidProp(entWorldProp:GetModel()) then
			entWorldProp:CreateGrip()
		end
		if tblItemTable.WeaponType then
		end
		return entWorldProp
	end
end

function Entity:Stun(intTime, intSeverity)
	if self.Resistance then if self.Resistance == "Ice" then return end end
	if !self.BeingSlowed then
		intTime = intTime or 3
		local intTotalTime = 0
		local intSlowRate = 0.1
		local startingcolor = self:GetColor()
		local function SlowEnt()
			if self && self:IsValid() then
				if intTotalTime < intTime then
					self:SetPlaybackRate(intSeverity or 0.1)
					intTotalTime = intTotalTime + intSlowRate
					timer.Simple(intSlowRate, SlowEnt, self)
				else
					self:SetPlaybackRate(1)
					self:SetColor(self:GetColor())
					self.BeingSlowed = false
				end
			end
		end
		self:SetColor( Color(200, 200, 255, 255) )
		self.BeingSlowed = true
		SlowEnt()
	end
end

function Entity:IgniteFor(intTime, intDamage, plyPlayer)
	if self.Resistance then if self.Resistance == "Fire" then return end end
	if !self.Ignited then
		intTime = intTime or 3
		local intTotalTime = 0
		local intIgnitedRate = 0.35
		local function IgniteEnt()
			if self && self:IsValid() then
				if intTotalTime < intTime then
					plyPlayer:CreateIndacator(intDamage, self:GetPos(), "red", true)
					local StartingHealth = self:Health() -- Hacky way around self:Ignite dropping npc down to 40 health
					self:SetNWInt("Health", self:Health())
					intTotalTime = intTotalTime + intIgnitedRate
					self:Ignite(intTime,0) -- Used for the effect
					self:SetHealth(StartingHealth - intDamage) -- Starts taking damage
					timer.Simple(intIgnitedRate, IgniteEnt, self)
				else
					self:Extinguish()
					self:SetColor( Color(127, 51, 0, 255) )
					self.Ignited = false
				end
			end
		end
		self:SetColor( Color(200, 0, 0, 255) )
		self.Ignited = true
		IgniteEnt()
	end
end

function GM:RemoveAll(strClass, intTime)
	table.foreach(ents.FindByClass(strClass .. "*"), function(_, ent) SafeRemoveEntityDelayed(ent, intTime or 0) end)
end