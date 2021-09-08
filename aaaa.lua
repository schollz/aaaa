-- _
--
--

local er = require("er")
local lattice = require("lattice")
local musicutil = require("musicutil")

engine.name="PolyPerc"
local shift=false
local step=1
local ops={"+","-","x","/","%"}
local notes = musicutil.generate_scale_of_length(20, 5, 48)
aaaa={	
	current=1,
	steps=16,
	operations={1,3,1,1},
	--       m n r
	values={{1,8,0},{2,7,0},{3,4,0},{-7,5,1}},
}

function init()
	print("started _")
	redraw()

  local seq = lattice:new{
    ppqn = 96
  }
  seq:new_pattern{
  	action=function(t)
  		step=step+1
  		if step > aaaa.steps then
  			step=1
  		end
  		redraw()
  		if aaaa.steps>0 then
				local res=er_compute(aaaa.steps,aaaa.values,aaaa.operations)
				print(res[step])
				if res[step]~=0 then
					if res[step]>0 then
						res[step]=res[step]-1
					end
					local ind=math.floor(res[step]+24)
					if ind~=nil then
						engine.hz(musicutil.note_num_to_freq(notes[ind]))
					end
				end
  		end
  	end,
  	division=1/8,
  }
  seq:start()
end


function enc(k,d)
	if shift then
		if k==1 then
			aaaa.steps=util.clamp(aaaa.steps+sign(d),0,16)
		elseif k==2 then
			aaaa.current=util.clamp(aaaa.current+sign(d),1,4)
		else
			if aaaa.current > 1 then
				aaaa.operations[aaaa.current]=util.clamp(aaaa.operations[aaaa.current]+sign(d),1,5)
			end
		end
	else
		if k==1 then
			aaaa.values[aaaa.current][1]=aaaa.values[aaaa.current][1]+sign(d)
			aaaa.values[aaaa.current][1]=util.clamp(aaaa.values[aaaa.current][1],-22,22)
		elseif k==2 then
			aaaa.values[aaaa.current][2]=aaaa.values[aaaa.current][2]+sign(d)
			aaaa.values[aaaa.current][2]=util.clamp(aaaa.values[aaaa.current][2],0,aaaa.steps)
		else
			aaaa.values[aaaa.current][3]=aaaa.values[aaaa.current][3]+sign(d)
			aaaa.values[aaaa.current][3]=util.clamp(aaaa.values[aaaa.current][3],0,aaaa.steps-1)
		end
	end
	redraw()
end

function key(k,z)
	if k==1 then
		shift=z==1
	end
	redraw()
end

function er_compute(steps,values,operations)
	local res={}
	for i=1,steps do
		res[i]=0
	end
	for i, vs in ipairs(values) do
		local m=vs[1] -- multiplier
		local k=vs[2] -- pulses
		local n=steps -- steps
		local w=vs[3] -- shift
		local ev=er.gen(k,n,w)
		for j,has_step in ipairs(ev) do 
			if has_step then
				if operations[i]==1 then
					res[j]=res[j]+m
				elseif operations[i]==2 then
					res[j]=res[j]-m
				elseif operations[i]==3 then
					res[j]=res[j]*m
				elseif operations[i]==4 then
					res[j]=res[j]/m
				elseif operations[i]==5 then
					res[j]=res[j]%m
				end
			end
		end
	end
	-- clamp values
	for i,v in ipairs(res) do
		res[i]=util.clamp(v,-23,23)
	end
	return res
end

function redraw()
	screen.clear()
	local res=er_compute(aaaa.steps,aaaa.values,aaaa.operations)
	local max_value=23 -- TODO: don't do if not scaling
	for i,r in ipairs(res) do
		if math.abs(r) > max_value then
			max_value=math.abs(r)
		end
	end
	for i,r in ipairs(res) do
		screen.level(2)
		if step==i then
			screen.level(15)
		end
		rabs = math.floor(math.abs(r)/max_value*23)
		local x=49+(5*(i-1))
		local y=23-rabs
		if r<0 then
			y=24
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
		local y=24
		screen.move(x,y)
		screen.line(x+4,y)
		screen.stroke()
	end

	screen.move(22,12)
	screen.level(15)
	screen.text_center("pitch")
	for i,vs in ipairs(aaaa.values) do
		screen.level(2)
		if aaaa.current==i then
			screen.level(15)
		end
		for j,v in ipairs(vs) do
			local x=12+(j-1)*10
			local y=23+(i-1)*10
			screen.move(x,y)
			screen.text_center(v)
		end
	end
	for i,v in ipairs(aaaa.operations) do
		screen.level(2)
		if aaaa.current==i then
			screen.level(15)
		end
		if i > 1 then
			local x=4
			local y=20+(i-1)*10
			screen.move(x,y)
			screen.text_center(ops[v])
		end
	end

	if shift then
		screen.move(1,62)
		screen.text("K1 steps K2 switches K3 op")
	else
		screen.move(1,62)
		screen.text("K1 num K2 # pulses K3 shift")
	end
	screen.update()
end


function rerun()
  norns.script.load(norns.state.script)
end

function r()
  rerun()
end


function sign(x)
	if x > 0 then
		do return 1 end
	elseif x < 0 then
		do return -1 end 
	end
	return 0
end