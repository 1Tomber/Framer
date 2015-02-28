
constraintLayer = new Layer
	width:  window.innerWidth / 2
	height: window.innerHeight / 2
	clip: false
	backgroundColor: "rgba(255,0,0,.1)"

constraintLayer.center()


layer = new Layer superLayer:constraintLayer
layer.draggable.enabled = true
layer.draggable.momentum = true
layer.draggable.bounce = true
layer.draggable.constraints = constraintLayer.size
layer.draggable.overdrag = true
layer.draggable.overdragScale = 0.1

# layer.draggable.momentumOptions =
# 	friction:


# layer.draggable.on Events.DragMove, ->
# 	print layer.draggable.velocity
# 	print layer.draggable.angle