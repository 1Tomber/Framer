{_} = require "./Underscore"

Utils = require "./Utils"
{BaseClass} = require "./BaseClass"
{Config} = require "./Config"
{DOMEventManager} = require "./DOMEventManager"

###

An easy way to think of the context is a bucket of things related to a set of layers. There
is always at least one context on the screen, but often many more. For example, the device has
a special context and replaces the default one (so it renders in the screen), and the print
function uses on to draw the console.

The default context lives under Framer.DefaultContext and the current one in 
Framer.CurrentContext. You can create layers in any context by using the run function.

A context keeps track of everyting around those layers, so it can clean it up again. We use
this a lot in Framer Studio's autocomplete function. Async things like running animations and
timers get stopped too.

Contexts can live inside another context (with a layer as a parent) so you can only reload
a part of a prototype. This is mainly how device works.

Another feature is to temporarily freeze/resume a context. If you freeze it, all user event
will temporarily get blocked so in theory nothing will change in the context. You can restore
these at any time.

###

class exports.Context extends BaseClass

	@define "parent",
		get: -> @_parent

	@define "element",
		get: -> @_element

	constructor: (options={}) ->
		
		super

		options = _.defaults options,
			parent: null
			name: null

		if not options.name
			throw Error("Contexts need a name")

		@_parent = options.parent
		@_name = options.name
		
		@reset()

	reset: ->

		@_createDOMEventManager()
		@_createRootElement()

		@resetLayers()
		@resetAnimations()
		@resetTimers()
		@resetIntervals()

		@emit("reset", @)

	# destroy: ->
	# 	@reset()


	##############################################################
	# Collections

	# Layers
	@define "layers", get: -> _.clone(@_layers)
	@define "layerCounter", get: -> @_layerCounter
	
	addLayer: (layer) ->
		return if layer in @_layers
		@_layerCounter++
		@_layers.push(layer)
		
	removeLayer: (layer) ->
		@_layers = _.without(@_layers, layer)
	
	resetLayers: ->
		@_layers = []
		@_layerCounter = 0


	# Animations
	@define "animations", get: -> _.clone(@_animations)
	
	addAnimation: (animation) ->
		return if animation in @_animations
		@_animations.push(animation)
		
	removeAnimation: (animation) ->
		@_animations = _.without(@_animations, animation)
	
	resetAnimations: ->
		@stopAnimations()
		@_animations = []

	stopAnimations: ->
		return unless @_animations
		@_animations.map (animation) -> animation.stop(true)


	# Timers
	@define "timers", get: -> _.clone(@_timers)
	
	addTimer: (timer) ->
		return if timer in @_timers
		@_timers.push(timer)
		
	removeTimer: (timer) ->
		@_timers = _.without(@_timers, timer)
	
	resetTimers: ->
		@_timers.map(window.clearTimeout) if @_timers
		@_timers = []


	# Intervals
	@define "intervals", get: -> _.clone(@_intervals)
	
	addInterval: (interval) ->
		return if interval in @_intervals
		@_intervals.push(interval)
		
	removeInterval: (interval) ->
		@_intervals = _.without(@_intervals, interval)
	
	resetIntervals: ->
		@_intervals.map(window.clearInterval) if @_intervals
		@_intervals = []


	##############################################################
	# Run

	run: (fn) ->
		previousContext = Framer.CurrentContext
		Framer.CurrentContext = @
		fn()
		Framer.CurrentContext = previousContext


	##############################################################
	# Freezing

	freeze: ->

		if @_frozenEvents
			throw new Error "Context is already frozen"

		@_frozenEvents = {}

		for layer in @_layers

			layerListeners = layer.listeners()
			layerId = @_layers.indexOf(layer)
			layer.removeAllListeners()

			@_frozenEvents[layerId] = layerListeners
			
		@stopAnimations()

		# TODO: It would be nice to continue at least intervals after a resume
		@resetTimers()
		@resetIntervals()

	resume: ->

		if not @_frozenEvents
			throw new Error "Context is not frozen, cannot resume"

		for layerId, events of @_frozenEvents
			layer = @_layers[layerId]
			for eventName, listeners of events
				for listener in listeners
					layer.on(eventName, listener)

		delete @_frozenEvents


	##############################################################
	# DOM

	_createDOMEventManager: ->
		@domEventManager?.reset()
		@domEventManager = new DOMEventManager

	_destroyRootElement: ->

		if @_element?.parentNode
			@_element.parentNode.removeChild(@_element)

		if @__pendingElementAppend
			Utils.domCompleteCancel(@__pendingElementAppend)
			@__pendingElementAppend = null

		@_element = null

	_createRootElement: ->

		@_destroyRootElement()

		@_element = document.createElement("div")
		@_element.id = "FramerContextRoot-#{@_name}"
		@_element.classList.add("framerContext")

		@__pendingElementAppend = =>
			parentElement = @_parent?._element
			parentElement ?= document.body
			parentElement.appendChild(@_element)

		Utils.domComplete(@__pendingElementAppend)


	##############################################################
	# Geometry

	# Remember the context doesn't really have height. These are just a reference
	# to it's parent or document.

	@define "width", 
		get: -> 
			return @parent.width if @parent
			return window.innerWidth

	@define "height",
		get: -> 
			return @parent.height if @parent
			return window.innerHeight

	@define "frame", get: -> {x:0, y:0, width:@width, height:@height}
	@define "size",  get: -> _.pluck(@frame, ["x", "y"])
	@define "point", get: -> _.pluck(@frame, ["width", "height"])

