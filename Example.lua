--[[
  1. Play some music 
  2. Play a sound whenever a button is touched
  3. Mix it so the button sound always plays louder than the music

  The mixer will lower the music volume and set the
  button sound volume at "the top of the mix" since 
  it has the highest weight. 

  Blending strengths are used here to transition 
  the music (slowly) and the button sound (quickly)
  between volume levels in respect to their original/set 
  volumes.
--]]

local runService = game:GetService("RunService")
local mixers = require(script.Parent.Mixers)

local music = workspace:WaitForChild("Music")
local button = workspace:WaitForChild("Button")

local mixer = mixers.new()

-- init music
mixer:Add(music, 1, 0.1)

music:Play()

-- init button sound
button.Touched:Connect(function()
	if not button.Sound.IsPlaying then
		button.Sound:Play()
	end
end)

button.Sound.Played:Connect(function()
	mixer:Add(button.Sound, 6, 0.9)
end)

button.Sound.Ended:Connect(function()
	mixer:Remove(button.Sound)
end)

-- run the mix
runService.Heartbeat:Connect(function()
	mixer:Mix()
end)
