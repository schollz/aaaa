local Eros={}

function Eros:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  -- initialize ero for each property
  if o.maps~=nil then
    for k,map in ipairs(o.maps) do
      o.eros[k]=Ero:new({map=map})
    end
  end
  o.playing=false
  return o
end


function Eros:trig()
  local p={}
  for k,ero in pairs(self.eros) do
    p[k]=ero:get_mapped()
  end
  if self.fn_trig~=nil then
    self.fn_trig(p)
  end
end

function Eros:set_trig(fn)
  self.fn_trig=fn
end

function Eros:play()
  self.playing=true
  for _,ero in pairs(self.eros) do
    ero:reset()
  end
end

function Eros:stop()
  self.playing=false
end

function Eros:set_div(k,div)
  self.eros[k]:set_div(div)
end

function Eros:set_steps(k,steps)
  self.eros[k]:set_steps(div)
end

function Eros:set(k,i,kv)
  self.eros[k]:set(i,kv)
end

function Eros:delta(k,i,kv)
  self.eros[k]:delta(i,kv)
end

function Eros:get(k,i)
  return self.eros[k]:get(i)
end

-- inc increments the current step
function Eros:inc(div)
  if not self.playing then
    do return end
  end
  for _,ero in pairs(self.eros) do
    ero:inc(div)
  end
  self:trig()
end

-- eror returns the current
-- euclidean rhythm operation result
function Eros:get_res(k)
  return self.eros[k]:get_res()
end

return Eros
