# Utils.log = ->
# 	console.log arguments.join " "

{_} = require "./Underscore"

Utils = {}

Utils.setDefaultProperties = (obj, defaults, warn=true) ->

	result = {}

	for k, v of defaults
		if obj.hasOwnProperty k
			result[k] = obj[k]
		else
			result[k] = defaults[k]

	if warn
		for k, v of obj
			if not defaults.hasOwnProperty k
				console.warn "Utils.setDefaultProperties: got unexpected option: '#{k} -> #{v}'", obj

	result

Utils.valueOrDefault = (value, defaultValue) ->

	if value in [undefined, null]
		value = defaultValue

	return value

Utils.arrayToObject = (arr) ->
	obj = {}

	for item in arr
		obj[item[0]] = item[1]

	obj

Utils.arrayNext = (arr, item) ->
	arr[arr.indexOf(item) + 1] or _.first arr

Utils.arrayPrev = (arr, item) ->
	arr[arr.indexOf(item) - 1] or _.last arr


######################################################
# TIME FUNCTIONS

# Note: in Framer 3 we try to keep all times in seconds

# Used by animation engine, needs to be very performant
Utils.getTime = -> Date.now() / 1000

# This works only in chrome, but we only use it for testing
# if window.performance
# 	Utils.getTime = -> performance.now() / 1000

Utils.delay = (time, f) ->
	timer = setTimeout f, time * 1000
	# window._delayTimers ?= []
	# window._delayTimers.push timer
	return timer
	
Utils.interval = (time, f) ->
	timer = setInterval f, time * 1000
	# window._delayIntervals ?= []
	# window._delayIntervals.push timer
	return timer

Utils.debounce = (threshold=0.1, fn, immediate) ->
	timeout = null
	threshold *= 1000
	(args...) ->
		obj = this
		delayed = ->
			fn.apply(obj, args) unless immediate
			timeout = null
		if timeout
			clearTimeout(timeout)
		else if (immediate)
			fn.apply(obj, args)
		timeout = setTimeout delayed, threshold

Utils.throttle = (delay, fn) ->
	return fn if delay is 0
	delay *= 1000
	timer = false
	return ->
		return if timer
		timer = true
		setTimeout (-> timer = false), delay unless delay is -1
		fn arguments...


######################################################
# HANDY FUNCTIONS

Utils.randomColor = (alpha = 1.0) ->
	c = -> parseInt(Math.random() * 255)
	"rgba(#{c()}, #{c()}, #{c()}, #{alpha})"

Utils.randomChoice = (arr) ->
	arr[Math.floor(Math.random() * arr.length)]

Utils.randomNumber = (a=0, b=1) ->
	# Return a random number between a and b
	Utils.mapRange Math.random(), 0, 1, a, b

Utils.uuid = ->

	chars = "0123456789abcdefghijklmnopqrstuvwxyz".split("")
	output = new Array(36)
	random = 0

	for digit in [1..32]
		random = 0x2000000 + (Math.random() * 0x1000000) | 0 if (random <= 0x02)
		r = random & 0xf
		random = random >> 4
		output[digit] = chars[if digit == 19 then (r & 0x3) | 0x8 else r]

	output.join ""

Utils.arrayFromArguments = (args) ->

	# Convert an arguments object to an array
	
	if _.isArray args[0]
		return args[0]
	
	Array.prototype.slice.call args

Utils.cycle = ->
	
	# Returns a function that cycles through a list of values with each call.
	
	args = Utils.arrayFromArguments arguments
	
	curr = -1
	return ->
		curr++
		curr = 0 if curr >= args.length
		return args[curr]

# Backwards compatibility
Utils.toggle = Utils.cycle


######################################################
# ENVIROMENT FUNCTIONS

Utils.isWebKit = ->
	window.WebKitCSSMatrix isnt null
	
Utils.isTouch = ->
	window.ontouchstart is null

Utils.isMobile = ->
	(/iphone|ipod|android|ie|blackberry|fennec/).test \
		navigator.userAgent.toLowerCase()

Utils.isChrome = ->
	(/chrome/).test \
		navigator.userAgent.toLowerCase()

Utils.isLocal = ->
	Utils.isLocalUrl window.location.href

Utils.isLocalUrl = (url) ->
	url[0..6] == "file://"

Utils.devicePixelRatio = ->
	window.devicePixelRatio

######################################################
# MATH FUNCTIONS
		
Utils.round = (value, decimals) ->
	d = Math.pow 10, decimals
	Math.round(value * d) / d

# Taken from http://jsfiddle.net/Xz464/7/
# Used by animation engine, needs to be very performant
Utils.mapRange = (value, fromLow, fromHigh, toLow, toHigh) ->
	toLow + (((value - fromLow) / (fromHigh - fromLow)) * (toHigh - toLow))

######################################################
# STRING FUNCTIONS

Utils.parseFunction = (str) ->

	result = {name: "", args: []}

	if _.endsWith str, ")"
		result.name = str.split("(")[0]
		result.args = str.split("(")[1].split(",").map (a) -> _.trim(_.rtrim(a, ")"))
	else
		result.name = str

	return result

######################################################
# DOM FUNCTIONS

__domComplete = []

