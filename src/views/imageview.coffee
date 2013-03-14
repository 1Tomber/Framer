{View} = require "./view"

class exports.ImageView extends View
	
	constructor: (args) ->
		super
		
		# Behave like NSImage. Stretch to view size
		@style["background-repeat"] = "no-repeat"
		@style["background-size"] = "cover"
		
		@image = args.image

	@define "html"
		get: -> @_element.innerHTML
		set: (value) -> @_element.innerHTML = value

	@define "image"
		
		get: ->
			return @_image
		
		set: (value) ->

			if @_image is value
				return @emit "load", loader
			
			@_image = value
			
			loader = new Image()
			loader.name = @image
			loader.src = @image
			
			loader.onload = =>
				@style["background-image"] = "url('#{@image}')"
				@emit "load", loader
			
			loader.onerror = =>
				@emit "error", loader