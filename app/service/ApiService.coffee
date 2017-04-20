fimplus.ApiService =
  callback  : ()->
    console.log 'callback'
  commonData: ()->
    data =
      platform    : fimplus.config.platform
      uuid        : fimplus.config.appInfo.deviceId
      macAddress  : fimplus.config.appInfo.macAddress
      modelId     : fimplus.config.appInfo.modelId
      modelName   : fimplus.config.appInfo.modelName
      device_model: fimplus.config.appInfo.modelName
      serialId    : fimplus.config.appInfo.serialId
      mode4k      : fimplus.config.appInfo.model4K
    return data
  
  checkToken: (url)->
    if url.indexOf(fimplus.config.api.cm) is 0 or url.indexOf(fimplus.config.api.ubs) is 0
      return localStorage.hd1_cm
    if url.indexOf(fimplus.config.api.payment) is 0
      return localStorage.hd1_payment
    if url.indexOf(fimplus.config.api.billing) is 0
      return localStorage.hd1_billing
    if url.indexOf(fimplus.config.api.cas) is 0
      return localStorage.hd1_cas

  showPopup: ()->
    backHome = ()->
      fimplus._page.initPage()
    login = ()->
      fimplus._login.initPage(()->
        fimplus._page.initPage()
      )
    fimplus._error.initPage({
      title      : "register-fail"
      onReturn   : backHome
      description: 'account-authentication'
      buttons    : [
        title   : 'button-cancel'
        callback: backHome
      ,
        title   : 'button-accept'
        callback: login
      ]
    });

  requestSuccess: (done, req)->
    self = fimplus.ApiService
    if done is undefined
      console.log 'unknow callback'
      self.callback() if _.isFunction(self.callback)
      return
    done null, req
  
  requestError: (done, error)->
    clearStorage = ()->
      delete window.localStorage.hd1_billing
      delete window.localStorage.hd1_cm
      delete window.localStorage.hd1_cas
      delete window.localStorage.hd1_payment
      delete window.localStorage.user_info
#      window.location.reload()
    
    console.error 'requestError', error
    if error.status is 403 and error.responseJSON
      if error.responseJSON.message and error.responseJSON.message.indexOf("Unauthorized") != -1
        fimplus.ApiService.showPopup()
        clearStorage()
        return
