address = null
height = null
width = null

heightArray = []
widthArray = []

mainViewport = null

browse = (address) ->

	# make sure it has a fully qualified domain
	patternOne = new RegExp("http://")
	patternTwo = new RegExp("https://")
	address = 'http://'+address if not patternOne.test(address) or patternTwo.test(address)

	# remove hash if the last value is a hash
	patternThree = new RegExp(/\/#/)
	address = address.replace(/\/#/, "") while patternThree.test(address)
	$('#address').val(address)

	# if the height and length array count in 1 then we only need to build a single one
	$('.viewport').each ->
		iframe = $(this).find('iframe')
		iframe.attr('src', address)
		iframe.css { height: $(this).find('.height').val(), width: $(this).find('.width').val() }

	# stops a bug where the page doesnt reload if we're on the same location as previous
	$('.viewport').each ->
		iframe = $(this).find('iframe')
		iframe.attr('src', iframe.attr('scr'))

	generateQueryString()

getParameterByName = (name) ->
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
    results = regex.exec(location.search)
    if results is null then return "" else return decodeURIComponent(results[1].replace(/\+/g, " "))

setDefaults = ->
	# get any default query string paramters
	address = getParameterByName('address') 
	height = getParameterByName('height')
	width = getParameterByName('width')

	if address isnt ''
		$('#address').val(address)
	else 
		address = $('#address').val()

	# work out the default heights and widths for all viewports
	if height isnt '' and width isnt ''
		tempOne = height.split(',')
		tempTwo = width.split(',')
		if tempOne.length == tempTwo.length
			heightArray = tempOne
			widthArray = tempTwo
		else
			height = mainViewport.find('.height').val()
			heightArray.push height
			wdith = mainViewport.find('.width').val()
			widthArray.push width
	else
		height = mainViewport.find('.height').val()
		heightArray.push height
		width = mainViewport.find('.width').val()
		widthArray.push width

	# build extra viewports
	if widthArray.length > 1 and heightArray.length > 1
		for num in [1..widthArray.length-1]
			addViewport()

	# set correct heights and widths
	key = 0
	$('.viewport').each ->
		$(this).find('.height').val(heightArray[key])
		$(this).find('.width').val(widthArray[key])
		key++

	# force a browse
	browse(address)
	return

# Adds a new viewport
addViewport = (addArray = false)->
	newViewport = mainViewport.clone()
	$('body').append(newViewport)
	if addArray
		widthArray.push newViewport.find('.width').val()
		heightArray.push newViewport.find('.height').val()
		generateQueryString()
	return

# Genreate querystring
generateQueryString = ->
	resetSizeArrays()

	uri =  window.location.protocol + "//" + window.location.host + window.location.pathname
	qs = []
	qs.push "address=#{address}"
	qs.push "width=#{widthArray.join(',')}"
	qs.push "height=#{heightArray.join(',')}"
	string = qs.join('&')
	uri = "#{uri}?#{string}"
	console.log uri

	window.history.pushState("", "Responsive Tool", uri);
	return

# reset the height and width arrays
resetSizeArrays = ->
	heightArray = []
	widthArray = []

	$('.viewport').each ->
		iframe = $(this).find('iframe')
		heightArray.push $(this).find('.height').val()
		widthArray.push $(this).find('.width').val()

	address = $('#address').val()
	return

$ ->
	mainViewport = $('.viewport').eq(0)
	setDefaults()
	$('#submit').click -> browse($('#address').val())
	$('#new').click -> addViewport(true)