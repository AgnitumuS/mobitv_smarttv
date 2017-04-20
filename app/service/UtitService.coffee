pateco.UtitService =
  pageHide : (name)->
    $(name).removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(name).hide()
    , 1000)

  handleAppResume : (status)->
    switch status
      when 0
        if pateco.platform is 'tv_tizen'
          webapis.avplay.suspend();
        console.info 'app hidden'
      when 1
        if pateco.platform is 'tv_tizen'
          if pateco.config.state is 'player'
            webapis.avplay.restore();
        return

  disconnectionCallback : ()->
    console.log 'disconnection callback'

  checkConnect : ()->
    console.log 'retry connect'
    self = pateco.UtitService
    doneCheckVersion = (error, result)->
      if error
        self.handleDisconnect()
        return
      try
        if pateco._player.video.getState() in ['PAUSE'] and pateco.config.state is 'player'
          pateco._player.video.play()
        self.disconnectionCallback()
      catch e
    pateco.ApiService.getVersion(doneCheckVersion)

  handleDisconnect : ()->
    console.log 'disconnect'
    self = pateco.UtitService
    try
      if pateco._player.video.getState() in ['PLAY']
        pateco._player.video.pause()
    catch e

    pateco._error.initPage({
      onReturn : pateco.config.exit
      description : 'connect-internet-error'
      title : 'notification'
      buttons : [
        title : 'button-try-again'
        callback : self.checkConnect
      ,
        title : 'exit'
        callback : pateco.config.exit
      ]
    })

  initPage : (page)->
    unless pateco[page]
      console.warn "This #{page} is not exits!"
      return

    if _.isFunction pateco[page].initPage()
      return pateco[page].initPage()

  onImageError : (element) ->
    img = "#{pateco.server}images/imgholder.png"
    element.src = img
    true

  onImageLoad : (element) ->
    return if $(element).data().originurl is ''
    originImg = $(element).data().originurl
    holderImg = "#{pateco.server}images/imgholder.png"
    img = new Image
    img.onload = ()->
      $(element).data().originurl = ''
      console.log 'done'
      element.src = originImg

    img.onerror = ()->
      $(element).data().originurl = ''
      element.src = holderImg

    img.src = originImg
    #    console.log img
    true

  loadImage : (url, done)->
    return if url is undefined
    newImg = new Image;
    onLoadSuccess = ()->
      console.log 'load image done'
      done()
    imageNotFound = ()->
      console.log 'can not load image with url', url
      done()

    newImg.onerror = imageNotFound;
    newImg.onload = onLoadSuccess
    newImg.src = url

  convertObjToArr : (obj)->
    $.map obj, (el) ->
      el

  coverNumber : (int)->
    int = int / 1000
    int = int.toFixed(3)
    int = '0' if int <= 0
    return int

  formatTicket : (params)->
    data = {}
    _.map params, (item)->
      data[item.service] = item.ticket
    return data

  updateActive : (list, index, child)->
    $(list).children(child).removeClass("active")
    nextActiveButton = $(list).children(child).get(index)
    $(nextActiveButton).addClass("active")
    return

  currency : (params = {})->
    return 0 unless params
    return 0 unless params.value
    thousandSeparator = if params.thousandSeparator then params.thousandSeparator else '.'
    decimalSeparator = if params.decimalSeparator then params.decimalSeparator else ','
    decimalPrecision = if params.decimalPrecision then params.decimalPrecision else 0
    prefix = if params.prefix then params.prefix else ''
    suffix = if params.suffix then params.suffix else 'Đ'
    displayType = if params.displayType then params.displayType else 'text'
    n = Math.abs(Math.ceil(params.value)).toString()
    i = n.length % 3
    f = n.substr(0, i)
    if(params.value < 0)
      f = '-' + f
    while i < n.length
      if(i != 0)
        f += thousandSeparator
      f += n.substr(i, 3)
      i += 3
    if(decimalPrecision > 0)
      f += decimalSeparator + params.value.toFixed(decimalPrecision).split('.')[1]
    if displayType is 'text'
      return prefix + f + suffix
    return f

  setFlashScreenWelcome : ()->
    window.localStorage.flashScreenWelcome = true
  getFlashScreenWelcome : ()->
    return true if window.localStorage.flashScreenWelcome is 'true'
    return false
