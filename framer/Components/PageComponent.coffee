{Events} = require "../Events"
{ScrollComponent} = require "./ScrollComponent"

"""
PageComponent

originX <number>
originY <number>

velocityThreshold <number>
animationOptions <animationOptions={}>
currentPage <Layer>
closestPage(<originX:n, originY:n>) <Layer>

nextPage(direction="", currentPage)
snapToNextPage(direction="", animate, animationOptions={})

"""

class exports.PageComponent extends ScrollComponent

	@define "originX", @simpleProperty("originX", .5)
	@define "originY", @simpleProperty("originY", .5)
	@define "velocityThreshold", @simpleProperty("velocityThreshold", 0.1)
	@define "animationOptions", @simpleProperty("animationOptions", {curve:"spring(500,50,0)"})
	@define "currentPage", 
		importable: false
		exportable: false
		get: -> @closestPage

	constructor: ->
		super

		@content.draggable.momentum = false
		@content.draggable.bounce = false

		@on(Events.ScrollStart, @_scrollStart)
		@on(Events.ScrollEnd, @_scrollEnd)

		@content.on("change:frame", _.debounce(@_scrollMove, 16))
		@_content.on "change:subLayers", => 
			@_currentPage = @closestPage
			@_previousPages = []

		@_currentPage = null
		@_previousPages = []

	@define "closestPage",  get: -> @closestContentLayerForScrollPoint(@_originScrollPoint(), @originX, @originY)
	@define "previousPage", get: -> @_previousPages[@_previousPages.length-2]

	nextPage: (direction="right", currentPage=null) ->

		currentPage ?= @currentPage

		# Figure out the point from where to look for next layers in a direction
		point = {x:0, y:0}
		point = Utils.framePointForOrigin(currentPage, @originX, @originY) if currentPage

		layers = @contentLayersAbove(point) if direction is "up"
		layers = @contentLayersRight(point) if direction is "right"
		layers = @contentLayersBelow(point) if direction is "down"
		layers = @contentLayersLeft(point) if direction is "left"

		# See if there is one close by that we should go to
		layers = _.without(layers, currentPage)
		layers = Utils.frameSortByAbsoluteDistance(point, layers, @originX, @originY)
		
		return _.first(layers)

	snapToPage: (page, animate=true, animationOptions=null) ->
		@scrollToLayer(page, @originX, @originY, true, animationOptions)

	snapToNextPage: (direction="right", animate=true, animationOptions=null) ->
		animationOptions ?= @animationOptions
		nextPage  = @nextPage(direction)
		nextPage ?= @closestPage
		@snapToPage(nextPage, animate, animationOptions)

	snapToPreviousPage: ->
		return unless @previousPage
		@snapToPage(@previousPage)
		@_previousPages = @_previousPages[0..@_previousPages.length-2]

	addPage: (page, direction="right") ->

		# We only allow adding pages to the right and bottom for now, because it shouldn't
		# be hard to insert them in the right order, and if we need to manage that for you
		# we'd have to change the position of every content layer so the new page fits.
		# Ergo: too much magic.
		directions = ["right", "bottom"]

		if not direction in directions
			direction = "right"
			throw new Error("#{direction} should be in #{directions}")

		point = {x:0, y:0}

		if @content.subLayers.length
			point.x = Utils.frameGetMaxX(@content.contentFrame()) if direction == "right"
			point.y = Utils.frameGetMaxY(@content.contentFrame()) if direction == "bottom"

		page.point = point
		page.superLayer = @content

	_scrollStart: =>
		@_currentPage = @currentPage

	_scrollMove: =>

		currentPage = @currentPage

		if currentPage not in [_.last(@_previousPages), undefined]
			@_previousPages.push(currentPage)
			@emit("change:currentPage", {old:@previousPage, new:currentPage})

	_scrollEnd: =>

		if not @content.draggable.isDragging
			return

		velocity = @content.draggable.velocity

		# See if we meet the minimum velocity to scroll to the next page. If not we snap
		# to the layer closest to the scroll point.
		if Math.max(Math.abs(velocity.x), Math.abs(velocity.y)) < @velocityThreshold
			@scrollToClosestLayer(@originX, @originY, true, @animationOptions)
			return 

		# Figure out which direction we are scrolling to and make a sorted list of
		# layers on that side, sorted by absolute distance so we can pick the first.
		nextPage = @nextPage(@direction, @_currentPage)

		# print Math.max(Math.abs(velocity.x), Math.abs(velocity.y))
		# print @direction, layer

		# If not, we scroll to the closest layer that we have available, often the one
		# that we are already at.
		nextPage ?= @closestPage
		@snapToPage(nextPage, true, @animationOptions)

	_originScrollPoint: ->
		scrollPoint = @scrollPoint
		scrollPoint.x += @width * @originX
		scrollPoint.y += @height * @originY
		return scrollPoint

	##############################################################
	# Page indicator TODO

	# createPageIndicator: ->
	# updatePageIndicator: (currentPage) ->
