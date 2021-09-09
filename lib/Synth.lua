local Synth={}

function Synth:new(name)
  -- define maps for the synth type
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

  -- define new "Eros" type to inherit
  -- inherit Eros methods
  local eros=Eros:new()
  -- define new eros
  -- self parameter should no refer to Synth
  -- https://www.lua.org/pil/16.2.html
  local s=eros:new()
  s.notes=MusicUtil.generate_scale_of_length(24,5,63)
  s.notes_on={}
  s:set_maps(maps)
  s:set_action(function(p)
    -- stop any note that exceeded duration
    for k,v in pairs(s.notes_on) do
      s.notes_on[k].length=s.notes_on[k].length+1
      if s.notes_on[k].duration==s.notes_on[k].length then
        print("Synth: note off "..k)
        s.notes_on[k]=nil
        engine.synthy_note_off(k)
      end
    end
    if p.trigger>0 then
      local note=s.notes[p.pitch]
      print("Synth: playing "..note.." at "..p.velocity.." for "..p.duration)
      s.notes_on[note]={length=0,duration=p.duration}
      engine.synthy_note_on(note,p.velocity/127)
    end
  end)
  s.props={"trigger","pitch","velocity","duration","transpose"}
  s.name=name
  return s
end

function Synth:emit(p)

  -- -- turn off notes that are done
  -- local notes_done={}
  -- for k,v in pairs(self.notes_on) do
  --   self.notes_on[k].beats=v.beats+1
  --   if self.notes_on[k].beats==v.duration then
  --     -- note is done
  --     table.insert(notes_done,k)
  --   end
  -- end
  -- for _,note in ipairs(notes_done) do
  --   -- TODO: turn off note
  --   self.notes_on[k]=nil
  -- end

  -- -- turn on new note
  -- self.notes_on[p.pitch]={beats=0,duration=p.duration}
  -- -- TODO: turn on note in engine
end

return Synth
