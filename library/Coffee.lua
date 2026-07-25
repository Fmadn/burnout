local coffees = {}

function coffees.new(pos_x, pos_y)
    local self = {}
    self.x = pos_x
    self.y = pos_y
    self.cooldown = { active = false, duration = 10 } -- lagi cooldown atau enggak, lama cooldownnya berapa detik

    return self
end

return coffees