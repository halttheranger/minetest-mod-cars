
--
-- Helper functions
--

local function is_ground(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "cracky") ~= 0
end

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i/math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = math.cos(yaw)*v
	local z = math.sin(yaw)*v
	return {x=x, y=y, z=z}
end

local function get_v(v)
	return math.sqrt(v.x^2+v.z^2)
end

--
-- Cart entity
--

local boat = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_grey.png"},
	
	driver = nil,
	v = 0,
}

function boat:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function boat:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function boat:get_staticdata()
	return tostring(v)
end

function boat:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car")
	end
end

function boat:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

local bot = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_fire.png"},
	
	driver = nil,
	v = 0,
}

function bot:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function bot:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function bot:get_staticdata()
	return tostring(v)
end

function bot:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_fire")
	end
end

function bot:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

local bat = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_red.png"},
	
	driver = nil,
	v = 0,
}

function bat:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function bat:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function bat:get_staticdata()
	return tostring(v)
end

function bat:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_red")
	end
end

function bat:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

local bt = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_blue.png"},
	
	driver = nil,
	v = 0,
}

function bt:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function bt:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function bt:get_staticdata()
	return tostring(v)
end

function bt:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_blue")
	end
end

function bt:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

local car = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_police.png"},
	
	driver = nil,
	v = 0,
}

function car:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function car:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function car:get_staticdata()
	return tostring(v)
end

function car:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_police")
	end
end

function car:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

local cr = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_midnight.png"},
	
	driver = nil,
	v = 0,
}

function cr:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function cr:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function cr:get_staticdata()
	return tostring(v)
end

function cr:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_midnight")
	end
end

function cr:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

local sports = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_black.png"},
	
	driver = nil,
	v = 0,
}

function sports:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function sports:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function sports:get_staticdata()
	return tostring(v)
end

function sports:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_black")
	end
end

function sports:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end


local sport = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_white.png"},
	
	driver = nil,
	v = 0,
}

function sport:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function sport:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function sport:get_staticdata()
	return tostring(v)
end

function sport:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_white")
	end
end

function sport:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end


local sprt = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_colors.png"},
	
	driver = nil,
	v = 0,
}

function sprt:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function sprt:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function sprt:get_staticdata()
	return tostring(v)
end

function sprt:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_colors")
	end
end

function sprt:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end


local spt = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_green.png"},
	
	driver = nil,
	v = 0,
}

function spt:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function spt:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function spt:get_staticdata()
	return tostring(v)
end

function spt:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_green")
	end
end

function spt:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end




local brown = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_brown.png"},
	
	driver = nil,
	v = 0,
}

function brown:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function brown:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function brown:get_staticdata()
	return tostring(v)
end

function brown:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_brown")
	end
end

function brown:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end



local orange = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_orange.png"},
	
	driver = nil,
	v = 0,
}

function orange:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function orange:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function orange:get_staticdata()
	return tostring(v)
end

function orange:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_orange")
	end
end

function orange:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end



local yellow = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_yellow.png"},
	
	driver = nil,
	v = 0,
}

function yellow:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function yellow:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function yellow:get_staticdata()
	return tostring(v)
end

function yellow:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_yellow")
	end
end

function yellow:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end



local pink = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_pink.png"},
	
	driver = nil,
	v = 0,
}

function pink:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function pink:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function pink:get_staticdata()
	return tostring(v)
end

function pink:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_pink")
	end
end

function pink:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end




local egg = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_easter.png"},
	
	driver = nil,
	v = 0,
}

function egg:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function egg:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function egg:get_staticdata()
	return tostring(v)
end

function egg:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_easter")
	end
end

function egg:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

local xmas = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_xmas.png"},
	
	driver = nil,
	v = 0,
}

function xmas:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function xmas:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function xmas:get_staticdata()
	return tostring(v)
end

function xmas:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_xmas")
	end
end

function xmas:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

local flag = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_flag.png"},
	
	driver = nil,
	v = 0,
}

function flag:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function flag:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function flag:get_staticdata()
	return tostring(v)
end

function flag:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_flag")
	end
end

function flag:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end

local sword = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_sword.png"},
	
	driver = nil,
	v = 0,
}

