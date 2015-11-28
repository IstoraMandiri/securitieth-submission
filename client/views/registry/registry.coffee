
Session.set('registryItems', [])

getUpdatedRegistry = ->
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
  return registryItems

@updateRegistry = ->
  registryItems = getUpdatedRegistry()
  Session.set('registryItems', [])
  Tracker.flush()
  Session.set('registryItems', registryItems)

# TODO - listen to all events and rerender with mongo; nice pattern :)

Template.registry.events
  'click .refresh' : -> updateRegistry()

  'click .create-registry' : ->
    unless title = prompt "Name Regsitry (32 chars or less)"
      alert 'tx cancelled'
      return false

    # deploy new securities contracts
    Contracts.securityRegistry.new title,
       data: Contracts.securityRegistry.code
       gas: 3000000
    , (err,res) ->
      if err
        alert err
      else if res.address
        Session.set 'registryAddr', res.address

  'change .set-registry' : (e) ->
    Session.set 'registryAddr', e.currentTarget.value
    setTimeout ->
      updateRegistry()
    , 1000

  'click .create-security' : ->
    # the current registry is
    if securityName = prompt 'Security name? (32 chars or less)'
      amount = parseInt prompt 'How many starting coins?'
      Contracts.security.new amount, Session.get('registryAddr'), securityName,
         data: Contracts.security.code
         gas: 3000000
      , (err,res) ->
        if err
          console.log err
        else if res.address
          updateRegistry()
    else
      alert 'Cancelled'


# Session.set('registryAddr', false)

Template.registry.onCreated ->

  @myEth = new ReactiveVar();

  @handle = Meteor.setInterval =>
    @myEth.set Math.round(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[0]).toNumber(), "ether") * 100) / 100
  , 2000

Template.registry.onDestroyed ->
  Meteor.clearInterval @handle

Template.registry.helpers
  myEth: ->
    Template.instance().myEth.get()

  registry: ->
    if registryAddr = Session.get('registryAddr')
      if Contracts.securityRegistry
        return Contracts.securityRegistry.at registryAddr

  securities: ->
    _.map Session.get('registryItems'), (addr) -> Contracts.security.at addr