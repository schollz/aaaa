local Ero={}

-- internal constants
local divs={1/32,1/16,1/8,1/4,1/2,1}
local ops={"+","-","x","/","%"}

-- new can define map {map={1,2,3,4}}
function Ero:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o:init()
  return o
end

function Ero:init()
  self.res={}
  self.resmap={}
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
  self.res={}
  self.resmap={}
  for i=1,self.steps do
    self.res[i]=0
    self.resmap[i]=1
  end
  for i,vs in ipairs(self.ero) do
    local ev=er.gen(self.p,self.steps,self.w)
    for j,has_step in ipairs(ev) do
      if has_step then
        if self.op[i]==1 then
          self.res[j]=self.res[j]+m
        elseif self.op[i]==2 then
          self.res[j]=self.res[j]-m
        elseif self.op[i]==3 then
          self.res[j]=self.res[j]*m
        elseif self.op[i]==4 then
          self.res[j]=self.res[j]/m
        elseif self.op[i]==5 then
          self.res[j]=self.res[j]%m
        end
      end
    end
  end
  -- clamp values and map them
  for i,v in ipairs(self.res) do
    self.res[i]=util.clamp(v,-31,31)
    if self.map~=nil then
      local ind=math.floor(util.linlin(-31,31,1,#self.map+0.9999,self.res[i]))
      self.resmap[i]=self.map[ind]
    else
      self.resmap[i]=self.res[i]
    end
  end
end


-- set_div(div) where div=1/4, 1/8, etc.
function Ero:set_div(div)
  for i,v in ipairs(divs) do
    if v==div then
      self.div=i
    end
  end
end

function Ero:set_steps(steps)
  self.steps=steps
  self:recalculate()
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

-- inc increments the current step
function Ero:inc(div)
  if div~=divs[self.div] then
    do return end
  end
  self.step=(self.step%self.steps)+1
end

-- eror returns the current
-- euclidean rhythm operation result
function Ero:get_res()
  return self.res,self.resmap
end

return Ero