function sword:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function sword:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function sword:get_staticdata()
	return tostring(v)
end

function sword:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_sword")
	end
end

function sword:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end


local smile = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_smile.png"},
	
	driver = nil,
	v = 0,
}

function smile:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function smile:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function smile:get_staticdata()
	return tostring(v)
end

function smile:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_smile")
	end
end

function smile:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end


local grace = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_grace.png"},
	
	driver = nil,
	v = 0,
}

function grace:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function grace:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function grace:get_staticdata()
	return tostring(v)
end

function grace:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_shine")
	end
end

function grace:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end


local cyan = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_cyan.png"},
	
	driver = nil,
	v = 0,
}

function cyan:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function cyan:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function cyan:get_staticdata()
	return tostring(v)
end

function cyan:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_cyan")
	end
end

function cyan:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end


local camo = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.5,y=1.5},
	mesh = "car.x",
	textures = {"car_camo.png"},
	
	driver = nil,
	v = 0,
}

function camo:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function camo:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function camo:get_staticdata()
	return tostring(v)
end

function camo:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_camo")
	end
end

function camo:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end


local bee = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.5,y=1.5},
	mesh = "car.x",
	textures = {"car_bee.png"},
	
	driver = nil,
	v = 0,
}

function bee:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function bee:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function bee:get_staticdata()
	return tostring(v)
end

function bee:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_bee")
	end
end

function bee:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end


local dark = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.5,y=1.5},
	mesh = "car.x",
	textures = {"car_darkgreen.png"},
	
	driver = nil,
	v = 0,
}

function dark:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
	elseif not self.driver then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x=0,y=5,z=0}, {x=0,y=0,z=0})
		self.object:setyaw(clicker:get_look_yaw())
	end
end

function dark:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
end

function dark:get_staticdata()
	return tostring(v)
end

function dark:on_punch(puncher, time_from_last_punch, tool_capabilities, direction)
	self.object:remove()
	if puncher and puncher:is_player() then
		puncher:get_inventory():add_item("main", "cars:car_darkgreen")
	end
end

function dark:on_step(dtime)
	self.v = get_v(self.object:getvelocity())*get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		if ctrl.up then
			self.v = self.v+0.5
		end
		if ctrl.down then
			self.v = self.v-0.1
		end
		if ctrl.left then
			self.object:setyaw(self.object:getyaw()+math.pi/120+dtime*math.pi/120)
		end
		if ctrl.right then
			self.object:setyaw(self.object:getyaw()-math.pi/120-dtime*math.pi/120)
		end
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02*s
	if s ~= get_sign(self.v) then
		self.object:setvelocity({x=0, y=0, z=0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 4.5 then
		self.v = 4.5*get_sign(self.v)
	end
	
	local p = self.object:getpos()
	p.y = p.y-0.5
	if not is_ground(p) then
		if minetest.registered_nodes[minetest.get_node(p).name].walkable then
			self.v = 0
		end
		self.object:setacceleration({x=0, y=-10, z=0})
		self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
	else
		p.y = p.y+1
		if is_ground(p) then
			self.object:setacceleration({x=0, y=3, z=0})
			local y = self.object:getvelocity().y
			if y > 2 then
				y = 2
			end
			if y < 0 then
				self.object:setacceleration({x=0, y=10, z=0})
			end
			self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), y))
		else
			self.object:setacceleration({x=0, y=0, z=0})
			if math.abs(self.object:getvelocity().y) < 1 then
				local pos = self.object:getpos()
				pos.y = math.floor(pos.y)+0.5
				self.object:setpos(pos)
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), 0))
			else
				self.object:setvelocity(get_velocity(self.v, self.object:getyaw(), self.object:getvelocity().y))
			end
		end
	end
end




minetest.register_entity("cars:car_pink", pink)



minetest.register_craftitem("cars:car_pink", {
	description = "Pink Car",
	inventory_image = "car_pink.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_pink")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_pink",
	recipe = {
		{"", "dye:pink", ""},
		{"", "cars:car", ""},
		{"", "", ""},
	},
})
minetest.register_entity("cars:car_easter", egg)



