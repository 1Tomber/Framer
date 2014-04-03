_ = require "underscore"

{EventEmitter} = require "../eventemitter"
{Events} = require "../primitives/events"

# Add specific events for draggable
Events.DragStart = "dragstart"
Events.DragMove = "dragmove"
Events.DragEnd = "dragend"

# Make any view draggable

class exports.Draggable extends EventEmitter

	@VelocityTimeOut = 100

	constructor: (@view) ->

		@speed = {x:1.0, y:1.0}

		@_deltas = []
		@_isDragging = false

		@attach()

	attach: -> @view.on  Events.TouchStart, @_touchStart
	remove: -> @view.off Events.TouchStart, @_touchStart

	emit: (eventName, event) ->
		# We override this to get all events both on the draggable
		# and the encapsulated view.
		@view.emit eventName, event

		super eventName, event


	calculateVelocity: ->

		if @_deltas.length < 2
			return {x:0, y:0}

		curr = @_deltas[-1..-1][0]
		prev = @_deltas[-2..-2][0]
		time = curr.t - prev.t

		# Bail out if the last move updates where a while ago
		timeSinceLastMove = (new Date().getTime() - prev.t)

		if timeSinceLastMove > @VelocityTimeOut
			return {x:0, y:0}

		velocity =
			x: (curr.x - prev.x) / time
			y: (curr.y - prev.y) / time

		velocity.x = 0 if velocity.x is Infinity
		velocity.y = 0 if velocity.y is Infinity

		velocity

	_updatePosition: (event) =>

		@emit Events.DragMove, event

		touchEvent = Events.touchEvent event

		delta =
			x: touchEvent.clientX - @_start.x
 			y: touchEvent.clientY - @_start.y

		# Correct for current drag speed
		correctedDelta =
			x: delta.x * @speed.x
			y: delta.y * @speed.y
			t: event.timeStamp

		@view.x = @_start.x + correctedDelta.x - @_offset.x
 		@view.y = @_start.y + correctedDelta.y - @_offset.y

		@_deltas.push correctedDelta

		@emit Events.DragMove, event

	_touchStart: (event) =>

		@view.animateStop()

		@_isDragging = true

		touchEvent = Events.touchEvent event

		@_start =
			x: touchEvent.clientX
			y: touchEvent.clientY

		@_offset =
			x: touchEvent.clientX - @view.x
			y: touchEvent.clientY - @view.y

		document.addEventListener Events.TouchMove, @_updatePosition
		document.addEventListener Events.TouchEnd, @_touchEnd

		@emit Events.DragStart, event

	_touchEnd: (event) =>

		@_isDragging = false

		document.removeEventListener Events.TouchMove, @_updatePosition
		document.removeEventListener Events.TouchEnd, @_touchEnd

		@emit Events.DragEnd, event

		@_deltas = []