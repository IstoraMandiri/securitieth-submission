
Session.set('registryItems', [])

updateRegistry = ->
  mainRegistry = Contracts.securityRegistry.at(Session.get('registryAddr'))
  registryItems = []
  for i in [0...100]
    securityAddress = mainRegistry.registry(i)
    if !securityAddress \
    or securityAddress is '0x0000000000000000000000000000000000000000' \
    or securityAddress is '0x'
      break
    else
      registryItems.push securityAddress
  Session.set('registryItems', registryItems)

Meteor.startup ->
  setTimeout ->
    updateRegistry()
  , 2000

UI.registerHelper 'getVar', (key) -> Session.get(key)

# TODO - listen to all events and sync with mongo; nice pattern :)

Template.explorer.events
  'click .create-registry' : ->
    # let's deploy this shit
    Contracts.securityRegistry.new
       data: Contracts.securityRegistry.code
       gas: 2000000
    , (err,res) ->
      if err
        console.log err
      else if res.address
        Session.set 'registryAddr', res.address

  'change .set-registry' : (e) ->
    Session.set 'registryAddr', e.currentTarget.value

Template.securities.helpers
  first10: ->
    console.log 'getting first 10 from', Session.get('registryItems')
    _.map Session.get('registryItems'), (addr) -> {address:addr}


Template.securities.events
  'click .create-security' : ->
    # the current registry is
    if amount = parseInt prompt 'How much starting cash?'
      Contracts.security.new amount, Session.get('registryAddr'),
         data: Contracts.security.code
         gas: 2000000
      , (err,res) ->
        if err
          console.log err
        else if res.address
          updateRegistry()


Template.security.helpers
  security: ->
    Contracts.security.at(@address)

  getLatestBalance: ->
    thisContract = Contracts.security.at(@address)
    currentState = parseInt(thisContract.currentState())
    thisContract.balances(web3.eth.accounts[0], currentState).toNumber()

  getCorporateActions: ->
    thisSecurity = Contracts.security.at(@address)
    for i in [0...parseInt(thisSecurity.currentState())]
      console.log 'ca', thisSecurity.getCorporateAction(i)


Template.security.events
  'click .add-coupon' : ->
    console.log 'howdy ho', @
    # couponContract.at(@address).corporateActions
    # somehow get corporate actions highest number
    # corpActNumber
    parentContract = Contracts.security.at(@address)
    Contracts.coupon.new @address, 2, 0, #corpActNumber
       data: Contracts.coupon.code
       gas: 2000000
       value: 2000
    , (err,res) ->
      if err
        console.log err
      else if res.address
        console.log 'created', res.address
        parentContract.addCorporateAction res.address, {gas: 2000000}, (err, res) ->
          console.log err, res



