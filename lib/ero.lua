local Ero={}

-- internal constants
local divs={1/32,1/16,1/8,1/4,1/2,1}
local ops={"+","-","x","/","%"}

function Ero:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o:init()
  return o
end

function Ero:init()
  self.res={}
  self.ero={}
  for i=1,4 do
    self.ero[i]={}
    self.ero[i].op=1 -- operation
    self.ero[i].m=1 -- multipler
    self.ero[i].p=1 -- pulse
    self.ero[i].w=0 -- shift
  end
  self.div=4 -- qn
  self.step=0
  self.steps=16
end

function Ero:play()
  self.step=0
end

function Ero:recalculate()
  -- recalculate result
end

function Ero:set(i,kv)
  for k,v in pairs(kv) do
    self.ero[i].k=v
  end
  self:recalculate()
end

function Ero:delta(i,kv)
  for k,v in pairs(kv) do
    self.ero[i].k=self.ero[i].k+v
  end
  self:recalculate()
end

function Ero:get(i)
  local r={}
  for k,v in pairs(self.ero[i]) do
    r.k=v
  end
  r.op=ops[r.op]
  r.div=divs[self.div]
  return r
end

function Ero:inc(div)
  if div~=divs[self.div] then
    do return end
  end
  self.step=(self.step%self.steps)+1
end

return Ero
