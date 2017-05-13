--[[Tutorial: https://www.youtube.com/watch?v=NdESDIs7Ty4]]

local f = CreateFrame("Frame")
f:RegisterEvent("DELETE_ITEM_CONFIRM")

f:SetScript("OnEvent", function(self, event, ...)
	if event == "DELETE_ITEM_CONFIRM" then
		print("deleteForMe: Prompted")
		deleteIt()
	end
end)

function deleteIt(...)
	DeleteCursorItem()
	print("deleteForMe: Deleted automatically")
end