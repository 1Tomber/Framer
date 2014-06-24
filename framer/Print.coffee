Utils = require "./Utils"
{Session} = require "./Session"

"""

Todo:
- Better looks
- Resizable
- Live in own space on top of all Framer stuff

"""

exports.print = (args...) ->
	
	printLayer = Framer.Session.printLayer

	if not printLayer

		printLayer = new Layer
		printLayer.scrollVertical = true
		printLayer.ignoreEvents = false
		printLayer.html = ""
		printLayer.style =
			"font": "12px/1.35em Menlo"
			"color": "rgba(0,0,0,.7)"
			"padding": "8px"
			"padding-bottom": "30px"
			"border-top": "1px solid #d9d9d9"
		
		printLayer.opacity = 0.9
		printLayer.style.zIndex = 999 # Always stay on top
		printLayer.visible = true
		printLayer.backgroundColor = "white"
		# printLayer.bringToFront()

		printLayer.width = window.innerWidth
		printLayer.height = 160
		printLayer.maxY = window.innerHeight
	
	printNode = document.createElement("div")
	printNode.innerHTML = "&raquo; " + args.map(Utils.stringify).join(", ") + "<br>"
	printNode.style["-webkit-user-select"] = "text"
	printNode.style["cursor"] = "auto"
	
	printLayer._element.appendChild(printNode)

	Framer.Session.printLayer = printLayer
	
	Utils.delay 0, ->
		printLayer._element.scrollTop = printLayer._element.scrollHeight