updateRegistry = ->
  # force a re-render of all the templates
  oldAddr = Session.get 'registryAddr'
  Session.set 'registryAddr', false
  Tracker.flush()
  Session.set 'registryAddr', oldAddr

Template.registry.events
  'click .refresh' : updateRegistry

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

Template.registry.onCreated ->

  @myEth = new ReactiveVar();

  @handle = Meteor.setInterval =>
    @myEth.set Math.round(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[0]).toNumber(), "ether") * 100) / 100
  , 2000

Template.registry.onRendered ->
  # a hacky way to make sure web3 is ready
  setTimeout ->
    updateRegistry()
  , 10

Template.registry.onDestroyed ->
  Meteor.clearInterval @handle

Template.registry.helpers
  myEth: ->
    Template.instance().myEth.get()

  registry: ->
    if registryAddr = Session.get('registryAddr')
      if Contracts.securityRegistry
        return Contracts.securityRegistry.at registryAddr

  securities : ->
    mainRegistry = Contracts.securityRegistry.at(Session.get('registryAddr'))
    registryItems = []
    count = mainRegistry.count().toNumber()
    if count
      for i in [mainRegistry.count().toNumber()-1..0]
        registryItems.push Contracts.security.at mainRegistry.registry(i)
    return registryItems
