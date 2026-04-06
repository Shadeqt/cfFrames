function cfFrames.initGroupIndicator()
	if PlayerFrameGroupIndicator then
		PlayerFrameGroupIndicator:SetAlpha(0)
		PlayerFrameGroupIndicator:HookScript("OnShow", function(self)
			self:SetAlpha(0)
		end)
	end
end
