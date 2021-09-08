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
    self.eros[k]=Ero:new({map=maps[k]})
  end

  self.playing=false
  self.notes_on={}
end

function Synth:trig()
  local p={}
  for k,ero in pairs(self.eros) do
    p[k]=ero:get_mapped()
  end

  -- turn off notes that are done
  local notes_done={}
  for k,v in pairs(self.notes_on) do
    self.notes_on[k].beats=v.beats+1
    if self.notes_on[k].beats==v.duration then
      -- note is done
      table.insert(notes_done,k)
    end
  end
  for _,note in ipairs(notes_done) do
    -- TODO: turn off note
    self.notes_on[k]=nil
  end

  -- turn on new note
  self.notes_on[p.pitch]={beats=0,duration=p.duration}
  -- TODO: turn on note in engine
end

-- shared between sample and synth
function Synth:play()
  self.playing=true
  for _,ero in pairs(self.eros) do
    ero:reset()
  end
end

function Synth:stop()
  self.playing=false
end

-- set_div(div) where div=1/4, 1/8, etc.
function Synth:set_div(k,div)
  self.eros[k]:set_div(div)
end

function Synth:set_steps(k,steps)
  self.eros[k]:set_steps(div)
end

function Synth:set(k,i,kv)
  self.eros[k]:set(i,kv)
end

function Synth:delta(k,i,kv)
  self.eros[k]:delta(i,kv)
end

function Synth:get(k,i)
  return self.eros[k]:get(i)
end

-- inc increments the current step
function Synth:inc(div)
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
function Synth:get_res(k)
  return self.eros[k]:get_res()
end

return Synth
