_ = require "underscore"
utils = require "../utils"

# CSSMatrix = require "CSSMatrix"

EmptyMatrix = new WebKitCSSMatrix()

class Matrix
	
	constructor: (matrix) ->
		
		if matrix instanceof WebKitCSSMatrix
			@from matrix
	
	@define "x",
		get: -> @_x or 0
		set: (value) -> @_x = value

	@define "y",
		get: -> @_y or 0
		set: (value) -> @_y = value
	
	@define "z",
		get: -> @_z or 0
		set: (value) -> @_z = value


	@define "scaleX",
		get: -> @_scaleX or 1
		set: (value) -> @_scaleX = value
	
	@define "scaleY",
		get: -> @_scaleY or 1
		set: (value) -> @_scaleY = value
	
	@define "scaleZ",
		get: -> @_scaleZ or 1
		set: (value) -> @_scaleZ = value

	@define "scale",
		get: -> (@_scaleX + @_scaleY) / 2.0
		set: (value) -> @_scaleX = @_scaleY = value


	@define "rotationX",
		get: -> @_rotationX or 0
		set: (value) -> @_rotationX = value
	
	@define "rotationY",
		get: -> @_rotationY or 0
		set: (value) ->
			@_rotationY = value
	
	@define "rotationZ",
		get: -> @_rotationZ or 0
		set: (value) -> 
			@_rotationZ = value
	
	@define "rotation",
		get: -> @rotationZ
		set: (value) -> 
			@rotationZ = value

	decompose: (m) ->
		
		result = {}
		
		result.translation =
			x: m.m41
			y: m.m42
			z: m.m43
		
		result.scale =
			x: Math.sqrt(m.m11*m.m11 + m.m12*m.m12 + m.m13*m.m13)
			y: Math.sqrt(m.m21*m.m21 + m.m22*m.m22 + m.m23*m.m23)
			z: Math.sqrt(m.m31*m.m31 + m.m32*m.m32 + m.m33*m.m33)
		
		# http://blog.bwhiting.co.uk/?p=26
		# Todo: There is still a bug here, where it sometimes rotations in reverse
		result.rotation =
			x: -Math.atan2(m.m32/result.scale.z, m.m33/result.scale.z)
			y: Math.asin(m.m31/result.scale.z)
			z: -Math.atan2(m.m21/result.scale.y, m.m11/result.scale.x)
		
		return result
		
		# Requires: https://raw.github.com/joelambert/morf/master/
		#	js/src/WebkitCSSMatrix.ext.js
		#
		# d = m.decompose()
		# 
		# result = {}
		# 
		# result =
		# 	translation: d.translate
		# 	scale: d.scale
		# 	rotation: d.rotation
		# 
		# return result
		
	
	from: (matrix) ->
		
		v = @decompose matrix
		
		@x = v.translation.x
		@y = v.translation.y
		
		@scaleX = v.scale.x
		@scaleY = v.scale.y
		@scaleZ = v.scale.z
		
		@rotationX = v.rotation.x / Math.PI * 180
		@rotationY = v.rotation.y / Math.PI * 180
		@rotationZ = v.rotation.z / Math.PI * 180
		
	
	# matrix: ->
	# 	m = new WebKitCSSMatrix()
	# 	m = m.translate @_x, @_y, @_z
	# 	m = m.rotate @_rotationX, @_rotationY, @_rotationZ
	# 	# m = m.rotate @_rotationX, 0, 0
	# 	# m = m.rotate 0, @_rotationY, 0
	# 	# m = m.rotate 0, 0, @_rotationZ
	# 	m = m.scale @scaleX, @scaleY, @scaleZ
	# 	
	# 	return m
	
	set: (view) ->
		view._matrix = @
	
	css: ->
		m = EmptyMatrix
		
		m = m.translate @_x, @_y, @_z
		m = m.rotate @_rotationX, @_rotationY, @_rotationZ
		m = m.scale @_scaleX, @_scaleY, @_scaleZ
		
		return m.toString()


exports.Matrix = Matrix