if document?
	document.onreadystatechange = (event) =>
		if document.readyState is "complete"
			while __domComplete.length
				f = __domComplete.shift()()

Utils.domComplete = (f) ->
	if document.readyState is "complete"
		f()
	else
		__domComplete.push f

Utils.domCompleteCancel = (f) ->
	__domComplete = _.without __domComplete, f

Utils.domLoadScript = (url, callback) ->
	
	script = document.createElement "script"
	script.type = "text/javascript"
	script.src = url
	
	script.onload = callback
	
	head = document.getElementsByTagName("head")[0]
	head.appendChild script
	
	script

######################################################
# GEOMERTY FUNCTIONS

# Point

Utils.pointMin = ->
	points = Utils.arrayFromArguments arguments
	point = 
		x: _.min point.map (size) -> size.x
		y: _.min point.map (size) -> size.y

Utils.pointMax = ->
	points = Utils.arrayFromArguments arguments
	point = 
		x: _.max point.map (size) -> size.x
		y: _.max point.map (size) -> size.y

# Size

Utils.sizeMin = ->
	sizes = Utils.arrayFromArguments arguments
	size  =
		width:  _.min sizes.map (size) -> size.width
		height: _.min sizes.map (size) -> size.height

Utils.sizeMax = ->
	sizes = Utils.arrayFromArguments arguments
	size  =
		width:  _.max sizes.map (size) -> size.width
		height: _.max sizes.map (size) -> size.height

# Frames

# min mid max * x, y

Utils.frameGetMinX = (frame) -> frame.x
Utils.frameSetMinX = (frame, value) -> frame.x = value

Utils.frameGetMidX = (frame) -> 
	if frame.width is 0 then 0 else frame.x + (frame.width / 2.0)
Utils.frameSetMidX = (frame, value) ->
	frame.x = if frame.width is 0 then 0 else value - (frame.width / 2.0)

Utils.frameGetMaxX = (frame) -> 
	if frame.width is 0 then 0 else frame.x + frame.width
Utils.frameSetMaxX = (frame, value) ->
	frame.x = if frame.width is 0 then 0 else value - frame.width

Utils.frameGetMinY = (frame) -> frame.y
Utils.frameSetMinY = (frame, value) -> frame.y = value

Utils.frameGetMidY = (frame) -> 
	if frame.height is 0 then 0 else frame.y + (frame.height / 2.0)
Utils.frameSetMidY = (frame, value) ->
	frame.y = if frame.height is 0 then 0 else value - (frame.height / 2.0)

Utils.frameGetMaxY = (frame) -> 
	if frame.height is 0 then 0 else frame.y + frame.height
Utils.frameSetMaxY = (frame, value) ->
	frame.y = if frame.height is 0 then 0 else value - frame.height


Utils.frameSize = (frame) ->
	size =
		width: frame.width
		height: frame.height

Utils.framePoint = (frame) ->
	point =
		x: frame.x
		y: frame.y

Utils.frameMerge = ->

	# Return a frame that fits all the input frames

	frames = Utils.arrayFromArguments arguments

	frame =
		x: _.min frames.map Utils.frameGetMinX
		y: _.min frames.map Utils.frameGetMinY

	frame.width  = _.max(frames.map Utils.frameGetMaxX) - frame.x
	frame.height = _.max(frames.map Utils.frameGetMaxY) - frame.y

	frame





# Points

# Utils.pointDistance = (pointA, pointB) ->
# 	distance =
# 		x: Math.abs(pointB.x - pointA.x)
# 		y: Math.abs(pointB.y - pointA.y)

# Utils.pointInvert = (point) ->
# 	point =
# 		x: 0 - point.x
# 		y: 0 - point.y

# Utils.pointTotal = (point) ->
# 	point.x + point.y



# Utils.pointAbs = (point) ->
# 	point =
# 		x: Math.abs point.x
# 		y: Math.abs point.y

# Utils.pointInFrame = (point, frame) ->
# 	return false  if point.x < frame.minX or point.x > frame.maxX
# 	return false  if point.y < frame.minY or point.y > frame.maxY
# 	true

# Utils.convertPoint = (point, view1, view2) ->

# 	# Public: Convert a point between two view coordinate systems
# 	#
# 	# point - The point to be converted
# 	# view1 - The origin view of the point
# 	# view2 - The destination view of the point
# 	# 
# 	# Returns an Object
# 	#

# 	point = _.clone point
	
# 	traverse = (view) ->
	
# 		currentView = view
# 		superViews = []
	
# 		while currentView and currentView.superLayer
# 			superViews.push currentView.superLayer
# 			currentView = currentView.superLayer
	
# 		return superViews
	
# 	superViews1 = traverse view1
# 	superViews2 = traverse view2
	
# 	superViews2.push view2 if view2
	
# 	for view in superViews1
# 		point.x += view.x
# 		point.y += view.y

# 		if view.scrollFrame
# 			point.x -= view.scrollFrame.x
# 			point.y -= view.scrollFrame.y

# 	for view in superViews2
# 		point.x -= view.x
# 		point.y -= view.y
		
# 		if view.scrollFrame
# 			point.x += view.scrollFrame.x
# 			point.y += view.scrollFrame.y
	
# 	return point

_.extend exports, Utils

