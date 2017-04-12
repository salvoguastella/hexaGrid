local M = {}

function M.new(tile)
	local menu = display.newGroup( )
	local bg = display.newRect( menu, 0, 0, 450, 500 )
	bg:setFillColor(0.5, 0.5, 0.5)
	local tileName = display.newText( menu, tile.name, -140, -210, native.systemFontBold, 36 )
	menu.close = display.newCircle( menu, 225, -250, 30 )
	menu.close:setFillColor(0.1, 0.1, 0.1)
	menu.x = display.contentCenterX
	menu.y = display.contentCenterY
	return menu
end

return M