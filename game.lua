
local composer = require( "composer" )

local scene = composer.newScene()

local tableUtils = require("utils.tableUtils")

local hexagons = require("lib.hexagons")

local _player = require("lib.player")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

--data: boundings table
local boundings = {}

--data: contains on-screen tiles (board+hands)
local tilesTable = {}

--data: stores the chronologic order of played tiles
local playedTiles = {}

--data: stores tiles on the board. index = physical position
local board = {}

--graphic: contains main grid
local bg

--graphic: contains boundings
local guides

--contains gui elements
local gui

--graphic: contains tiles
local player1_handTiles
local player2_handTiles

local player1, player2

local turn = 0
local turnTime = {current = 0, max = 120}
local who_plays = nil

local game_end = false

--example deck
local loadedDeck = {"magic", "alchemy", "vigor", "shell"}

--checks if one tile has been moved on a bounding area. values are related to screen center
local function isOnBounding( _bounding,x,y )
  local bounds = _bounding.contentBounds
  centeredX = x - display.contentCenterX
  centeredY = y - display.contentCenterY
  xMax = bounds.xMax - display.contentCenterX
  xMin = bounds.xMin - display.contentCenterX
  yMax = bounds.yMax - display.contentCenterY
  yMin = bounds.yMin - display.contentCenterY
  --print("element "..centeredX.." "..centeredY)
  --print(_bounding.index.."-----------")
  --print("x bound "..xMin.." "..xMax)
  --print("y bound "..yMin.." "..yMax)
  if (xMin <= centeredX and xMax >= centeredX and yMin <= centeredY and yMax >= centeredY) then
    return _bounding.x,_bounding.y
  else
    return false
  end
end

--just for debug, gets bounding area info
local function getBoundingInfo(event)
  local _bounding = event.target
  print(_bounding.index)
  local bounds = _bounding.contentBounds 
  print( "xMin: ".. bounds.xMin ) -- xMin: 75
  print( "xMax: ".. bounds.xMax ) -- xMax: 125
  print( "yMin: ".. bounds.yMin ) -- yMin: 75
  print( "yMax: ".. bounds.yMax ) -- yMax: 125
end

