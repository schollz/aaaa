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
  self:recalculate()
end

function Ero:random()
  for i=1,4 do
    self.ero[i].op=math.random(1,2) -- operation
    if self.ero[i].op>2 then
      self.ero[i].m=math.random(-2,2) -- multipler
      if self.ero[i].m==0 then
        self.ero[i].m=1
      end
    else
      self.ero[i].m=math.random(-15,15) -- multipler
    end
    self.ero[i].p=math.random(2,10) -- pulse
    self.ero[i].w=math.random(1,2) -- shift
  end
  self:clamp()
  self:recalculate()
end

function Ero:reset()
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
  if self.steps==0 then
    do return end
  end
  for i,ero in ipairs(self.ero) do
    local ev=ER.gen(ero.p,self.steps,ero.w)
    for j,has_step in ipairs(ev) do
      if has_step then
        if ero.op==1 then
          self.res[j]=self.res[j]+ero.m
        elseif ero.op==2 then
          self.res[j]=self.res[j]-ero.m
        elseif ero.op==3 then
          self.res[j]=self.res[j]*ero.m
        elseif ero.op==4 then
          self.res[j]=self.res[j]/ero.m
        elseif ero.op==5 then
          self.res[j]=self.res[j]%ero.m
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

function Ero:delta(kv,i)
  for k,v in pairs(kv) do
    print(k,v)
    if k=="div" or k=="steps" then
      self[k]=self[k]+v
    elseif i~=nil then
      self.ero[i][k]=self.ero[i][k]+v
    end
  end
  self:clamp()
  self:recalculate()
end

function Ero:clamp()
  for i=1,4 do
    self.ero[i].op=util.clamp(self.ero[i].op,1,#ops)
    self.ero[i].m=util.clamp(self.ero[i].m,-31,31)
    self.ero[i].p=util.clamp(self.ero[i].p,0,16)
    self.ero[i].w=util.clamp(self.ero[i].w,0,15)
  end
  self.div=util.clamp(self.div,1,#divs)
  self.steps=util.clamp(self.steps,1,16)
end

function Ero:get(i)
  local r={}
  for k,v in pairs(self.ero[i]) do
    r[k]=v
  end
  r.op=ops[r.op]
  r.div=self.div
  return r
end

-- inc increments the current step
function Ero:inc(div,step)
  self.step=(step%self.steps)+1
end

-- eror returns the current for all steps
-- euclidean rhythm operation result
function Ero:get_res()
  return self.res,self.resmap
end

-- get_mapped returns the mapped value
-- for current step
function Ero:get_mapped()
  return self.resmap[self.step]
end

return Ero
