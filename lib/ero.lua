local Ero={}

function Ero:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o:init()
  return o
end

function Ero:init()
  self.operations={1,1,1,1}
  self.values={{1,8,0},{2,7,0},{3,4,0},{-7,5,1}}
end

return Ero
