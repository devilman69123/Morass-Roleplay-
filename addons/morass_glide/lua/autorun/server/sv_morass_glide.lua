if not MorassGlide then return end

local function setOwner(ply, ent)
	if not ply:GetCharacter() then return end

	ent:SetNetVar("owner", ply:GetCharacter():GetID())

	if ent.CPPISetOwner then
		ent:CPPISetOwner(ply)
	end
end

hook.Add("PlayerSpawnedSENT", "MorassGlide.Owner", function(ply, ent)
	if not ent.IsGlideVehicle then return end
	setOwner(ply, ent)
end)

hook.Add("PlayerSpawnedVehicle", "MorassGlide.OwnerJeep", function(ply, ent)
	if ent.IsGlideVehicle then
		setOwner(ply, ent)
	end
end)

hook.Add("PlayerSpawnSENT", "MorassGlide.Allowlist", function(ply, class)
	if not list.Get("GlideVehicles")[class] then return end
	if not MorassGlide.IsAllowed(class) then return false end
end)

hook.Add("Glide_CanEnterVehicle", "MorassGlide.CharacterLoaded", function(ply)
	if not ply:GetCharacter() then return false end
end)

hook.Add("OnEntityCreated", "MorassGlide.StripHeliWeapons", function(ent)
	timer.Simple(0, function()
		if not IsValid(ent) or not ent.IsGlideVehicle then return end

		local class = ent:GetClass()
		if MorassGlide.GetCategory(class) ~= "helicopter" then return end

		ent.WeaponInfo = nil
		ent.CrosshairInfo = nil

		if ent.weapons then
			for index, weapon in pairs(ent.weapons) do
				if IsValid(weapon) then
					weapon:Remove()
				end

				ent.weapons[index] = nil
			end
		end
	end)
end)

hook.Add("InitPostEntity", "MorassGlide.BlockStrayGlide", function()
	for _, ent in ipairs(ents.GetAll()) do
		if ent.IsGlideVehicle and not MorassGlide.IsAllowed(ent:GetClass()) then
			ent:Remove()
		end
	end
end)

concommand.Add("morass_glide_list", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end

	for class, category in pairs(MorassGlide.Allowed) do
		print(("[morass_glide] %s (%s)"):format(class, category))
	end
end)
