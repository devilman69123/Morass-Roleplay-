--[[
	Template — copy to morass_my_car.lua and rename the file to match the entity class.

	Requires Glide Base workshop addon. Models can come from any subscribed pack.
	Do not mount Simfphys/LVS for the same car — port the chassis model here instead.
]]

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_glide_car"
ENT.PrintName = "My Car"
ENT.GlideCategory = "Morass"

ENT.ChassisModel = "models/path/to/chassis.mdl"
ENT.ChassisMass = 1200

if CLIENT then
	ENT.CameraOffset = Vector(-270, 0, 50)

	function ENT:OnCreateEngineStream(stream)
		stream:LoadPreset("f620")
	end
end

-- Then add to MorassGlide.Custom in morass_glide/lua/autorun/sh_morass_glide_config.lua:
-- morass_my_car = "citizen",
