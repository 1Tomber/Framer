STYLESHEET_ID = "FramerCSS"

_STYLESHEET = null

exports.addStyle = (css) ->
	
	# styleSheet = document.getElementById STYLESHEET_ID
	# 
	# if not styleSheet
	# 		
	# 	head = document.getElementsByTagName "head"
	# 	head = head[0] if head
	# 
	# 	if not head
	# 		head = document.body or document.documentElement
	# 
	# 	styleSheet = document.createElement "style"
	# 	styleSheet.id = STYLESHEET_ID
	# 	
	# 	head.appendChild styleSheet
	# 
	# styleSheet.appendChild document.createTextNode css
	
	# if _STYLESHEET is null
	_STYLESHEET = document.createElement('style');
	document.head.appendChild(_STYLESHEET);
	
	_STYLESHEET.innerHTML += css
	
	# style = document.createElement('style');
	# style.innerHTML = css

	


exports.addStyle "
.uilayer {
	display: block;
	visibility: visible;
	position: absolute;
	top:auto; right:auto; bottom:auto; left:auto;
	width:auto; height:auto;
	overflow: visible;
	z-index:0;
	opacity:1;
	box-sizing: border-box;
	-webkit-box-sizing: border-box;
}
.uilayer.textureBacked {
	-webkit-transform: matrix3d(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1);
	-webkit-transform-origin: 50% 50% 0%;
	-webkit-backface-visibility: hidden;
	-webkit-transform-style: flat;
}
.uilayer.animated {
	-webkit-transition-duration: 500ms;
	-webkit-transition-timing-function: linear;
	-webkit-transition-delay: 0;
	-webkit-transition-property: none;
}"