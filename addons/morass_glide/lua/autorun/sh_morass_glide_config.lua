MorassGlide = MorassGlide or {}

MorassGlide.Workshop = {
	base = 3389728250,
	helicopters = 3389795738,
}

MorassGlide.Boats = {
	gtav_dinghy = true,
	gtav_seashark = true,
}

MorassGlide.Citizen = {
	gtav_blazer = true,
	gtav_dukes = true,
	gtav_gauntlet_classic = true,
	gtav_infernus = true,
	gtav_speedo = true,
}

MorassGlide.Emergency = {
	gtav_police_cruiser = true,
}

-- Civilian helicopters from Glide // GTAV: Helicopters (verify class names in spawn menu once mounted).
MorassGlide.Helicopters = {
	gtav_frogger = true,
	gtav_maverick = true,
	gtav_swift = true,
}

MorassGlide.Allowed = {}

for class in pairs(MorassGlide.Boats) do
	MorassGlide.Allowed[class] = "boat"
end

for class in pairs(MorassGlide.Citizen) do
	MorassGlide.Allowed[class] = "citizen"
end

for class in pairs(MorassGlide.Emergency) do
	MorassGlide.Allowed[class] = "emergency"
end

for class in pairs(MorassGlide.Helicopters) do
	MorassGlide.Allowed[class] = "helicopter"
end

function MorassGlide.GetCategory(class)
	return MorassGlide.Allowed[class]
end

function MorassGlide.IsAllowed(class)
	return MorassGlide.Allowed[class] ~= nil
end

function MorassGlide.ShouldStripLights(class)
	local category = MorassGlide.GetCategory(class)
	return category == "citizen" or category == "boat" or category == "helicopter"
end
