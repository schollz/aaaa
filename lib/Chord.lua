local Chord={}
local fourchords_=include("synthy/lib/fourchords")
fourchords=fourchords_:new({fname=_path.code.."synthy/lib/4chords_top1000.txt"})

local function new_chords()
  local chord_text=table.concat(fourchords:random_weighted()," ")
  local chords={}
  for chord in chord_text:gmatch("%S+") do
    local data=music.chord_to_midi(chord..":"..params:get("chordy_octave"))
    if data~=nil then
      table.insert(s.chords,{name=chord,data=data})
      print("new_chords: added "..chord)
    end
  end
  return chords
end

function Chord:new(name)
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
  -- self parameter should no refer to Chord
  -- https://www.lua.org/pil/16.2.html
  local s=eros:new()

  -- define chords
  s.chords=new_chords()
  s.chord_current=0
  s.notes_on={}
  s:set_maps(maps)
  s:set_action(function(p)
    local step=p.step%16
    -- stop any note that exceeded duration
    for k,v in pairs(s.notes_on) do
      s.notes_on[k].length=s.notes_on[k].length+1
      if s.notes_on[k].duration==s.notes_on[k].length or p.trigger>0 then
        print("Chord: note off "..k)
        s.notes_on[k]=nil
        engine.synthy_note_off(k)
      end
    end
    if p.trigger>0 then
      -- determine next chord
      local next_chord=1 
      if step>12 then
        next_chord=4
      elseif step>8 then
        next_chord=3
      elseif step>4 then
        next_chord=2
      end
      for _, note in pairs(s.chords[next_chord].data) do
        -- TODO: for each note in chord, play it
        print("Chord: playing "..note.m.." at "..p.velocity.." for "..p.duration)
        s.notes_on[note.m]={length=0,duration=p.duration}
        engine.synthy_note_on(note.m,p.velocity/127)
      end
    end
  end)
  s.props={"trigger","velocity","duration"}
  s.name=name
  return s
end

return Chord
