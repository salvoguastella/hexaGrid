-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local tableUtils = require("utils.tableUtils")

function round(num, numDecimalPlaces)
  local num = tostring(num)
  return tonumber(string.sub( num, 0 , numDecimalPlaces ))
end

local hexagons = require("lib.hexagons")
--print(hexagons:getSingleNode(1,1))
--print(hexagons:getSingleNode(hexagons:getSingleNode(1,1),3))
--print(hexagons:getSingleNode(3,4))

--print( tableUtils.tostring( hexagons ) )

--contains main grid
local bg = display.newGroup( )
--contains boundings
local guides = display.newGroup( )
--contains tiles
local handTiles = display.newGroup( )

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

--print( tableUtils.tostring( hexSizes) )

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

--print( tableUtils.tostring( centers ) )

--boundings table
local boundings = {}

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

--contains on-scree tiles (board+hands)
local tilesTable = {}

--generate player
local _player = require("lib.player")
local player1 = _player.new("Salvo")
print(player1.name.." is playing")

local newCard1

for i=0, 3, 1 do
  newCard1 = player1.addCardToHand()
  if (newCard1) then table.insert( tilesTable, newCard1 ) end
end

--stores the chronologic order of played tiles
local playedTiles = {}

local function dragTile(event)
  local phase = event.phase
  local tile = event.target
  if(not tile.slot) then
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

--move tiles to bottom bar and add touch event
for i, v in ipairs(tilesTable) do
  --move this to player
  handTiles:insert(v)
  v.x = 150*i
  v.barX = v.x
  v.y = display.contentHeight - 20
  v.barY = v.y
  v:scale(1.08,1.08)
  v:addEventListener( "touch", dragTile )
end