minetest.register_craftitem("cars:car_easter", {
	description = "Easter!!!!! :D",
	inventory_image = "car_easter.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_easter")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_easter",
	recipe = {
		{"", "food:egg", ""},
		{"", "cars:car_colors", ""},
		{"", "", ""},
	},
})
local race = {
	physical = true,
	collisionbox = {-1.5,-0,-1.5, 1.5,1,1.5},
	visual = "mesh",
	stepheight = 1.1,
	visual_size = {x=1.4,y=1.4},
	mesh = "car.x",
	textures = {"car_easter.png"},
	
	driver = nil,
	v = 0,
}

minetest.register_entity("cars:car_yellow", yellow)


minetest.register_craftitem("cars:car_yellow", {
	description = "Yellow Car",
	inventory_image = "car_yellow.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_yellow")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_yellow",
	recipe = {
		{"", "dye:yellow", ""},
		{"", "cars:car", ""},
		{"", "", ""},
	},
})

minetest.register_entity("cars:car_orange", orange)


minetest.register_craftitem("cars:car_orange", {
	description = "Orange Car",
	inventory_image = "car_orange.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_orange")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_orange",
	recipe = {
		{"", "dye:orange", ""},
		{"", "cars:car", ""},
		{"", "", ""},
	},
})


minetest.register_entity("cars:car_brown", brown)


minetest.register_craftitem("cars:car_brown", {
	description = "Brown Car",
	inventory_image = "car_brown.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_brown")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_brown",
	recipe = {
		{"", "dye:brown", ""},
		{"", "cars:car", ""},
		{"", "dye:brown", ""},
	},
})

minetest.register_entity("cars:car", boat)


minetest.register_craftitem("cars:car", {
	description = "Car",
	inventory_image = "car_grey.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car",
	recipe = {
		{"default:mese", "dye:grey", "default:glass"},
		{"streets:concrete", "streets:concrete", "streets:concrete"},
		{"default:diamond", "", "default:diamond"},
	},
})

minetest.register_entity("cars:car_red", bat)


minetest.register_craftitem("cars:car_red", {
	description = "Red Car",
	inventory_image = "car_red.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_red")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_red",
	recipe = {
		{"", "dye:red", ""},
		{"", "cars:car", ""},
		{"", "dye:red", ""},
	},
})

minetest.register_entity("cars:car_blue", bt)


minetest.register_craftitem("cars:car_blue", {
	description = "Blue Car",
	inventory_image = "car_blue.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_blue")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_blue",
	recipe = {
		{"", "dye:blue", ""},
		{"", "cars:car", ""},
		{"", "dye:blue", ""},
	},
})

minetest.register_entity("cars:car_fire", bot)



minetest.register_craftitem("cars:car_fire", {
	description = "Blue Fire Car",
	inventory_image = "car_fire.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_fire")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_fire",
	recipe = {
		{"", "dye:red", ""},
		{"", "cars:car_blue", ""},
		{"", "dye:orange", ""},
	},
})

minetest.register_entity("cars:car_police", car)



minetest.register_craftitem("cars:car_police", {
	description = "Police Car",
	inventory_image = "car_police.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_police")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_police",
	recipe = {
		{"", "dye:yellow", ""},
		{"", "car:car_blue", ""},
		{"", "", ""},
	},
})

minetest.register_entity("cars:car_midnight", cr)



minetest.register_craftitem("cars:car_midnight", {
	description = "Midnight Car",
	inventory_image = "car_midnight.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_midnight")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_midnight",
	recipe = {
		{"", "dye:white", ""},
		{"", "cars:car_black", ""},
		{"", "", ""},
	},
})

minetest.register_entity("cars:car_black", sports)



minetest.register_craftitem("cars:car_black", {
	description = "Black Car",
	inventory_image = "car_black.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_black")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_black",
	recipe = {
		{"", "dye:black", ""},
		{"", "cars:car", ""},
		{"", "", ""},
	},
})
minetest.register_entity("cars:car_white", sport)



minetest.register_craftitem("cars:car_white", {
	description = "White Car",
	inventory_image = "car_white.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_white")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_white",
	recipe = {
		{"", "dye:white", ""},
		{"", "cars:car", ""},
		{"", "", ""},
	},
})
minetest.register_entity("cars:car_colors", sprt)



