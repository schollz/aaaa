format: lua-format.py
	echo "formating"
	python3 lua-format.py lib/Eros.lua
	python3 lua-format.py lib/Ero.lua
	python3 lua-format.py lib/Synth.lua
	python3 lua-format.py aaaa.lua

lua-format.py:
	wget https://raw.githubusercontent.com/schollz/LuaFormat/master/lua-format.py