#        return done(true, error)
    done true, error
  
  request: (options, done)->
    self = @
    self.callback = ()->
      console.log 'callback'
    self.callback = done if _.isFunction(done)
    
    options.headers = options.headers or {}
    options.data = _.extend _.clone(@commonData()), options.data
    if options.method is 'GET'
      options.url = options.url + "?" + $.param(options.data)
      delete options.data
    
    if(fimplus.UserService.isLogin() or options.headers.Authorization is undefined )
      headers =
        'Authorization': @checkToken(options.url)
      options.headers = _.extend headers, options.headers
    #    console.log 'f', options.headers
    options.headers['Accept-Language'] = fimplus.UserService.getValueStorage('userSettings', 'language')
    options.success = @requestSuccess.bind(@, done)
    options.error = @requestError.bind(@, done)
    #    options.complete = @requestComplete.bind(@, done)
    $.ajax(options)
  
  getPage: (pageId, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cm}page/#{pageId}"
      method: 'GET'
      data  :
        imageSize: '2x'
    @request options, done
  
  getHome: (done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cm}home"
      method: 'GET'
      data  :
        imageSize: '2x',
    @request options, done
  
  getMenu: (done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cm}menu"
      method: 'GET'
      data  : {}
    @request options, done
  
  getRibbonDetail: (params, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params = params or
      limit: 12
      page : 0
    
    options =
      url   : "#{fimplus.config.api.cm}menu/#{params.id}"
      method: 'GET'
      data  : params
    @request options, done
  
  getPackage: (ids = [], done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      menuIdList: JSON.stringify ids
    options =
      url   : "#{fimplus.config.api.cm}custom/page/phim-goi"
      method: 'GET'
      data  : params
    @request options, done
  
  getPaymentMethod: (allowMethod, env, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      version: "1.0"
      env    : env
      exclude: allowMethod
    options =
      url   : "#{fimplus.config.api.payment}method"
      method: 'GET'
      data  : params
    @request options, done
  
  getEntityDetail: (id, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      imageSize: "2x"
    options =
      url   : "#{fimplus.config.api.cm}movie/#{id}"
      method: 'GET'
      data  : params
    @request options, done
  
  search: (keyword, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      page     : 0
      limit    : "40"
      imageSize: "2x"
    options =
      url   : "#{fimplus.config.api.cm}search/#{keyword}"
      method: 'GET'
      data  : params
    @request options, done
  
  loginWithPassword: (params, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cas}auth/login"
      method: 'POST'
      data  : params
    @request options, done
  
  login_hd1_payment: (ticket, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.payment}auth/login"
      method: 'POST'
      data  :
        ticket: ticket
    @request options, done
  
  login_hd1_billing: (ticket, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.billing}auth/login"
      method: 'POST'
      data  :
        ticket: ticket
    @request options, done
  
  login_hd1_cas: (ticket, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cas}auth/service/login"
      method: 'POST'
      data  :
        ticket: ticket
    @request options, done
  
  login_hd1_cm: (ticket, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cm}auth/login"
      method: 'POST'
      data  :
        ticket: ticket
    @request options, done
  
  getUserProfile: (done)->
    options =
      url   : "#{fimplus.config.api.cas}user"
      method: 'GET'
    @request options, (error, result)->
      if error
        return done error, result
      console.log result
      done error, result
  
  updateProfileLeft: (done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.billing}subscription/validmessage"
      method: 'POST'
    @request options, done
  
  loginServices: (data, done)->
    self = @
    func = {}
    _.map fimplus.config.services, (item)->
      func[item] = (cb)->
        self["login_" + item](data[item], cb)
    async.parallel(func, done)

# get notifications in user getUserProfile
  getNotification: (done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      limit: 300
      page : 0
    options =
      url   : "#{fimplus.config.api.cas}notification"
      method: 'GET'
      data  : params
    @request options, done
  
  getCodeVal: (params, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      _codeVal: params.code
      email : params.email
      phone : params.phone
    options =
      url   : "#{fimplus.config.api.billing}code"
      method: 'POST'
      data  : params
    @request options, done
  
  updateLogout: (id, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      new : "1"
      uuid: id
    options =
      url   : "#{fimplus.config.api.cas}auth/logout"
      method: 'POST'
      data  : params
    @request options, done
  
  updateFavorite: (params, done)->
    done = done or ()->
    params =
      movieId: params.movieId
      like   : params.like
    options =
      url   : "#{fimplus.config.api.ubs}favorite"
      method: 'POST'
      data  : params
    @request options, done
  
  getWatchLater: (page, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      limit: 40
      page : page
    options =
      url   : "#{fimplus.config.api.cm}user/favorites"
      method: 'GET'
      data  : params
    @request options, done
  
  registerGetCode: (params, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cas}auth/register/getcode"
      method: 'POST'
      data  : params
    @request options, done
  
  registerCheckCode: (params, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cas}auth/register/checkcode"
      method: 'POST'
      data  : params
    @request options, done
  
  registerPhone: (params, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    data =
      services: fimplus.config.services
    data = _.extend data, params
    options =
      url   : "#{fimplus.config.api.cas}auth/register/phone"
      method: 'POST'
      data  : data
    @request options, done
  
  getPackageDisplay: (id, url, done) ->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.billing}#{url}"
      method: 'GET'
      data  :
        movieId: id
    @request options, done
  
  getListCode: (done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.billing}bCodes/user/"
      method: 'GET'
    @request options, done
  
  
  initSessionPlay: (movieId, done)->
    self = @
    params =
      url     : '/api/v1/sessions'
      method  : 'POST'
      casToken: localStorage.hd1_cas
      userId  : fimplus.UserService.getProfile().id
      movieId : movieId
    @sessionPlayManager(params, done)
  
  sessionPlayManager: (params, done)->
    done = done or ()->
    options =
      url   : "#{fimplus.config.api.cas}ssmanager"
      method: 'POST'
      data  : params
    @request options, done
  
  getFirstEpisode: (id, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cm}episode/first/#{id}"
      method: 'GET'
    @request options, (error, result)->
      if error
        return done(error, result)
      done(error, result.firstId)
  
  getSeasons: (params, done)->
    done = done or ()->
    options =
      url   : "#{fimplus.config.api.cm}season/#{params.movieId}"
      method: 'GET'
      data  : params
    @request options, done
  
  getEpisodes: (params, done)->
    done = done or ()->
    options =
      url   : "#{fimplus.config.api.cm}episode/#{params.seasonId}"
      method: 'GET'
      data  : params
    @request options, done
  
  getPlayList: (params = {}, done)->
#    params =
#      id           : id // movieID
#      sessionPlayId: sessionPlayId
#      tokenPairing : tokenPairing
    params.raw = 1
    browser = fimplus.config.browser
    
    if  browser.name is 'safari' and fimplus.config.platform is 'web'
      params.platform = 'web_safari'
    options =
      url   : "#{fimplus.config.api.cm}playlist/#{params.id}"
      method: 'GET'
      data  : params
    if params.tokenPairing
      options.headers =
        Authorization: params.tokenPairing
      console.log 'pairing', options.headers
    @request options, (error, result)->
      if error
        return done(error, result)
      result.sessionPlayId = params.sessionPlayId
      done(error, result)
  
  updateCreditcard: (token, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      type : "CCSTRIPE"
      token: token
    options =
      url   : "#{fimplus.config.api.payment}creditcard/sync"
      method: 'POST'
      data  : params
    @request options, done
  
  getVerifyCode: (code, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.billing}bCodes/#{code}"
      method: 'GET'
    @request options, done
  
  getbCodeActive: (code, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.billing}bCodes/#{code}/active/"
      method: 'GET'
    @request options, done
  
  getPaymentMobileCard: (env, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      version: "1.0"
      env    : env
    options =
      url   : "#{fimplus.config.api.payment}telco"
      method: 'GET'
      data  : params
    @request options, done
  
  updatePaymentMobileCard: (cardSeries, cardNumber, telcoCode, env, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      cardId   : cardSeries
      cardCode : cardNumber
      telcoCode: telcoCode
      env      : env
    options =
      url   : "#{fimplus.config.api.payment}wallet/deposit"
      method: 'POST'
      data  : params
    @request options, done
  
  getWallet: (env, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      version: "1.0"
      env    : env
    options =
      url   : "#{fimplus.config.api.payment}wallet"
      method: 'GET'
      data  : params
    @request options, done
  
  updateWalletSubscription: (params, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.billing}subscription/confirmmessage"
      method: 'POST'
      data  : params
    @request options, done
  
  updatePaymentConfirm: (packageId, sourceId, redeemCode, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    params =
      packageId : packageId
      sourceId  : sourceId
      redeemCode: redeemCode
    options =
      url   : "#{fimplus.config.api.billing}subscription/confirmmessage"
      method: 'POST'
      data  : params
    @request options, done
  
  buyPackage: (params, done)->
    done = done or ()->
    params = params or {}
    options =
      url   : "#{fimplus.config.api.billing}subscription/buyPackage"
      method: 'POST'
      data  : params
    @request options, done
  
  getTrailer: (id, done)->
    browser = fimplus.config.browser
    if  browser.name is 'safari' and fimplus.config.env is 'web'
      params.platform = 'web_safari'
    options =
      url   : "#{fimplus.config.api.cm}linkplay/#{id}"
      method: 'GET'
      data  : {}
    
    @request options, done
  
  getListFavorite: (params, done)->
    done = done or ()->
    params = params or {}
    options =
      url   : "#{fimplus.config.api.cm}user/favorites"
      method: 'GET'
      data  : params
    @request options, done
  getListRecent  : (params, done)->
    done = done or ()->
    params = params or {}
    options =
      url   : "#{fimplus.config.api.cm}user/recents"
      method: 'GET'
      data  : params
    @request options, done
  
  getListPaid: (params, done)->
    done = done or ()->
    params = params or {}
    options =
      url   : "#{fimplus.config.api.cm}user/purchased"
      method: 'GET'
      data  : params
    @request options, done
  
  buyItem: (params, done)->
    done = done or ()->
    params = params or {}
    options =
      url   : "#{fimplus.config.api.billing}subscription/buyItem"
      method: 'POST'
      data  : params
    
    @request options, done
  
  trackProgress: (params, done)->
    done = done or (error, result)->
#        console.log 'tracking: ' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.ubs}progress"
      method: 'POST'
      data  : params
    
    @request options, done
  
  updateMovieSubscription: (done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.billing}subscription/validmessage"
      method: 'POST'
    @request options, done
  
  getSuggestionSearch: (done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.cm}promotion/tizen"
      method: 'GET'
    @request options, done

  getCurrentPackage: (userId, done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.config.api.billing}subscription/getcurrentpackage"
      method: 'GET'
      data  :
        userId: userId
    @request options, done

  getVersion: (done)->
    done = done or (error, result)->
        console.log 'message :' + JSON.stringify(result)
    options =
      url   : "#{fimplus.server}version.json"
      method: 'GET'
    @request options, done
    
