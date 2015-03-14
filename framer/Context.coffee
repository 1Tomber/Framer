Utils = require "./Utils"

{_} = require "./Underscore"
{BaseClass} = require "./BaseClass"
{Config} = require "./Config"
{EventManager} = require "./EventManager"

Counter = 1

class exports.Context extends BaseClass
	
	constructor: (options={}) ->
		
		super

		Counter++

		options = _.defaults options,
			contextName: null
			parentLayer: null
			name: null

		if not options.name
			throw Error("Contexts need a name")

		@_parentLayer = options.parentLayer
		@_name = options.name

		@reset()

	reset: ->

		@eventManager?.reset()
		@eventManager = new EventManager

		@_rootElement?.parentNode?.removeChild?(@_rootElement)
		@_rootElement = @_createRootElement()

		@_delayTimers?.map (timer) -> window.clearTimeout(timer)
		@_delayIntervals?.map (timer) -> window.clearInterval(timer)

		if @_animationList
			for animation in @_animationList
				animation.stop(false)

		@_layerList = []
		@_animationList = []
		@_delayTimers = []
		@_delayIntervals = []

		@emit("reset", @)

	getRootElement: ->
		@_rootElement

	getLayers: ->
		_.clone(@_layerList)

	_createRootElement: ->

		element = document.createElement("div")
		element.id = "FramerContextRoot-#{@_name}"
		element.classList.add("framerContext")

		parentElement = @_parentLayer?._element

		Framer.Loop.once "render", ->
			parentElement ?= document.body
			parentElement.appendChild(element)

		element

	run: (f) ->
		previousContext = Framer.CurrentContext
		Framer.CurrentContext = @
		f()
		Framer.CurrentContext = previousContext

	# @define "x"
	# @define "y"

	@define "width", 
		get: -> 
			return @_parentLayer.width if @_parentLayer
			return window.innerWidth
	@define "height",
		get: -> 
			return @_parentLayer.height if @_parentLayer
			return window.innerHeight

