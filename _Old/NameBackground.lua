function cfFrames.initNameBackground()
    if not TargetFrameNameBackground then return end
    TargetFrameNameBackground:SetVertexColor(0, 0, 0, 0.5)
    if TargetFrame_CheckFaction then
        hooksecurefunc("TargetFrame_CheckFaction", function()
            TargetFrameNameBackground:SetVertexColor(0, 0, 0, 0.5)
        end)
    end
end
