local Synth={}

function Synth:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o:init()
  return o
end

function Synth:init()
  local props={"trigger","pitch","velocity","duration","transpose"}
  local maps={}
  maps.pitch={}
  maps.velocity={}
  for i=1,63 do
    table.insert(maps.pitch,i)
    table.insert(maps.velocity,(i-1)*2) -- 0 to 124 (sorta midi range)
  end

  -- middle duration is one note
  maps.duration={}
  for i=8,1,-1 do
    table.insert(maps.duration,i)
  end
  for i=1,8 do
    table.insert(maps.duration,i)
  end

  -- middle transpose is 0
  maps.transpose={}
  for i=-12,12 do
    table.insert(maps.transpose,i)
  end

  -- trigger is only 1 above 0
  maps.trigger={}
  for i=1,32 do
    table.insert(maps.trigger,0)
  end
  for i=1,31 do
    table.insert(maps.trigger,1)
  end

  -- initialize ero for each property
  for _,k in ipairs(props) do
    self.prop[k]=Ero:new({map=maps[k]})
  end

  self.playing=false
end

function Synth:play()
  self.playing=true
  for _,k in pairs(self.prop) do
    self.prop[k]:reset()
  end
end

function Synth:stop()
  self.playing=false
end

-- set_div(div) where div=1/4, 1/8, etc.
function Synth:set_div(k,div)
  self.prop[k]:set_div(div)
end

function Synth:set_steps(k,steps)
  self.prop[k]:set_steps(div)
end

function Synth:set(k,i,kv)
  self.prop[k]:set(i,kv)
end

function Synth:delta(i,kv)
  for k,v in pairs(kv) do
    self.ero[i].k=self.ero[i].k+v
  end
  self:recalculate()
end

function Synth:get(i)
  local r={}
  for k,v in pairs(self.ero[i]) do
    r.k=v
  end
  r.op=ops[r.op]
  r.div=divs[self.div]
  return r
end

-- inc increments the current step
function Synth:inc(div)
  if not self.playing then
    do return end
  end
  for _,k in pairs(self.props) do
    self.prop[k]:inc(div)
  end
end

-- eror returns the current
-- euclidean rhythm operation result
function Synth:get_res()
  return self.res,self.resmap
end

return Synth
