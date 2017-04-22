pateco.ApiService =
  callback : ()->
    console.log 'callback'
  commonData : ()->
    data =
      platform : pateco.config.platform
      env : pateco.config.env
      uuid : pateco.config.appInfo.deviceId
      macAddress : pateco.config.appInfo.macAddress
      modelId : pateco.config.appInfo.modelId
      modelName : pateco.config.appInfo.modelName
      device_model : pateco.config.appInfo.modelName
      serialId : pateco.config.appInfo.serialId
    return data

  getToken : ()->
    return localStorage.user_token
  checkToken : (url)->
    return localStorage.user_token
  requestSuccess : (done, req)->
    self = pateco.ApiService
    if done is undefined
      console.log 'unknow callback'
      self.callback() if _.isFunction(self.callback)
      return
    done null, req

  requestError : (done, error)->
    clearStorage = ()->
      delete window.localStorage.hd1_billing
      delete window.localStorage.hd1_cm
      delete window.localStorage.hd1_cas
      delete window.localStorage.hd1_payment
      delete window.localStorage.user_info

    console.error 'requestError', error
    if error.status is 403 and error.responseJSON
      if error.responseJSON.message and error.responseJSON.message.indexOf("Unauthorized") != -1
        pateco.ApiService.showPopup()
        clearStorage()
        return
    done true, error

  request : (options, done)->
    self = @
    self.callback = ()->
    self.callback = done if _.isFunction(done)
    options.headers = options.headers or {}
    options.data = _.extend _.clone(@commonData()), options.data
    if options.method is 'GET'
      options.url = options.url + "?" + $.param(options.data)
      delete options.data

    if(pateco.UserService.isLogin() or options.headers.Authorization is undefined )
      headers =
        'Authorization' : @getToken()
      options.headers = _.extend headers, options.headers
    options.headers['Accept-Language'] = pateco.UserService.getValueStorage('userSettings', 'language')
    options.success = @requestSuccess.bind(@, done)
    options.error = @requestError.bind(@, done)
    $.ajax(options)


  getUserProfile : (done)->
    options =
      url : "#{pateco.config.api.cm}user"
      method : 'GET'
    @request options, done

  updateUserProfile : (params, done)->
    options =
      url : "#{pateco.config.api.cm}user"
      method : 'PUT'
      data : params
    @request options, done

  getCategory : (done)->
    options =
      url : "#{pateco.config.api.cm}category"
      method : 'GET'
    @request options, done

  getVod : (params, done)->
    unless params.id
      return
