if not MorassGlide then return end

local empty = {}

local function stripEntTable(tbl)
	tbl.Headlights = empty
	tbl.LightSprites = empty
	tbl.SirenLights = empty
	tbl.ExhaustOffsets = empty
	tbl.EngineSmokeStrips = empty
	tbl.EngineFireOffsets = empty
end

hook.Add("PreRegisterSENT", "MorassGlide.StripCitizenLights", function(tbl, class)
	if not MorassGlide.ShouldStripLights(class) then return end
	stripEntTable(tbl)
end)

hook.Add("OnEntityCreated", "MorassGlide.StripCitizenLights", function(ent)
	if not IsValid(ent) or not ent.IsGlideVehicle then return end

	local class = ent:GetClass()
	if not MorassGlide.ShouldStripLights(class) then return end

	ent.Headlights = empty
	ent.LightSprites = empty
	ent.SirenLights = empty

	if ent.RemoveHeadlights then
		ent.RemoveHeadlights = function() end
	end

	ent.headlightState = 0
end)

hook.Add("InitPostEntity", "MorassGlide.ClientMinimal", function()
	timer.Simple(0, function()
		if not Glide or not Glide.Config then return end

		local cfg = Glide.Config

		cfg.headlightShadows = false
		cfg.autoHeadlightOn = false
		cfg.autoHeadlightOff = false
		cfg.autoTurnOffLights = true
		cfg.autoTurnOnEngine = true

		cfg.showSkyboxOnLand = false
		cfg.showSkyboxOnAircraft = false
		cfg.enableTips = false
		cfg.showHUD = false
		cfg.showPassengerList = false
		cfg.showCustomHealth = false
		cfg.showEmptyVehicleHealth = false

		cfg.maxSkidMarkPieces = 80
		cfg.maxTireRollPieces = 40
		cfg.skidmarkTimeLimit = 6
		cfg.reduceTireParticles = true

		cfg.windVolume = 0.35
		cfg.warningVolume = 0.4

		if Glide.DisableSkyboxIndicator then
			Glide.DisableSkyboxIndicator()
		end

		timer.Remove("Glide.AutoToggleHeadlights")
	end)
end)

hook.Add("Glide_OnLocalEnterVehicle", "MorassGlide.NoAutoHeadlights", function()
	timer.Remove("Glide.AutoToggleHeadlights")
end)
