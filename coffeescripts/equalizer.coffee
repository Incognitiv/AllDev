AudioContext = 0
context = new AudioContext()
srcNode = 0
analyser = 0
jsNode = 0
ctx = $("music").get()[0].getContext("2d")
i = 0
val = 0

gradient = ctx.createLinearGradient(0, 0, 0, 255)
gradient.addColorStop 1, "#FFFFFF"
gradient.addColorStop 0, "#000000"

unless window.AudioContext
	alert "AudioContext was not found!" unless window.webkitAudioContext
	window.AudioContext = window.webkitAudioContext

setupAudioNodes = ->
	"use strict"
	jsNode = context.createScriptProcessor(2048, 1, 1)
	jsNode.connect context.destination
	analyser = context.createAnalyser()
	analyser.smoothingTimeConstant = 0.795
	analyser.fftSize = 2048
	srcNode = context.createBufferSource()
	srcNode.connect analyser
	analyser.connect jsNode
	srcNode.connect context.destination
	return

setupAudioNodes()

playSound = (buffer) ->
	"use strict"
	srcNode.buffer = buffer
	srcNode.start(0)
	return

onError = (e) ->
	"use strict"
	console.log e
	return

loadSound = (url) ->
	"use strict"
	request = new XMLHttpRequest()
	request.open "GET", url, true
	request.responseType = "arraybuffer"
	request.onload = ->
		context.decodeAudioData request.response, ((buffer) ->
			playSound buffer
			return
		), onError
		return
	request.send()
	return

drawSpectrum = (array) ->
	"use strict"
	while i < (array.length)
		i = i + 1
		val = array[i]
		ctx.fillRect i * 8, 260 - val, 4, 260
	return

jsNode.onaudioprocess = ->
	"use strict"
	arr = new Uint8Array(analyser.frequencyBinCount)
	analyser.getByteFrequencyData arr
	ctx.clearRect 0, 0, 2048, 255
	ctx.fillStyle = gradient
	drawSpectrum arr