minetest.register_craftitem("cars:car_colors", {
	description = "Colorful Car",
	inventory_image = "car_colors.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_colors")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_colors",
	recipe = {
		{"dye:black", "dye:yellow", "dye:black"},
		{"dye:blue", "cars:car_white", "dye:orange"},
		{"dye:black", "dye:red", "dye:black"},
	},
})
minetest.register_entity("cars:car_green", spt)



minetest.register_craftitem("cars:car_green", {
	description = "Green Car",
	inventory_image = "car_green.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_green")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_green",
	recipe = {
		{"", "dye:green", ""},
		{"", "cars:car", ""},
		{"", "", ""},
	},
})
minetest.register_entity("cars:car_xmas", xmas)



minetest.register_craftitem("cars:car_xmas", {
	description = "Xmas Car",
	inventory_image = "car_xmas.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_xmas")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_xmas",
	recipe = {
		{"", "dye:red", ""},
		{"", "cars:car_green", ""},
		{"", "", ""},
	},
})
minetest.register_entity("cars:car_sword", sword)



minetest.register_craftitem("cars:car_sword", {
	description = "Sword Car",
	inventory_image = "car_sword.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_sword")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_sword",
	recipe = {
		{"", "dye:red", ""},
		{"dye:black", "cars:car_blue", "dye:white"},
		{"", "dye:orange", ""},
	},
})
minetest.register_entity("cars:car_flag", flag)



minetest.register_craftitem("cars:car_flag", {
	description = "American Flag Car",
	inventory_image = "car_flag.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_flag")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_flag",
	recipe = {
		{"", "dye:red", ""},
		{"", "cars:car_blue", ""},
		{"", "dye:white", ""},
	},
})

minetest.register_entity("cars:car_smile", smile)



minetest.register_craftitem("cars:car_smile", {
	description = "Smile Car",
	inventory_image = "car_smile.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_smile")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_smile",
	recipe = {
		{"", "dye:yellow", ""},
		{"", "cars:car_green", ""},
		{"", "dye:black", ""},
	},
})
minetest.register_entity("cars:car_cyan", cyan)



minetest.register_craftitem("cars:car_cyan", {
	description = "Cyan Car",
	inventory_image = "car_cyan.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_cyan")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_cyan",
	recipe = {
		{"", "dye:white", ""},
		{"", "cars:car_blue", ""},
		{"", "dye:blue", ""},
	},
})
minetest.register_entity("cars:car_shine", grace)



minetest.register_craftitem("cars:car_shine", {
	description = "Shine Car",
	inventory_image = "car_grace.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_shine")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_shine",
	recipe = {
		{"", "dye:white", ""},
		{"dye:blue", "cars:car_white", "dye:orange"},
		{"", "dye:yellow", ""},
	},
})
minetest.register_entity("cars:car_camo", camo)



minetest.register_craftitem("cars:car_camo", {
	description = "Camo Car",
	inventory_image = "car_camo.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_camo")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_camo",
	recipe = {
		{"", "dye:black", ""},
		{"", "cars:car_darkgreen", ""},
		{"dye:white", "dye:brown", "dye:white"},
	},
})
minetest.register_entity("cars:car_bee", bee)



minetest.register_craftitem("cars:car_bee", {
	description = "bee Car",
	inventory_image = "car_bee.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_bee")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_bee",
	recipe = {
		{"", "dye:black", ""},
		{"", "cars:car_yellow", ""},
		{"", "dye:black", ""},
	},
})
minetest.register_entity("cars:car_darkgreen", dark)



minetest.register_craftitem("cars:car_darkgreen", {
	description = "Dark Green Car",
	inventory_image = "car_darkgreen.png",
	wield_scale = {x=2, y=2, z=1},
	liquids_pointable = true,
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_ground(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y+2
		minetest.add_entity(pointed_thing.under, "cars:car_darkgreen")
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "cars:car_darkgreen",
	recipe = {
		{"", "dye:black", ""},
		{"", "cars:car_green", ""},
		{"", "dye:green", ""},
	},
})
