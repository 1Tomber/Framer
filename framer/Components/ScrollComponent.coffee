{Layer} = require "../Layer"

"""
ScrollComponent

content <Layer>
contentOffset <{x:n, y:n}> TODO
contentSize <{width:n, height:n}>
contentInset <{top:n, right:n, bottom:n, left:n}> TODO
scrollFrame <{x:n, y:n, width:n, height:n}>
scrollPoint <{x:n, y:n}>
scrollHorizontal <bool>
scrollVertical <bool>
speedX <number>
speedY <number>
delaysContentTouches <bool> TODO
loadPreset(<"ios"|"android">) TODO
scrollToPoint(<{x:n, y:n}>, animate=true, animationOptions={})
scrollToLayer(contentLayer, originX=0, originY=0)

scrollFrameForContentLayer(<x:n, y:n>) <{x:n, y:n, width:n, height:n}> TODO
closestContentLayer(<x:n, y:n>) <Layer> TODO


ScrollComponent Events TODO

(all of the draggable events)
ScrollStart -> DragStart
ScrollWillMove -> DragWillMove
ScrollDidMove -> DragDidMove
scroll -> DragMove (html compat)
ScrollEnd -> DragEnd
"""


class exports.ScrollComponent extends Layer

	# Proxy properties directly from the draggable
	@define "velocity", @proxyProperty("content.draggable.velocity", true)
	@define "angle", @proxyProperty("content.draggable.angle", true)
	@define "scrollHorizontal", @proxyProperty("content.draggable.horizontal", true)
	@define "scrollVertical", @proxyProperty("content.draggable.vertical", true)
	@define "speedX", @proxyProperty("content.draggable.speedX", true)
	@define "speedY", @proxyProperty("content.draggable.speedY", true)

	constructor: (options) ->
		
		options.backgroundColor ?= null

		super

		@content = new Layer 
			width: @width
			height: @height
			backgroundColor: null
			superLayer:@
		@content.draggable.enabled = true
		@content.draggable.momentum = true
		@_updateContent()

		@_contentInset = {top:100, right:0, bottom:0, left:0}
		@scrollWheelSpeedMultiplier = 0.10

		@content.on("change:subLayers", @_updateContent)
		@on("mousewheel", @_onMouseWheel)

	_updateContent: =>

		# TODO: contentInset
		# TODO: contentOffset

		contentFrame = @content.contentFrame()
		contentFrame.width  = @width  if contentFrame.width  < @width
		contentFrame.height = @height if contentFrame.height < @height
		@content.frame = contentFrame

		@content.draggable.constraints =
			x: -contentFrame.width  + @width
			y: -contentFrame.height + @height
			width: 	contentFrame.width  + contentFrame.width  - @width
			height: contentFrame.height + contentFrame.height - @height

	_onMouseWheel: (event) =>

		# TODO: Maybe this needs to move to draggable, I'm not sure.
		# In any case this should go through the eventBuffer from draggable
		# so we get sensible velocity and angles back.

		@content.animateStop()
		
		{minX, maxX, minY, maxY} = @content.draggable._calculateConstraints(
			@content.draggable.constraints)
		
		point = 
			x: Utils.clamp(@content.x + (event.wheelDeltaX * @scrollWheelSpeedMultiplier * @speedX), minX, maxX)
			y: Utils.clamp(@content.y + (event.wheelDeltaY * @scrollWheelSpeedMultiplier * @speedY), minY, maxY)
		
		@content.draggable.emit(Events.DragWillMove, event)

		@content.point = point

		@content.draggable.emit(Events.DragMove, event)
		@content.draggable.emit(Events.DragDidMove, event)

	@define "scroll",
		exportable: true
		get: -> @scrollHorizontal is true or @scrollVertical is true
		set: (value) ->
			@content.animateStop() if value is false
			@scrollHorizontal = @scrollVertical = value

	@define "scrollX",
		get: -> -@content.x
		set: (value) -> @content.x = @_pointInConstraints({x:-value, y:0}).x

	@define "scrollY",
		get: -> -@content.y
		set: (value) -> @content.y = @_pointInConstraints({x:0, y:-value}).y 

	@define "scrollPoint",
		get: -> 
			point =
				x: @scrollX
				y: @scrollY
		set: (point) ->
			@content.animateStop()
			@content.point = @_pointInConstraints(point)

	@define "scrollFrame",
		get: ->
			rect = @scrollPoint
			rect.width = @width
			rect.height = @height
			rect

	@define "contentInset",
		get: -> @_contentInset
		set: (@_contentInset) ->
			@_updateContent()

	scrollToPoint: (point, animate=true, animationOptions={curve:"spring(500,50,0)"}) ->
		
		point = @_pointInConstraints(point)

		if animate
			point.x = -point.x if point.x
			point.y = -point.y if point.y
			animationOptions.properties = point
			@content.animate(animationOptions)
		else
			@point = point

	scrollToLayer: (contentLayer, animate=true, animationOptions={curve:"spring(500,50,0)"}) ->
		
		if contentLayer.superLayer isnt @content
			throw Error("This layer is not in the scroll component")

		# TODO: For now we can only scroll to top left. We should make that better.
		@scrollToPoint(contentLayer.point, animate, animationOptions)


	_pointInConstraints: (point) ->

		{minX, maxX, minY, maxY} = @content.draggable.
			_calculateConstraints(@content.draggable.constraints)

		point = 
			x: -Utils.clamp(-point.x, minX, maxX)
			y: -Utils.clamp(-point.y, minY, maxY)

		return point