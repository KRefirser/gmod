if CLIENT then
	local tblNotifications = {}
	local intLastTime = 6
	local intStartPostion = ScrH() - 100
	local intSpacing = 0
	local intHieght = 25
	
	local function DrawNotifications()
		local yOffset = intStartPostion
		for _, strNocification in pairs(tblNotifications) do
			local wide, high = surface.GetTextSize(strNocification)
			local pnlNotification = jdraw.NewPanel()
			pnlNotification:SetDemensions(ScrW() - (wide + 45), yOffset, wide + 30, intHieght)
			pnlNotification:SetStyle(1, clrBlack)
			pnlNotification:SetBoarder(1, Color(math.abs(math.sin(CurTime()*5)*255), 0, 0, 255))
			jdraw.DrawPanel(pnlNotification)
			draw.SimpleText(strNocification, "OverheadFont", pnlNotification.Position.X - 8 + intHieght, pnlNotification.Position.Y + 3, clrWhite, 0, 3)
			yOffset = yOffset - intHieght - intSpacing
		end
	end
	hook.Add("HUDPaint", "DrawNotifications", DrawNotifications)

	function AddNotification(strNotification)
		local str = net.ReadString()
		table.insert(tblNotifications, 1, str)
		timer.Simple(intLastTime, function() table.remove(tblNotifications) end)
	end
	net.Receive( "Notify", AddNotification )
end

if SERVER then
	local Player = FindMetaTable("Player")
	function Player:CreateNotification(strMessage)

		if IsValid(self) then
			net.Start("Notify")
			net.WriteString(strMessage)
			net.Send(self)
		end
	end
	
	function Player:CreateAllNotification(strMessage)

		if IsValid(self) then
			net.Start("Notify")
			net.WriteString(strMessage)
			net.Broadcast()
		end
	end
end