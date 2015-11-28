
Session.set('registryItems', [])

@updateRegistry = ->
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

  Session.set('registryItems', [])
  Tracker.flush()
  Session.set('registryItems', registryItems)

Meteor.startup ->
  setTimeout ->
    updateRegistry()
  , 500

UI.registerHelper 'getVar', (key) -> Session.get(key)

# TODO - listen to all events and rerender with mongo; nice pattern :)



Template.registry.events
  'click .refresh' : -> updateRegistry()

  'click .create-registry' : ->
    # let's deploy this shit
    Contracts.securityRegistry.new
       data: Contracts.securityRegistry.code
       gas: 2000000
    , (err,res) ->
      if err
        alert err
      else if res.address
        Session.set 'registryAddr', res.address

  'change .set-registry' : (e) ->
    Session.set 'registryAddr', e.currentTarget.value
    setTimeout ->
      updateRegistry()
    , 500

  'click .create-security' : ->
    # the current registry is
    if securityName = prompt 'Security name? (32 chars or less)'
      amount = parseInt prompt 'How many starting coins?'
      Contracts.security.new amount, Session.get('registryAddr'), securityName,
         data: Contracts.security.code
         gas: 2000000
      , (err,res) ->
        if err
          console.log err
        else if res.address
          updateRegistry()
    else
      alert 'Cancelled'

Template.registry.helpers
  securities: ->
    _.map Session.get('registryItems'), (addr) -> Contracts.security.at(addr)