#    param =
#      categoryId : params.id
#      offset : params.offset or 0
#      limit : params.limit or 15
    options =
      url : "#{pateco.config.api.cm}category/video"
      method : 'GET'
      date : params
    @request options, done

  getChildren : (id, done)->
    options =
      url : "#{pateco.config.api.cm}entity/#{id}/children"
      method : 'GET'
    @request options, done

  getRelative : (id, done)->
    options =
      url : "#{pateco.config.api.cm}entity/#{id}/relative"
      method : 'GET'
    @request options, done

  getCollection : (id, done)->
    options =
      url : "#{pateco.config.api.cm}collection/#{id}"
      method : 'GET'
    @request options, done

  getPlaylist : (id, originType = 'channel', done)->
    options =
      url : "#{pateco.config.api.cm}entity/#{id}/linkplay?" + $.param(@commonData())
      method : 'GET'
    request = _.extend options,
      headers :
        'authorization' : @getToken()
        'accept-language' : 'vi'
    $http(request)
    .success @requestSuccess.bind(@, done)
    .error (error)->
      done true, error

  getDetailEntity : (id, done)->
    options =
      url : "#{pateco.config.api.cm}entity/#{id}"
      method : 'GET'
    @request options, done

  getHome : (done)->
    options =
      url : "#{pateco.config.api.cm}page/home"
      method : 'GET'
      data : {type : 'slug'}
    @request options, done

  getPage : (id, done)->
    options =
      url : "#{pateco.config.api.cm}page/#{id}"
      method : 'GET'
    @request options, done

  getMenu : (id, done)->
    options =
      url : "#{pateco.config.api.cm}menu/#{id}"
      method : 'GET'
      data : {type : 'slug'}
    @request options, done

  getChannel : (params = {}, done)->
    param =
      operator : params.operator or 'MOBITV'
      limit : params.limit or 1000
      offset : params.offset or 0
    options =
      url : "#{pateco.config.api.cm}channel"
      method : 'GET'
      data : param
    @request options, done

  getPackage : (done)->
    options =
      url : "#{pateco.config.api.cm}package"
      method : 'GET'
    @request options, done

  getProgram : (params, done)->
    return unless params.channelIds
    date = new Date()
    #        timezoneOffset = date.getTimezoneOffset() * 60 #so sanh mui gio
    timezoneOffset = 0
    if params.fromTime
      params.fromTime = params.fromTime - timezoneOffset
    if params.toTime
      params.toTime = params.toTime - timezoneOffset
    options =
      url : "#{pateco.config.api.cm}channel/program"
      method : 'GET'
      data : params
    @request options, done

  getAllProgramOfChannel : (params, done)->
    return unless params.channelIds
    date = new Date()
    #        timezoneOffset = date.getTimezoneOffset()*60 # so sanh mui gio
    timezoneOffset = 0
    if params.fromTime
      params.fromTime = params.fromTime - timezoneOffset
    if params.toTime
      params.toTime = params.toTime - timezoneOffset
    options =
      url : "#{pateco.config.api.cm}channel/program"
      method : 'GET'
      data : params
    @request options, done

  getMovieDetail : (id, done)->
    options =
      url : "#{pateco.config.api.cm}video"
      method : 'POST'
      data : {videoId : id}
    @request options, done

  setFavorite : (channelId, done)->
    options =
      url : "#{pateco.config.api.cm}channel/favorite"
      method : 'POST'
      data :
        channelId : channelId
    @request options, done

  buyViaWap : (url)->
    location.href = url

  subscribe : (packageId, mobile, done)->
    options =
      url : "#{pateco.config.api.cm}package/subscribe"
      method : 'POST'
      data :
        packageId : packageId
        method : 'mobifone'
        msisdn : mobile
        redirect : location.href
    @request options, done

  detect3G : (done)->
    options =
      url : "http://amobi.tv/msisdn"
      method : 'GET'
      crossDomain : true
    options = _.extend options,
      headers :
        'authorization' : UserService.getToken()
        'accept-language' : 'vi'
    $http(options)
    .success (result)->
      if (result)
        result = result.toString().replace(/^84/, 0)
        return done null, result
      return done true, null
    .error (error)->
      done error, null

  searchMovie : (params, done)->
    options =
      url : "#{pateco.config.api.cm}search"
      method : 'GET'
      data : params
    @request options, done

  getListEntityFavorite : (params, done)->
    unless params.offset
      params.offset = 0
    unless params.limit
      params.limit = 20
    options =
      url : "#{pateco.config.api.cm}favorite"
      method : 'GET'
      data : params
    @request options, done

  updateEntityFavorite : (params, done)->
    return done(true, null) unless params.id
    params.favorite = params.favorite.toString() if params.favorite isnt undefined
    options =
      url : "#{pateco.config.api.cm}entity/#{params.id}/favorite"
      method : 'POST'
      data : params
    @request options, done

  getAudioList : (params, done)->
    params.entityType = 'radio' if params
    options =
      url : "#{pateco.config.api.cm}entity"
      method : 'GET'
      data : params
    @request options, done

  getOTP : (params, done)->
    return done(true, 'Khong co so dien thoai') unless params.mobile
    if typeof(params.isExist) == 'undefined' # = '1': forgetpass ; 0:register
      return done(true, 'Khong co param isExist')
    options =
      url : "#{pateco.config.api.cm}auth/otp"
      method : 'GET'
      data : params
    @request options, done

  checkOTP : (params, done)->
    return done(true, 'Khong co so dien thoai') unless params.mobile
    return done(true, 'Khong co otp') unless params.otp
    options =
      url : "#{pateco.config.api.cm}auth/otp"
      method : 'POST'
      data : params
    @request options, done

  forgetPassword : (params, done)->
    return done(true, 'Khong co otp_token') unless params.otp_token
    return done(true, 'Khong co password') unless params.password
    options =
      url : "#{pateco.config.api.cm}auth/password"
      method : 'PUT'
      data : params
    @request options, done

  register : (params, done)->
    return done(true, 'register Khong co otp_token') unless params.otp_token
    #otp_token, email, name, password
    options =
      url : "#{pateco.config.api.cm}auth/register"
      method : 'POST'
      data : params
    @request options, done

  login : (params, done)->
    options =
      url : "#{pateco.config.api.cm}auth/login"
      method : 'POST'
      data : params
    @request options, done

  showPopup : ()->
    backHome = ()->
      pateco._page.initPage()
    login = ()->
      pateco._login.initPage(()->
        pateco._page.initPage()
      )
    pateco._error.initPage({
      title : "register-fail"
      onReturn : backHome
      description : 'account-authentication'
      buttons : [
        title : 'button-cancel'
        callback : backHome
      ,
        title : 'button-accept'
        callback : login
      ]
    });



