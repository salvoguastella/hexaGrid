local M = {}

function M.new()
	local _effects = {}

	_effects.destroy = function(source, target)
		return "destroy "..target
	end

	_effects.dealDamage = function(source, target, amount)
		return source.." deals "..amount.." damages to "..target
	end

	_effects.heal = function(source, target, amount)
		return source.." heals "..amount.." damages to "..target
	end

	_effects.setStatus = function(source, target, status)
		print(target.." is now "..status)
		return target.." is now "..status
	end

	_effects.removeStatus = function(source, target, status)
		print(target.." is no more "..status)
		return target.." is no more "..status
	end

	_effects.silence = function(source, target)
		_effects.setStatus(source, target, "silence")
	end

	_effects.freeze = function(source, target)
		_effects.setStatus(source, target, "freeze")
	end

	return _effects

end

return M