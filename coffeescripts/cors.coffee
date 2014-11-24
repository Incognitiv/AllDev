createCORSRequest = (method, url) ->
	xhr = new XMLHttpRequest()
	if "withCredentials" of xhr
		xhr.open method, url, true
	else unless typeof XDomainRequest is "undefined"
		xhr = new XDomainRequest()
		xhr.open method, url
	else
		xhr = null
	xhr

getTitle = (text) ->
	text.match("<title>(.*)?</title")[1]

makeCorsRequest = (url) ->
	xhr = createCORSRequest "GET", url
	unless xhr
		console.log "CORS is not supported!"
		return

	xhr.onload = ->
		text = xhr.responseText
		title = getTitle(text)
		console.log "Response from CORS request to #{url}: #{title}"
		return

	xhr.onerror = ->
		console.log "Request error!"
		return

	xhr.send()
	return