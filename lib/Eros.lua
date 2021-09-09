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

function Eros:set_action(fn)
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

function Eros:toggle_play() 
  if self.playing then 
    self:stop()
  else
    self:play()
  end
end


function Eros:delta(prop,kv,i)
  self.eros[prop]:delta(kv,i)
end

function Eros:get(prop,i)
  return self.eros[prop]:get(i)
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
function Eros:get_res(prop)
  return self.eros[prop]:get_res()
end

return Eros
