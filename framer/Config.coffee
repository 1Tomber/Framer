Utils = require "./Utils"

FramerCSS = """
body {
	overflow: hidden;
	pointer-events: none
}

.framerContext {	
	position: absolute
	left: 0
	top: 0
	right: 0
	bottom: 0
	pointer-events: none
	overflow: hidden
	-webkit-perspective: 1000
}

.framerLayer {
	display: block;
	position: absolute;
	background-repeat: no-repeat;
	background-size: cover;
	-webkit-overflow-scrolling: touch;
	-webkit-box-sizing: border-box;
	-webkit-user-select: none;
}

"""

Utils.domComplete -> Utils.insertCSS(FramerCSS)