local function dragTile(event)
  local phase = event.phase
  local tile = event.target
  if(not tile.slot and tile.owner.name == who_plays) then
    if (phase=="began") then
      display.currentStage:setFocus( tile )
      -- Store initial offset position
      tile.touchOffsetX = event.x - tile.x
      tile.touchOffsetY = event.y - tile.y
    elseif (phase=="moved") then
      -- Move the ship to the new touch position
      tile.x = event.x - tile.touchOffsetX
      tile.y = event.y - tile.touchOffsetY
    elseif (phase=="ended" or phase=="cancelled") then
      -- Release touch focus on the ship
      local foundPosition = false
      for i, _bounding in ipairs(boundings) do
        local newX, newY = isOnBounding(_bounding,tile.x,tile.y)
        if (newX and newY) then
          foundPosition = true
          transition.to( tile, { x=newX, y=newY, time=100, onComplete = function()
            tile.slot = _bounding.index
            board[_bounding.index] = tile
            tile:toBack( )
            table.insert( playedTiles, tile )
            local owner = tile.owner
            owner.playCard(tile)
            --print("test status. Asleep? "..tostring(tile.status.asleep))
            --print("test method. "..tile.onDamageDealt("dummy"))
            print( tableUtils.tostring(hexagons:getNodes(tile.slot)) )
            print( #playedTiles.." cards on the board" )
          end} )
        end
      end
      if (not foundPosition) then
        transition.to( tile, { x=tile.barX, y=tile.barY, time=100, onComplete = function()
            print("position not found")
        end} )
      end
      display.currentStage:setFocus( nil )
    end
  end
  return true
end


local function gameLoop()
    turnTime.current = turnTime.current +1
    --print("turn "..turn.." "..turnTime.current.." sec")
    if (turnTime.current >= turnTime.max) then
    	print("end turn "..turn)
    	timer.cancel(gameLoopTimer)
    	nextTurn()
    end
end

function nextTurn()
	turn = turn + 1
	if (turn % 2 ~= 0) then
		--player 1 turn
		who_plays = player1.name
	else
		--player 2 turn
		who_plays = player2.name
	end
	print(who_plays.."'s new turn")

	--example end game, replace with end-game condition
    if turn > 10 then game_end = true end
    --

    if (game_end) then
		print("end game")
	else
		turnTime.current = 0
		gameLoopTimer = timer.performWithDelay( 1000, gameLoop, 0 )
	end
end

local function skipTurn()
	turnTime.current = 999
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	--contains main grid
	bg = display.newGroup( )
	sceneGroup:insert( bg )
	--contains boundings
	guides = display.newGroup( )
	sceneGroup:insert( guides )
	--contains gui elements
	gui = display.newGroup( )
	sceneGroup:insert( gui )
	--contains tiles
	player1_handTiles = display.newGroup( )
	sceneGroup:insert( player1_handTiles )
	player2_handTiles = display.newGroup( )
	sceneGroup:insert( player2_handTiles )

	local hive = display.newImage( bg, "resources/images/hive.png" , 640, 694 )
	hive.x = display.contentCenterX
	hive.y = display.contentCenterY

	local baseWidth = hive.width/5

	--reference hexagonal tile sizes
	local hexSizes = {
	  width = baseWidth,
	  side = baseWidth/math.sqrt( 3 ),
	  diagonal = 2*baseWidth/math.sqrt( 3 )
	}

	--bounding areas center points. these have screen center as reference point
	local centers = {
	  {0,0},
	  {hexSizes.width*0.5,-(hexSizes.diagonal+hexSizes.side)/2},
	  {hexSizes.width, 0},
	  {hexSizes.width*0.5,(hexSizes.diagonal+hexSizes.side)/2},
	  {-hexSizes.width*0.5,(hexSizes.diagonal+hexSizes.side)/2},
	  {-hexSizes.width, 0},
	  {-hexSizes.width*0.5,-(hexSizes.diagonal+hexSizes.side)/2},
	  {0,-(hexSizes.diagonal+hexSizes.side)},
	  {hexSizes.width,-(hexSizes.diagonal+hexSizes.side)},
	  {hexSizes.width*1.5,-(hexSizes.diagonal+hexSizes.side)/2},
	  {hexSizes.width*2,0},
	  {hexSizes.width*1.5,(hexSizes.diagonal+hexSizes.side)/2},
	  {hexSizes.width,(hexSizes.diagonal+hexSizes.side)},
	  {0,(hexSizes.diagonal+hexSizes.side)},
	  {-hexSizes.width,(hexSizes.diagonal+hexSizes.side)},
	  {-hexSizes.width*1.5,(hexSizes.diagonal+hexSizes.side)/2},
	  {-hexSizes.width*2,0},
	  {-hexSizes.width*1.5, -(hexSizes.diagonal+hexSizes.side)/2},
	  {-hexSizes.width, -(hexSizes.diagonal+hexSizes.side)},
	}

	for i, v in ipairs(centers) do
	  local bounding = display.newCircle( 0, 0, 60 )
	  bounding.strokeWidth=2
	  bounding:setStrokeColor( 0.3, 0.3, 0.3 )
	  bounding.x = v[1] + display.contentCenterX
	  bounding.y = v[2] + display.contentCenterY
	  bounding.index = i
	  --just for debug
	  bounding:addEventListener( "tap", getBoundingInfo )
	  guides:insert(bounding)
	  table.insert( boundings, bounding )
	  --print(bounding.x.." "..bounding.y)
	end

	--temporary skip turn button
	local skip = display.newImage( gui, "resources/images/tiles/skip.png" , 128, 147 )
	skip.x = display.contentCenterX + 2*hexSizes.width
	skip.y = display.contentCenterY + (hexSizes.diagonal+hexSizes.side)
	skip:addEventListener( "tap", skipTurn )

	--example decks
	local loadedDeck1 = {"magic", "alchemy", "vigor", "shell"}
	local loadedDeck2 = {"magic", "alchemy", "vigor", "shell"}
	--generate player
	player1 = _player.new("Salvo", loadedDeck)
	player2 = _player.new("Bob", loadedDeck)

	player1.shuffleDeck()
	player2.shuffleDeck()

	print(player1.name.." is playing")
	print(player2.name.." is playing")

	local newCard

	for i=0, 3, 1 do
	  newCard = player1.addCardToHand()
	  if (newCard) then table.insert( tilesTable, newCard ) end
	end

	for i=0, 3, 1 do
	  newCard = player2.addCardToHand()
	  if (newCard) then table.insert( tilesTable, newCard ) end
	end

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

		--player hand counters
		local p1, p2 = 1,1
		--move tiles to bottom bar and add touch event. then draw them on right player hand
		for i, v in ipairs(tilesTable) do
		  --move this to the right player hand
		  if (v.owner.name == player1.name) then
			player1_handTiles:insert(v)
			v.x = (display.contentWidth / 5)*p1
			p1 = p1 + 1
			v.y = display.contentHeight - 20
		  else
			player2_handTiles:insert(v)
			v.x = (display.contentWidth / 5)*p2
			p2 = p2+1
			v.y = 20
		  end
		  v.barX = v.x
		  v.barY = v.y
		  v:scale(1.08,1.08)
		  v:addEventListener( "touch", dragTile )
		end

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		nextTurn()
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
