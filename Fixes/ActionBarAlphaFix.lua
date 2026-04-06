function cff.InitActionBarAlphaFix()
	if not cfFramesDB[cff.MODULES.ActionBarAlphaFix] then return end
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local btn = _G["ActionButton" .. i]
		if btn then
			local tex = btn:GetNormalTexture()
			if tex then
				local r, g, b = tex:GetVertexColor()
				tex:SetVertexColor(r, g, b, 0.5, cff.SENTINEL)
				hooksecurefunc(tex, "SetVertexColor", function(self, _, _, _, _, flag)
					if flag == cff.SENTINEL then return end
					local r, g, b, a = self:GetVertexColor()
					if a > 0 and (a < 0.49 or a > 0.51) then
						self:SetVertexColor(r, g, b, 0.5, cff.SENTINEL)
					end
				end)
			end
		end
	end
end
