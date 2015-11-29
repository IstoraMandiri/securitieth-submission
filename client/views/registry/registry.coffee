
getRegistryAddress = -> FlowRouter.getParam('registryAddress')

getSecurities = ->
  mainRegistry = Contracts.securityRegistry.at getRegistryAddress()
  registryItems = []
  if count = mainRegistry.count().toNumber()
    for i in [count-1..0]
      registryItems.push Contracts.security.at mainRegistry.registry(i)
  return registryItems


Template.registry.events
  'click .create-security' : ->
    # the current registry is
    if securityName = prompt 'Security name? (32 chars or less)'
      amount = parseInt prompt 'How many starting coins?'
      Contracts.security.new amount, getRegistryAddress(), securityName,
         data: Contracts.security.code
         gas: 3000000
      , (err,res) ->
        if err
          console.log err
        else
          console.log 'deployed!', res
    else
      alert 'Cancelled'

# naively and inefficiently poll for data
Template.registry.onCreated ->
  @registry = new ReactiveVar();
  @securities = new ReactiveVar();
  do interval = =>
    regAddress = getRegistryAddress()
    @registry.set Contracts.securityRegistry.at regAddress
    @securities.set getSecurities()
  @handle = Meteor.setInterval interval, 2000

Template.registry.onDestroyed ->
  Meteor.clearInterval @handle

Template.registry.helpers
  registry: ->
    Template.instance().registry.get()

  securities : ->
    Template.instance().securities.get()