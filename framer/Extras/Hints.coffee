class Hints

	constructor: ->

		@_context = new Framer.Context(name:"Hints")
		@_context._element.style.zIndex = 1000000

		@_context.run =>
			Events.wrap(document).addEventListener("mousedown", @_handleDown)
			Events.wrap(document).addEventListener("mouseup", @_handleUp)
			Events.wrap(document).addEventListener("touchdown", @_handleDown)
			Events.wrap(document).addEventListener("touchup", @_handleUp)

	_handleDown: (event) =>
		@_target = event.target

	_handleUp: (event) =>

		layer = Framer.CurrentContext.layerForElement(@_target)

		# If this is a layer with interaction, we do not show any hints
		if layer and layer.shouldShowHint()
			return

		@showHints()

	showHints: ->
		context = Framer.CurrentContext
		@_context.run => _.invoke(context.rootLayers, "_showHint")

	destroy: ->
		@_context.destroy()

hints = null

exports.enable = ->
	hints ?= new Hints(Framer.CurrentContext)

exports.disable = ->
	return unless hints
	hints.destroy()
	hints = null
