-- _
--
-- E1 switches synth/sample
-- E2 switches operation
-- E3 changes operation value
-- K1/K2 switches property
-- K1+K2 toggles current track
-- K1+K3 toggles all tracks
-- K1+E1 copies shared props
-- K1+E3 moves through rand props
-- hold K1 to see mapped values
--

ER=require("er")
Lattice=require("lattice")
MusicUtil=require("musicutil")
Ero=include("aaaa/lib/Ero")
Eros=include("aaaa/lib/Eros")
Synth=include("aaaa/lib/Synth")

engine.name="PolyPerc"
-- program state
s={
  id_snd=1,
  id_op=1,
  id_prop=1,
  shift=false,
}
-- user state (saveable)
u={
  snd={},
}

function init()
  for i=1,2 do
    u.snd[i]=Synth:new()
  end
  local divs={1/32,1/16,1/8,1/4,1/2,1}
  s.playing=false
  s.lattice=Lattice:new{
    ppqn=96
  }
  for _,div in ipairs(divs) do
    s.lattice:new_pattern{
      action=function(t)
        for _,snd in ipairs(u.snd) do
          snd.inc(div)
        end
      end,
      division=div,
    }
  end

  clock.run(function()
    while true do
      redraw()
      clock.sleep(1/15)
    end
  end)
end


function enc(k,d)
  if shift then
  else
    if k==1 then
      s.id_snd=util.clamp(s.id_snd+sign(d),1,#u.snd)
    elseif k==2 then
      s.id_op=util.clamp(s.id_op+sign(d),1,18)
    elseif k==3 then
      change_op(sign(d))
    end
  end
end

function change_op(d)
  -- TODO: every operation should go here
end

function key(k,z)
  if k==1 then
    shift=z==1
  end
  if k>1 and shift then
    if k==2 then

    elseif k==3 then
      if not s.playing then
        s.lattice:hard_restart()
      else
        s.lattice:stop()
      end
      s.playing=not s.playing
    end
  elseif k>1 and not shift then
    z=z*2-5
    s.id_prop=util.clamp(s.id_prop+sign(d),1,u.snd[s.id_snd]:get_prop_num())
  end
end

function redraw()
  screen.clear()

  screen.level(15)
  screen.rect(1,1,46,63)
  screen.stroke()

  screen.level(15)
  screen.rect(1,1,46,8)
  screen.fill()

  screen.level(0)
  screen.move(23,6)
  screen.text_center("synth 1")

  screen.level(15)
  screen.move(23,16)
  screen.text_center("pitch")


  local res=er_compute(aaaa.steps,aaaa.values,aaaa.operations)
  for i,r in ipairs(res) do
    screen.level(2)
    if step==i then
      screen.level(15)
    end
    rabs=math.abs(r)
    local x=49+(5*(i-1))
    local y=32-rabs
    if r<0 then
      y=33
    end
    screen.rect(x,y,4,rabs)
    screen.fill()
  end
  for i,_ in ipairs(res) do
    screen.level(2)
    if step==i then
      screen.level(15)
    end
    local x=49+(5*(i-1))
    local y=33
    screen.move(x,y)
    screen.line(x+4,y)
    screen.stroke()
  end

  local xp=8
  local yp=21
  local rowh=9
  local roww=11
  for i,vs in ipairs(aaaa.values) do
    screen.level(2)
    if aaaa.current==i then
      screen.level(15)
    end
    for j,v in ipairs(vs) do
      local x=xp+8+(j-1)*roww
      local y=yp+5+(i-1)*rowh
      screen.move(x,y)
      screen.text_center(v)
    end
  end
  for i,v in ipairs(aaaa.operations) do
    screen.level(2)
    if aaaa.current==i then
      screen.level(15)
    end
    if i>1 then
      local x=xp-2
      local y=yp+(i-1)*rowh
      screen.move(x,y)
      screen.text_center(ops[v])
    end
  end


  screen.level(15)
  screen.rect(1,56,46,8)
  screen.fill()

  screen.level(0)
  screen.move(23,62)
  screen.text_center("n=16, 1/4")
  screen.update()
end


function rerun()
  norns.script.load(norns.state.script)
end

function r()
  rerun()
end


function sign(x)
  if x>0 then
    do return 1 end
  elseif x<0 then
    do return-1 end
  end
  return 0
end





