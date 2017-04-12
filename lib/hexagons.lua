hexagons = {}

--hive relations generation
hex={}
hex.value = 1
hex.nodes = {2,3,4,5,6,7}
table.insert(hexagons,hex)
hex={}
hex.value = 2
hex.nodes = {9,10,3,1,7,8}
table.insert(hexagons,hex)
hex={}
hex.value = 3
hex.nodes = {10,11,12,4,1,2}
table.insert(hexagons,hex)
hex={}
hex.value = 4
hex.nodes = {3,12,13,14,5,1}
table.insert(hexagons,hex)
hex={}
hex.value = 5
hex.nodes = {1,4,14,15,16,6}
table.insert(hexagons,hex)
hex={}
hex.value = 6
hex.nodes = {7,1,5,16,17,18}
table.insert(hexagons,hex)
hex={}
hex.value = 7
hex.nodes = {8,2,1,6,18,19}
table.insert(hexagons,hex)
hex={}
hex.value = 8
hex.nodes = {"end",9,2,7,19,"end"}
table.insert(hexagons,hex)
hex={}
hex.value = 9
hex.nodes = {"end", "end", 10,2,8,"end"}
table.insert(hexagons,hex)
hex={}
hex.value = 10
hex.nodes = {"end","end",11,3,2,9}
table.insert(hexagons,hex)
hex={}
hex.value = 11
hex.nodes = {"end","end","end",12,3,10}
table.insert(hexagons,hex)
hex={}
hex.value = 12
hex.nodes = {11,"end","end",12,4,3}
table.insert(hexagons,hex)
hex={}
hex.value = 13
hex.nodes = {12,"end","end","end",14,4}
table.insert(hexagons,hex)
hex={}
hex.value = 14
hex.nodes = {4,13,"end","end",15,5}
table.insert(hexagons,hex)
hex={}
hex.value = 15
hex.nodes = {5,14,"end","end","end",16}
table.insert(hexagons,hex)
hex={}
hex.value = 16
hex.nodes = {6,5,15,"end","end",17}
table.insert(hexagons,hex)
hex={}
hex.value = 17
hex.nodes = {18,6,16,"end","end","end"}
table.insert(hexagons,hex)
hex={}
hex.value = 18
hex.nodes = {19,7,6,17,"end","end"}
table.insert(hexagons,hex)
hex={}
hex.value = 19
hex.nodes = {"end",8,7,18,"end","end"}
table.insert(hexagons,hex)




function hexagons:getSingleNode(hex,node)
	--gets node by node number (1-6)
	return self[hex].nodes[node]
end

function hexagons:getNodes(hex)
	return self[hex].nodes
end


return hexagons