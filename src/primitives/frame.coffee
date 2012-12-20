

utils = require "../utils"


{EventEmitter} = require "../eventemitter"

	
class Frame extends EventEmitter

	constructor: (args) ->
		@properties = args

	@define "properties"
		get: ->
			p = {}
			for key, value of Frame.Properties
				p[key] = @[key] or Frame.Properties[key]
			return p
			
		set: (args) ->
			
			for key, value of Frame.Properties
				@[key] = args[key] if args[key]
			
			for key, value of Frame.CalculatedProperties
				@[key] = args[key] if args[key] not in [null, undefined]

	@define "minX"
		get: -> @x
		set: (value) ->  @x = value

	@define "midX"
		get: -> @x + (@width / 2.0)
		set: (value) ->
			throw Error "Width is zero" if @width is 0
			@x = value - (@width / 2.0)

	@define "maxX"
		get: -> @x + @width
		set: (value) -> 
			throw Error "Width is zero" if @width is 0
			@x = value - @width

	@define "minY"
		get: -> @y
		set: (value) -> @y = value

	@define "midY"
		get: -> @y + (@height / 2.0)
		set: (value) ->
			throw Error "Width is zero" if @height is 0
			@y = value - (@height / 2.0)

	@define "maxY"
		get: -> @y + @height
		set: (value) -> 
			throw Error "Width is zero" if @height is 0
			@y = value - @height


Frame.Properties =
	x: 0
	y: 0
	width: 0
	height: 0

Frame.CalculatedProperties =
	minX: null
	midX: null
	maxX: null
	minY: null
	midY: null
	maxY: null

exports.Frame = Frame