#  getPage : (pageId, done)->
#    done = done or (error, result)->
#    options =
#      url : "#{pateco.config.api.cm}page/#{pageId}"
#      method : 'GET'
#      data :
#        imageSize : '2x'
#    @request options, done
#
#  getHome : (done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.cm}home"
#      method : 'GET'
#      data :
#        imageSize : '2x',
#    @request options, done
#
#  getMenu : (done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.cm}menu"
#      method : 'GET'
#      data : {}
#    @request options, done
#
#  getRibbonDetail : (params, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params = params or
#      limit : 12
#      page : 0
#
#    options =
#      url : "#{pateco.config.api.cm}menu/#{params.id}"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  getPackage : (ids = [], done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      menuIdList : JSON.stringify ids
#    options =
#      url : "#{pateco.config.api.cm}custom/page/phim-goi"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  getPaymentMethod : (allowMethod, env, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      version : "1.0"
#      env : env
#      exclude : allowMethod
#    options =
#      url : "#{pateco.config.api.payment}method"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  getEntityDetail : (id, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      imageSize : "2x"
#    options =
#      url : "#{pateco.config.api.cm}movie/#{id}"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  search : (keyword, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      page : 0
#      limit : "40"
#      imageSize : "2x"
#    options =
#      url : "#{pateco.config.api.cm}search/#{keyword}"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  loginWithPassword : (params, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.cas}auth/login"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  login_hd1_payment : (ticket, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.payment}auth/login"
#      method : 'POST'
#      data :
#        ticket : ticket
#    @request options, done
#
#  login_hd1_billing : (ticket, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.billing}auth/login"
#      method : 'POST'
#      data :
#        ticket : ticket
#    @request options, done
#
#  login_hd1_cas : (ticket, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.cas}auth/service/login"
#      method : 'POST'
#      data :
#        ticket : ticket
#    @request options, done
#
#  login_hd1_cm : (ticket, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.cm}auth/login"
#      method : 'POST'
#      data :
#        ticket : ticket
#    @request options, done
#
#  getUserProfile : (done)->
#    options =
#      url : "#{pateco.config.api.cas}user"
#      method : 'GET'
#    @request options, (error, result)->
#      if error
#        return done error, result
#      console.log result
#      done error, result
#
#  updateProfileLeft : (done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.billing}subscription/validmessage"
#      method : 'POST'
#    @request options, done
#
#  loginServices : (data, done)->
#    self = @
#    func = {}
#    _.map pateco.config.services, (item)->
#      func[item] = (cb)->
#        self["login_" + item](data[item], cb)
#    async.parallel(func, done)
#
## get notifications in user getUserProfile
#  getNotification : (done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      limit : 300
#      page : 0
#    options =
#      url : "#{pateco.config.api.cas}notification"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  getCodeVal : (params, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      _codeVal : params.code
#      email : params.email
#      phone : params.phone
#    options =
#      url : "#{pateco.config.api.billing}code"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  updateLogout : (id, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      new : "1"
#      uuid : id
#    options =
#      url : "#{pateco.config.api.cas}auth/logout"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  updateFavorite : (params, done)->
#    done = done or ()->
#    params =
#      movieId : params.movieId
#      like : params.like
#    options =
#      url : "#{pateco.config.api.ubs}favorite"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  getWatchLater : (page, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      limit : 40
#      page : page
#    options =
#      url : "#{pateco.config.api.cm}user/favorites"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  registerGetCode : (params, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.cas}auth/register/getcode"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  registerCheckCode : (params, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.cas}auth/register/checkcode"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  registerPhone : (params, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    data =
#      services : pateco.config.services
#    data = _.extend data, params
#    options =
#      url : "#{pateco.config.api.cas}auth/register/phone"
#      method : 'POST'
#      data : data
#    @request options, done
#
#  getPackageDisplay : (id, url, done) ->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.billing}#{url}"
#      method : 'GET'
#      data :
#        movieId : id
#    @request options, done
#
#  getListCode : (done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.billing}bCodes/user/"
#      method : 'GET'
#    @request options, done
#
#
#  initSessionPlay : (movieId, done)->
#    self = @
#    params =
#      url : '/api/v1/sessions'
#      method : 'POST'
#      casToken : localStorage.hd1_cas
#      userId : pateco.UserService.getProfile().id
#      movieId : movieId
#    @sessionPlayManager(params, done)
#
#  sessionPlayManager : (params, done)->
#    done = done or ()->
#    options =
#      url : "#{pateco.config.api.cas}ssmanager"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  getFirstEpisode : (id, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.cm}episode/first/#{id}"
#      method : 'GET'
#    @request options, (error, result)->
#      if error
#        return done(error, result)
#      done(error, result.firstId)
#
#  getSeasons : (params, done)->
#    done = done or ()->
#    options =
#      url : "#{pateco.config.api.cm}season/#{params.movieId}"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  getEpisodes : (params, done)->
#    done = done or ()->
#    options =
#      url : "#{pateco.config.api.cm}episode/#{params.seasonId}"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  getPlayList : (params = {}, done)->
##    params =
##      id           : id // movieID
##      sessionPlayId: sessionPlayId
##      tokenPairing : tokenPairing
#    params.raw = 1
#    browser = pateco.config.browser
#
#    if  browser.name is 'safari' and pateco.config.platform is 'web'
#      params.platform = 'web_safari'
#    options =
#      url : "#{pateco.config.api.cm}playlist/#{params.id}"
#      method : 'GET'
#      data : params
#    if params.tokenPairing
#      options.headers =
#        Authorization : params.tokenPairing
#      console.log 'pairing', options.headers
#    @request options, (error, result)->
#      if error
#        return done(error, result)
#      result.sessionPlayId = params.sessionPlayId
#      done(error, result)
#
#  updateCreditcard : (token, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      type : "CCSTRIPE"
#      token : token
#    options =
#      url : "#{pateco.config.api.payment}creditcard/sync"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  getVerifyCode : (code, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.billing}bCodes/#{code}"
#      method : 'GET'
#    @request options, done
#
#  getbCodeActive : (code, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.billing}bCodes/#{code}/active/"
#      method : 'GET'
#    @request options, done
#
#  getPaymentMobileCard : (env, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      version : "1.0"
#      env : env
#    options =
#      url : "#{pateco.config.api.payment}telco"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  updatePaymentMobileCard : (cardSeries, cardNumber, telcoCode, env, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      cardId : cardSeries
#      cardCode : cardNumber
#      telcoCode : telcoCode
#      env : env
#    options =
#      url : "#{pateco.config.api.payment}wallet/deposit"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  getWallet : (env, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      version : "1.0"
#      env : env
#    options =
#      url : "#{pateco.config.api.payment}wallet"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  updateWalletSubscription : (params, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.billing}subscription/confirmmessage"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  updatePaymentConfirm : (packageId, sourceId, redeemCode, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    params =
#      packageId : packageId
#      sourceId : sourceId
#      redeemCode : redeemCode
#    options =
#      url : "#{pateco.config.api.billing}subscription/confirmmessage"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  buyPackage : (params, done)->
#    done = done or ()->
#    params = params or {}
#    options =
#      url : "#{pateco.config.api.billing}subscription/buyPackage"
#      method : 'POST'
#      data : params
#    @request options, done
#
#  getTrailer : (id, done)->
#    browser = pateco.config.browser
#    if  browser.name is 'safari' and pateco.config.env is 'web'
#      params.platform = 'web_safari'
#    options =
#      url : "#{pateco.config.api.cm}linkplay/#{id}"
#      method : 'GET'
#      data : {}
#
#    @request options, done
#
#  getListFavorite : (params, done)->
#    done = done or ()->
#    params = params or {}
#    options =
#      url : "#{pateco.config.api.cm}user/favorites"
#      method : 'GET'
#      data : params
#    @request options, done
#  getListRecent : (params, done)->
#    done = done or ()->
#    params = params or {}
#    options =
#      url : "#{pateco.config.api.cm}user/recents"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  getListPaid : (params, done)->
#    done = done or ()->
#    params = params or {}
#    options =
#      url : "#{pateco.config.api.cm}user/purchased"
#      method : 'GET'
#      data : params
#    @request options, done
#
#  buyItem : (params, done)->
#    done = done or ()->
#    params = params or {}
#    options =
#      url : "#{pateco.config.api.billing}subscription/buyItem"
#      method : 'POST'
#      data : params
#
#    @request options, done
#
#  trackProgress : (params, done)->
#    done = done or (error, result)->
##        console.log 'tracking: ' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.ubs}progress"
#      method : 'POST'
#      data : params
#
#    @request options, done
#
#  updateMovieSubscription : (done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.billing}subscription/validmessage"
#      method : 'POST'
#    @request options, done
#
#  getSuggestionSearch : (done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.cm}promotion/tizen"
#      method : 'GET'
#    @request options, done
#
#  getCurrentPackage : (userId, done)->
#    done = done or (error, result)->
#        console.log 'message :' + JSON.stringify(result)
#    options =
#      url : "#{pateco.config.api.billing}subscription/getcurrentpackage"
#      method : 'GET'
#      data :
#        userId : userId
#    @request options, done
#
  getVersion : (done)->
    done = done or (error, result)->
    options =
      url : "#{pateco.server}version.json"
      method : 'GET'
    @request options, done
    
