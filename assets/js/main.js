// Generated by CoffeeScript 1.6.2
(function() {
  var addViewport, address, browse, generateQueryString, getParameterByName, height, heightArray, mainViewport, removeViewport, requestAddress, resetSizeArrays, setDefaults, width, widthArray;

  address = null;

  height = null;

  width = null;

  heightArray = [];

  widthArray = [];

  mainViewport = null;

  requestAddress = 'request.php?uri=';

  browse = function(address) {
    var index, patternOne, patternThree, patternTwo;

    $('.iframe-preloader').each(function() {
      return $(this).removeClass('hide');
    });
    patternOne = new RegExp("http://");
    patternTwo = new RegExp("https://");
    if (!patternOne.test(address) || patternTwo.test(address)) {
      address = 'http://' + address;
    }
    patternThree = new RegExp(/\/#/);
    while (patternThree.test(address)) {
      address = address.replace(/\/#/, "");
    }
    address = address.replace(/<script>/g, '<>');
    address = address.replace(/<\/script>/g, '</>');
    $('#address').val(address);
    index = 0;
    $('.viewport').each(function() {
      var iframe;

      iframe = $(this).find('iframe');
      iframe.attr('src', "" + requestAddress + address + "/&index=" + index);
      iframe.css({
        height: $(this).find('.height').val(),
        width: $(this).find('.width').val()
      });
      $(this).find('.iframe-preloader').css({
        height: $(this).find('.height').val(),
        width: $(this).find('.width').val()
      });
      return index++;
    });
    $('.viewport').each(function() {
      var iframe;

      iframe = $(this).find('iframe');
      return iframe.attr('src', iframe.attr('scr'));
    });
    return generateQueryString();
  };

  getParameterByName = function(name) {
    var regex, results;

    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)");
    results = regex.exec(location.search);
    if (results === null) {
      return "";
    } else {
      return decodeURIComponent(results[1].replace(/\+/g, " "));
    }
  };

  setDefaults = function() {
    var key, num, tempOne, tempTwo, wdith, _i, _ref;

    address = getParameterByName('address');
    height = getParameterByName('height');
    width = getParameterByName('width');
    if (address !== '') {
      $('#address').val(address);
    } else {
      address = $('#address').val();
    }
    if (height !== '' && width !== '') {
      tempOne = height.split(',');
      tempTwo = width.split(',');
      if (tempOne.length === tempTwo.length) {
        heightArray = tempOne;
        widthArray = tempTwo;
      } else {
        height = mainViewport.find('.height').val();
        heightArray.push(height);
        wdith = mainViewport.find('.width').val();
        widthArray.push(width);
      }
    } else {
      height = mainViewport.find('.height').val();
      heightArray.push(height);
      width = mainViewport.find('.width').val();
      widthArray.push(width);
    }
    if (widthArray.length > 1 && heightArray.length > 1) {
      for (num = _i = 1, _ref = widthArray.length - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; num = 1 <= _ref ? ++_i : --_i) {
        addViewport();
      }
    }
    key = 0;
    $('.viewport').each(function() {
      $(this).find('.height').val(heightArray[key]);
      $(this).find('.width').val(widthArray[key]);
      return key++;
    });
    browse(address);
  };

  addViewport = function(setNewHeights) {
    var heightWidth, newViewport, string;

    if (setNewHeights == null) {
      setNewHeights = false;
    }
    newViewport = mainViewport.clone();
    $('.main-container').append(newViewport);
    if (setNewHeights) {
      string = $('#size-selector').val();
      heightWidth = string.split('|');
      newViewport.find('.height').val(heightWidth[0]);
      newViewport.find('.width').val(heightWidth[1]);
      newViewport.find('iframe').css({
        height: heightWidth[0],
        width: heightWidth[1]
      });
      newViewport.find('.iframe-preloader').css({
        height: heightWidth[0],
        width: heightWidth[1]
      });
      heightArray.push(heightWidth[0]);
      widthArray.push(heightWidth[1]);
      generateQueryString();
    }
  };

  generateQueryString = function() {
    var qs, string, uri;

    resetSizeArrays();
    uri = window.location.protocol + "//" + window.location.host + window.location.pathname;
    qs = [];
    qs.push("address=" + address);
    qs.push("width=" + (widthArray.join(',')));
    qs.push("height=" + (heightArray.join(',')));
    string = qs.join('&');
    uri = "" + uri + "?" + string;
    window.history.pushState("", "Responsive Tool", uri);
  };

  resetSizeArrays = function() {
    heightArray = [];
    widthArray = [];
    $('.viewport').each(function() {
      var iframe;

      iframe = $(this).find('iframe');
      heightArray.push($(this).find('.height').val());
      return widthArray.push($(this).find('.width').val());
    });
    address = $('#address').val();
  };

  removeViewport = function(viewport) {
    if ($('.viewport').length > 1) {
      viewport.remove();
      generateQueryString();
    } else {
      alert('Cant remove all viewports');
    }
  };

  window.finishedLoad = function(index) {
    $('.viewport').eq(index).find('.iframe-preloader').addClass('hide');
    setTimeout(function() {
      return $('iframe').each(function() {
        return $(this).contents().find('body').scrollTop(0);
      });
    }, 500);
  };

  $(function() {
    mainViewport = $('.viewport').eq(0);
    setDefaults();
    $('#submit').click(function() {
      return browse($('#address').val());
    });
    $('#new').click(function() {
      return addViewport(true);
    });
    return $('body').on('click', '.remove', function() {
      return removeViewport($(this).parent().parent());
    });
  });

}).call(this);
