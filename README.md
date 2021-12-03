# WeightedSoundMixer
Blending sound volumes based on weights where higher weighted sounds play louder than lower weighted sounds. This does not manage or read your sound playback states, it just adjusts volumes. Transitions between volumes are handeled by a fixed-step lerp, tweak it until it sounds good / don't expect a lot of sanity there.

MixedVolume = OriginalVolume * (GivenWeight / HighestWeightInMixer)

*module.new()*
 - creates a new empty mixer.

*mixer:Add(sound, weight, fadeStrenght)*
 - sound: a roblox sound object (or anything with a .Volume index)
 - weight: any number greater than 0. This represents how loud the sound will be in the mix. If not provided then a default of 1 is used.
 - fadeStrength: where 0 is no change in volume, 0 onto 1 is a quicker change in volume, 1 is an instant change in volume, and past 1 your ears hurt. If not provided a default of 1 is used.

mixer:Remove(sound)
 - sound: a sound object to remove from the mix. Removing a sound will return it's volume to the value it had when it as added to the mix.

mixer:Mix()
 - processes the current volume mix. It's reccomended that you call this fairly frequently if you are using fade strength values other than 1.

See Source.lua for extra API that I can't be bothered to doccument.
