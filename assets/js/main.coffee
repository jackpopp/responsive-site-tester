address = null
height = null
width = null

heightArray = []
widthArray = []

mainViewport = null
requestAddress = 'request.php?uri='

browse = (address) ->
	$('.iframe-preloader').each -> $(this).removeClass('hide')

	# make sure it has a fully qualified domain
	patternOne = new RegExp("http://")
	patternTwo = new RegExp("https://")
	address = 'http://'+address if not patternOne.test(address) or patternTwo.test(address)

	# remove hash if the last value is a hash
	patternThree = new RegExp(/\/#/)
	address = address.replace(/\/#/, "") while patternThree.test(address)
	address = address.replace(/<script>/g, '<>')
	address = address.replace(/<\/script>/g, '</>')
	$('#address').val(address)

	# if the height and length array count in 1 then we only need to build a single one
	index = 0
	$('.viewport').each ->
		iframe = $(this).find('iframe')
		iframe.attr('src', "#{requestAddress}#{address}/&index=#{index}")
		iframe.css { height: $(this).find('.height').val(), width: $(this).find('.width').val() }
		$(this).find('.iframe-preloader').css { height: $(this).find('.height').val(), width: $(this).find('.width').val() }
		index++

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
addViewport = (setNewHeights = false)->
	newViewport = mainViewport.clone()
	$('.main-container').append(newViewport)

	# if set new neights is true then they have added a new view port and it is not one generated from the query string
	# so we need to check what dropdown is chosen and add the info to the arrays
	if setNewHeights

		#update the heigth and width of the new viewport
		string = $('#size-selector').val()
		heightWidth = string.split('|')

		newViewport.find('.height').val(heightWidth[0])
		newViewport.find('.width').val(heightWidth[1])
		newViewport.find('iframe').css {height: heightWidth[0], width: heightWidth[1] }
		newViewport.find('.iframe-preloader').css {height: heightWidth[0], width: heightWidth[1] }

		heightArray.push heightWidth[0]
		widthArray.push heightWidth[1]
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

removeViewport = (viewport) ->
	# check how many view ports needs at least one.
	if $('.viewport').length > 1
		viewport.remove()
		generateQueryString()
	else
		alert 'Cant remove all viewports'
	return

# Called by the iframe when it has finished being loaded in	

window.finishedLoad = (index) ->
	$('.viewport').eq(index).find('.iframe-preloader').addClass('hide')

	# make all pages scroll to top by default
	setTimeout( 
		->
			$('iframe').each -> $(this).contents().find('body').scrollTop(0)
		500
	)
	return

$ ->
	mainViewport = $('.viewport').eq(0)
	setDefaults()
	$('#submit').click -> browse($('#address').val())
	$('#new').click -> addViewport(true)
	$('body').on 'click', '.remove', -> removeViewport($(this).parent().parent())

	$(window).on 'click', 'a', -> console.log this