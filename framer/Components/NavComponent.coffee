
Utils = require "../Utils"

{Layer} = require "../Layer"

class NavComponentTransition

	constructor: (@navComponent, @layerA, @layerB) ->

	forward: (animate=true) ->

		if @layerA
			animation = @_startAnimation animate, @layerA,
				x: 0 - (@navComponent.width / 2)
				opacity: 0
			animation.onAnimationEnd =>
				@layerA.visible = false

		if @layerB
			@layerB.point =
				x: @navComponent.width
				y: 0
			@_startAnimation animate, @layerB,
				x: 0

	back: (animate=true) ->

		if @layerA
			@layerA.visible = true
			@_startAnimation animate, @layerA,
				x: 0
				opacity: 1

		if @layerB
			@_startAnimation animate, @layerB,
				x: @navComponent.width

	_startAnimation: (animate, layer, properties) ->
		if animate
			layer.animate
				properties: properties
				curve: "spring(300,35,0)"
		else
			_.extend(layer, properties)

class NavComponentAlertTransition

	constructor: (@navComponent, @layerA, @layerB) ->

	forward: (animate=true) ->

		background = @navComponent.background

		if background and @layerB
			background.placeBehind(@layerB)

		if @layerB
			@layerB.point = Align.center
			@layerB.scale = 0.8
			@layerB.opacity = 0

			@layerB.animate
				properties:
					scale: 1
					opacity: 1
				curve: "spring(800,28,0)"

		if background
			background.frame = @navComponent.frame
			background.opacity = 0
			background.visible = true

			background.animate
				properties:
					opacity: 0.5
				curve: "ease-out"
				time: 0.2

	back: (animate=true) ->

		background = @navComponent.background

		if @layerB
			@layerB.animate
				properties:
					scale: 0.8
					opacity: 0
				curve: "ease-out"
				time: 0.1

		if background
			animation = background.animate
				properties:
					opacity: 0
				curve: "ease-out"
				time: 0.1

			animation.onAnimationEnd ->
				background.visible = false

	_startAnimation: (animate, layer, properties, animationOptions) ->
		if animate
			layer.animate
				properties: properties
				curve: "spring(800,50,0)"
		else
			_.extend(layer, properties)


NavComponentLayerScrollKey = "_navComponentWrapped"

class exports.NavComponent extends Layer

	constructor: (options={}) ->

		options = _.defaults options,
			width: Screen.width
			height: Screen.height
			backgroundColor: "black"

		super options

		@_stack = []
		@_current = null

		@background = new Layer
			name: "background"
			parent: @
			size: @size
			backgroundColor: "black"
			visible: false

		@background.onTap =>
			@back()

		# Screen.onEdgeSwipeLeftEnd (e) =>
		# 	@back()

	_wrapLayer: (layer) ->

		# See if we need to wrap the layer in a scroll view

		# If we already created a scroll, we can use that one
		if layer[NavComponentLayerScrollKey]
			return layer[NavComponentLayerScrollKey]

		# If the layer size is exactly equal to the size of the NavComponent
		# we can just use it directly.
		if layer.width is @width and layer.height is @height
			return layer

		# If the layer size is smaller then the size of the NavComponent we
		# still need to add a backgound layer so it covers up the background.
		# TODO: Implement this
		if layer.width < @width and layer.height < @height
			return layer

		# If this layer is a ScrollComponent we do not have to add another one
		if layer instanceof ScrollComponent
			return layer

		layer.point = Utils.pointZero()

		scroll = ScrollComponent.wrap(layer)
		scroll.size = @size
		scroll.backgroundColor = @backgroundColor
		scroll.scrollHorizontal = layer.width > @width
		scroll.scrollVertical = layer.height > @height

		layer[NavComponentLayerScrollKey] = scroll

		return scroll

	_wrappedLayer: (layer) ->
		return null unless layer
		return layer[NavComponentLayerScrollKey] or layer

	push: (layer, TransitionType, animate, wrap) ->

		return unless layer
		return if layer is @current

		# Set the default values
		TransitionType ?= NavComponentTransition
		animate ?= if @_stack.length then true else false
		wrap ?= true

		# Make sure the layer is visible
		layer.visible = true
		layer.opacity = 1

		# Wrap the layer and set this as the parent
		wrappedLayer = layer
		wrappedLayer = @_wrapLayer(layer) if wrap
		wrappedLayer.parent = @

		transition = new TransitionType(@, @_wrappedLayer(@current), wrappedLayer)
		transition.forward(animate)

		@_stack.push({layer:layer, transition:transition})

	alert: (layer)->
		@push(layer, NavComponentAlertTransition, true, false)


	back: ->
		return unless @previous
		previous = @_stack.pop()
		previous?.transition.back()

	@define "stack",
		get: -> _.clone(@_stack)

	@define "current",
		get: -> return @_stack[@_stack.length - 1]?.layer

	@define "previous",
		get: -> return @_stack[@_stack.length - 2]?.layer
