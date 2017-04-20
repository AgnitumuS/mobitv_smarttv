pateco._playerSnapshot =
  data:
    callback    : ()->
      console.log 'callback'
    items       : {}
    listSnaps   : [0, 1, 2, 3, 4, 5, 6]
    arrPos      : []
    positionSnap: [-3, -2, -1, 0, 1, 2, 3]
    stepTrunk   : 12
    stepImage   : 10
    height      : 270
  
  render: ()->
    self = pateco._playerSnapshot
    source = Templates['module.player.snapshot']()
    template = Handlebars.compile(source);
    self.element = $('#player-wrapper .player-snapshot')
    self.data.items.listSnaps = self.data.listSnaps
    self.element.html(template(self.data.items))
    self.calcPositionSnapshot()
    self.enableSnapshot(false)
  
  initSnapshot: (snapshot)->
    self = pateco._playerSnapshot
    self.data.items = snapshot
    async.eachSeries(snapshot.data, (item, callback)->
      newImg = new Image;
      newImg.onload = () ->
        callback();
      newImg.src = item.url
    , self.render)
  
  enableSnapshot: (active = true)->
    self = pateco._playerSnapshot
    try
      snapshot = self.element.find('.preview-snap')
      if active
        snapshot.show()
      else
        snapshot.hide()
    catch e
      console.log e
  
  calcPositionSnapshot: (second = 0)->
    self = pateco._playerSnapshot
    return unless self.element
    snapshot = self.element.find('.snapshot')
    snapshot.find('.timeSnapshot').html(pateco._player.converTime(second))
    height = 270
#    if $(document).width() <=1280
#      height = 178
    #    if second > self.data.stepImage * 3
    #      snapshot.find
    self.data.arrPos = []
    _.map self.data.positionSnap, (item)->
      newItem = second + self.data.stepTrunk * item
      position = Math.floor(newItem / self.data.stepTrunk)
      currentSnap = Math.floor(newItem / (60 * self.data.stepImage))
      position = position - currentSnap * (self.data.stepImage * 60 ) / self.data.stepTrunk
      css =
        'background-position': "0 -#{height * position}px"
      self.data.arrPos.push
        currentSnap: currentSnap
        css        : css
    _.map(self.data.arrPos, (item, index)->
      snapshot.eq(index).find('.thumb').hide()
      if item.currentSnap is -1
        return
      snapshot.eq(index).find('.thumb').eq(item.currentSnap).show().css(item.css)
    )
    