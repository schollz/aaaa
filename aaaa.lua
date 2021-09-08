-- _
--
--

er = require("er")

local shift=false
aaaa={	
	steps=16,
	operations={"+","*","+","+"},
	--       n r m
	values={{8,0,1},{7,0,2},{4,0,3},{5,1,-7}},
}

function init()
	print("started _")
	redraw()
end

function er_compute(steps,values,operations)
	local res={}
	for i=1,steps do
		res[i]=0
	end
	for i, vs in ipairs(values) do
		local k=vs[1] -- pulses
		local n=steps -- steps
		local w=vs[2] -- shift
		local m=vs[3] -- multiplier
		local ev=er.gen(k,n,w)
		for j,has_step in ipairs(ev) do 
			if has_step then
				if operations[i]=="+" then
					res[j]=res[j]+m
				elseif operations[i]=="-" then
					res[j]=res[j]-m
				elseif operations[i]=="/" then
					res[j]=res[j]/m
				elseif operations[i]=="x" then
					res[j]=res[j]*m
				elseif operations[i]=="%" then
					res[j]=res[j]%m
				end
			end
		end
	end
	return res
end

function redraw()
	screen.clear()
	local res=er_compute(aaaa.steps,aaaa.values,aaaa.operations)
	tab.print(res)
	screen.level(15)
	local max_value=23 -- TODO: don't do if not scaling
	for i,r in ipairs(res) do
		if math.abs(r) > max_value then
			max_value=math.abs(r)
		end
	end
	for i,r in ipairs(res) do
		rabs = math.floor(math.abs(r)/max_value*23)
		local x=49+(5*(i-1))
		local y=23-rabs
		if r<0 then
			y=24
		end
		screen.rect(x,y,4,rabs)
		screen.fill()
	end
	screen.level(2)
	for i,_ in ipairs(res) do
		local x=49+(5*(i-1))
		local y=24
		screen.move(x,y)
		screen.line(x+4,y)
		screen.stroke()
	end

	screen.level(15)
	screen.move(22,12)
	screen.text_center("pitch")
	for i,vs in ipairs(aaaa.values) do
		for j,v in ipairs(vs) do
			local x=12+(j-1)*10
			local y=25+(i-1)*10
			screen.move(x,y)
			screen.text_center(v)
		end
	end
	for i,v in ipairs(aaaa.operations) do
		if i > 1 then
			local x=4
			local y=22+(i-1)*10
			screen.move(x,y)
			screen.text_center(v)
		end
	end
	screen.update()
end


function rerun()
  norns.script.load(norns.state.script)
end

function r()
  rerun()
end
