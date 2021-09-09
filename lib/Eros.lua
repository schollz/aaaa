local Eros={}

function Eros:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  -- initialize ero for each property
  o.playing=false
  return o
end

function Eros:trig()
  -- print("Eros: trig")
  local p={}
  for k,ero in pairs(self.eros) do
    -- print(k,ero:get_mapped())
    p[k]=ero:get_mapped()
  end
  -- also return step of the trigger
  -- (this is gauranteed to be defined)
  p.step=self.eros.trigger.step
  if self.fn_trig~=nil then
    self.fn_trig(p)
  end
end

function Eros:set_maps(maps)
  self.eros={}
  for k,map in pairs(maps) do
    self.eros[k]=Ero:new({map=map})
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

function Eros:toggle_playing()
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
function Eros:next(div,step)
  if not self.playing then
    do return end
  end
  local trigged=false
  for prop,ero in pairs(self.eros) do
    if ero.div==div then
      ero:inc(div,step)
      if prop=="trigger" then
        trigged=true
      end
    end
  end
  if trigged then
    self:trig()
  end
end

-- eror returns the current
-- euclidean rhythm operation result
function Eros:get_res(prop)
  return self.eros[prop]:get_res()
end

return Eros
