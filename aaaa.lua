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
Tabutil=require("tabutil")
MusicUtil=require("musicutil")
Ero=include("aaaa/lib/Ero")
Eros=include("aaaa/lib/Eros")
Synth=include("aaaa/lib/Synth")

engine.name="PolyPerc"
-- program state
s={
  id_snd=1,-- index of the current synth or sample
  id_op=1,-- index of the current operation (1-18)
  id_prop=1,-- index of the current property (defined by the snd)
  shift=false,
}
-- user state (saveable)
u={
  snd={},
}
-- constants
local divs={1/32,1/16,1/8,1/4,1/2,1}
local divs_name={"tn","sn","en","qn","hn","wn"}

function init()
  for i=1,2 do
    u.snd[i]=Synth:new("synth "..i)
    for prop,_ in pairs(u.snd[i].eros) do
      u.snd[i].eros[prop]:random()
    end
  end
  s.playing=false
  s.lattice=Lattice:new{
    ppqn=96
  }
  for id_div,div in ipairs(divs) do
    s.lattice:new_pattern{
      action=function(t)
        for _,snd in ipairs(u.snd) do
          -- sound only steps when its the correct division
          -- and its currently playing
          snd:next(id_div)
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


  u.snd[1]:toggle_playing()
  u.snd[2]:toggle_playing()
  if not s.playing then
    s.lattice:hard_restart()
  else
    s.lattice:stop()
  end
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
  local snd=u.snd[s.id_snd]
  local prop=snd.props[s.id_prop]
  local id_op_val=0
  --  every operation should go here
  id_op_val=id_op_val+1
  if id_op_val==s.id_op then
    snd:toggle_playing()
  end
  id_op_val=id_op_val+1
  if id_op_val==s.id_op then
    -- change number of steps
    snd:delta(prop,{steps=d})
  end
  id_op_val=id_op_val+1
  if id_op_val==s.id_op then
    -- change div
    snd:delta(prop,{div=d})
  end
  for i=1,4 do
    -- operation
    if i>1 then
      id_op_val=id_op_val+1
      if id_op_val==s.id_op then
        -- change op
        snd:delta(prop,{op=d},i)
      end
    end
    -- m, p, w
    id_op_val=id_op_val+1
    if id_op_val==s.id_op then
      snd:delta(prop,{m=d},i)
    end
    id_op_val=id_op_val+1
    if id_op_val==s.id_op then
      snd:delta(prop,{p=d},i)
    end
    id_op_val=id_op_val+1
    if id_op_val==s.id_op then
      snd:delta(prop,{w=d},i)
    end
  end
end

function key(k,z)
  if k==1 then
    shift=z==1
  end
  if k>1 and shift then
    if k==2 then

    elseif k==3 then
      u.snd[1]:toggle_playing()
      if not s.playing then
        s.lattice:hard_restart()
      else
        s.lattice:stop()
      end
    end
  elseif k>1 and not shift and z==1 then
    local d=k*2-5
    s.id_prop=util.clamp(s.id_prop+d,1,#u.snd[s.id_snd].props)
  end
end

function redraw()
  screen.clear()

  local snd=u.snd[s.id_snd]
  if snd==nil then
    do return end
  end
  if snd.eros==nil then
    do return end
  end
  local prop=snd.props[s.id_prop]


  screen.level(15)
  screen.rect(1,1,46,63)
  screen.stroke()

  screen.level(15)
  screen.rect(1,1,46,8)
  screen.fill()

  screen.level(0)
  screen.move(23,6)
  screen.text_center(snd.name)

  if s.id_op==1 then
    screen.level(15)
  else
    screen.level(2)
  end
  screen.move(10,16)
  screen.text_center(snd.playing and ">" or "||")
  if s.id_op==2 then
    screen.level(15)
  else
    screen.level(2)
  end
  screen.move(23,16)
  screen.text_center(snd.eros[prop].steps)
  if s.id_op==3 then
    screen.level(15)
  else
    screen.level(2)
  end
  screen.move(37,16)
  screen.text_center(divs_name[snd.eros[prop].div])

  -- draw rectangles
  local res=snd.eros[prop]:get_res()
  for i,r in ipairs(res) do
    screen.level(2)
    if snd.eros[prop].step==i then
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
    if snd.eros[prop].step==i then
      screen.level(15)
    end
    local x=49+(5*(i-1))
    local y=33
    screen.move(x,y)
    screen.line(x+4,y)
    screen.stroke()
  end

  -- write down the actual values
  local xp=8
  local yp=21
  local rowh=9
  local roww=11
  local id_op_val=3
  for i=1,4 do
    local ero=snd.eros[prop]:get(i)
    -- operation
    if i>1 then
      id_op_val=id_op_val+1
      if id_op_val==s.id_op then
        screen.level(15)
      else
        screen.level(2)
      end
      local x=xp-2
      local y=yp+(i-1)*rowh
      screen.move(x,y)
      screen.text_center(ero.op)
    end
    -- m, p, w
    vs={ero.m,ero.p,ero.w}
    for j,v in ipairs(vs) do
      id_op_val=id_op_val+1
      if id_op_val==s.id_op then
        screen.level(15)
      else
        screen.level(2)
      end
      local x=xp+8+(j-1)*roww
      local y=yp+5+(i-1)*rowh
      screen.move(x,y)
      screen.text_center(v)
    end
  end


  screen.level(15)
  screen.rect(1,56,46,8)
  screen.fill()

  screen.level(0)
  screen.move(23,62)
  screen.text_center(prop)
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





