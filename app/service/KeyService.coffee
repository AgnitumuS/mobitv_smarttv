pateco.KeyService =
  common :
    NUMBER : [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59]
    LEFT : 37
    UP : 38
    RIGHT : 39
    DOWN : 40
    ENTER : 13
    RETURN : 27
    ZERO : 48
    ONE : 49
    TWO : 50
    THREE : 51
    FOUR : 52
    FIVE : 53
    SIX : 54
    SEVEN : 55
    EIGHT : 56
    NINE : 57
    PAGE_UP : 190
    PAGE_DOWN : 188
    CHANNELS_LIST : 76
    A : 65
    B : 66
    C : 67
    D : 68
    BACKWARD : 227
    FORWARD : 228
    PLAY_PAUSE : 179
    STOP : 178
    DELETE : 8

  web :
    BACKWARD : 219 #[
    FORWARD : 221 #]
    PLAY : 189 #-
    PAUSE : 187 #=
    STOP : 220 #\

#  @android = _.extend @desktop, {}
  tv_tizen :
    RETURN : 10009
    PAGE_UP : 427
    PAGE_DOWN : 428
    BACKWARD : 412
    FORWARD : 417
    PLAY : 415
    PAUSE : 19
    PLAY_PAUSE : 10252
    STOP : 413

  tv_webos :
    RETURN : 461
    BACKWARD : 412
    FORWARD : 417
    PAUSE : 19
    PLAY : 415
    STOP : 413
  reCalc : (current, max)-> return Math.abs(current + max) % max

  key : ()->
    key = _.extend @common, @[pateco.config.platform]
    return key

  registeKeyTizen : ()->
    return if pateco.config.platform isnt 'tv_tizen'
    console.info 'Init Tizen Key'
    listKey = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      'MediaRewind', #412
      'MediaFastForward', #417
      'MediaPlay', #415
      'MediaPause', #19
      'MediaPlayPause', # 10252
      'MediaStop', #413
      'MediaTrackPrevious', #10232
      'MediaTrackNext', #10233
      'Info', #457
      'Search', #10225
      'ChannelList', #10073
#                    'Caption',#10221
#      'Teletext', #10200
#                    'Source','Extra','MST','Soccer','1089',
#      'ColorF0Red', #403
#      'ColorF1Green', #404
#      'ColorF2Yellow', #405
#      'ColorF3Blue', #406
#      'ChannelUp', #427
#      'ChannelDown' #428
    ]
    for key in listKey
      try
        tizen.tvinputdevice.registerKey key
      catch e
        console.warn(e)

  initDefaultKey : (keyCode)->
    key = @key()

#    switch keyCode
#      when key.RETURN
#        UtitService.back()

  initKey : (handleKey, classActiveKey, active = true)->
    self = pateco.KeyService
    nameClassActive = 'on-keycode-active'
    checkClass = $(".#{nameClassActive}")
    if checkClass
      $(".#{nameClassActive}").removeClass(nameClassActive)
    if classActiveKey
      $("#{classActiveKey}").addClass(nameClassActive)

    if active
      console.log 'init key rember'
      pateco.UtitService.disconnectionCallback = self.initKey.bind(self, handleKey, classActiveKey)
    onKeyDown = (e)->
      keyCode = e.keyCode
      self.initDefaultKey(keyCode)
      handleKey(keyCode, self.key())

    $(document).unbind 'keydown'
    .bind 'keydown', onKeyDown
