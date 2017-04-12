local M = {}

local hexs = require("lib.hexagons")

local targets = nil

function M.getTargets(board, cell, mode, options)
	print("mode --> "..mode)
	if cell then
		print("cell --> "..cell)
		targets = {}
		if (mode == "randomAround") then
			print("randomAround case")
			local neighbours = {}
			local _neighbours = hexs:getNodes(cell)
			for i=1, #_neighbours, 1 do
				if board[_neighbours[i]] then
					if options then
						if options.player and options.owner then
							--check if we need only players's or enemy's tile
							--CHEEEEEEECK
							print("selective random for "..options.player..", only "..options.owner)
						end
					else
						table.insert( neighbours, _neighbours[i] )
					end
				end
			end
			if (#neighbours > 0) then
				local randIndex = math.random(#neighbours)
				local checkTarget = neighbours[randIndex]
				table.insert(targets, checkTarget)
			end
		elseif (mode == "singleAround") then

		elseif (mode == "singleBoard") then

		elseif (mode == "randomBoard") then

		elseif (mode == "self") then
			print("self case")
			table.insert(targets, cell)
		elseif (mode == "allBoard") then

		elseif (mode == "allAround") then
			print("allAround case")
			local neighbours = {}
			local _neighbours = hexs:getNodes(cell)
			for i=1, #_neighbours, 1 do
				if board[_neighbours[i]] then
					table.insert( neighbours, _neighbours[i] )
				end
			end
			if (#neighbours > 0) then
				for i,n in ipairs(neighbours) do
					table.insert(targets, n)
				end
			end
		end
			--nRandomAround
			--nRandomBoard
			--randomAllyAround
	end

	return targets

end

return M