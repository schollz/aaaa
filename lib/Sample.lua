local Sample={}

function Sample:new(name)
  -- define maps for the synth type
  local maps={}
  maps.velocity={}
  for i=1,63 do
    table.insert(maps.velocity,(i-1)*2) -- 0 to 124 (sorta midi range)
  end
  maps.rate={-2,-1,-0.5,0.5,1,1.5,2,2.5,4}
  -- middle duration is one note
  maps.duration={}
  for i=8,1,-1 do
    table.insert(maps.duration,i)
  end
  for i=1,8 do
    table.insert(maps.duration,i)
  end
  -- trigger is only 1 above 0
  maps.trigger={}
  for i=1,32 do
    table.insert(maps.trigger,0)
  end
  for i=1,31 do
    table.insert(maps.trigger,1)
  end

  -- define new "Eros" type to inherit
  -- inherit Eros methods
  local eros=Eros:new()
  -- define new eros
  -- self parameter should no refer to Sample
  -- https://www.lua.org/pil/16.2.html
  local s=eros:new()
  s:set_maps(maps)
  s:set_action(function(p)
    if p.trigger>0 then
      Tabutil.print(p)
    end
  end)
  s.props={"trigger","rate","velocity","duration"}
  s.name=name
  return s
end

return Sample
