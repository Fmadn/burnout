local desks = {}

local function random_next()
    return love.math.random(1, 5) * 1
end

function desks.new(x,y)
    local self = setmetatable({}, {__index = desks})

    self.x, self.y = x, y
    
    self.requesting = false
    self.next_job = random_next()

    self.waiting_time = 0
    self.elapsed_time = 0

    return self
end

function desks:add__job()
    print("Kerjaan lagi wok")
    self.elapsed_time = 0
    self.requesting = true
    self.next_job = random_next()
end

function desks:update(dt)
    if self.elapsed_time > self.next_job and not self.requesting then
        self:add__job()
    else
        self.elapsed_time = self.elapsed_time + dt
    end
end

function desks:work()
    print("Kerja dulu wok")
end

return desks