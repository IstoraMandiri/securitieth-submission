
if Meteor.isClient
  compiled = web3.eth.compile.solidity(contractsSource)

  Session.set('registryItems', [])

  updateRegistry = ->
    mainRegistry = securityRegistryContract.at(Session.get('registryAddr'))
    registryItems = []
    for i in [0...100]
      securityAddress = mainRegistry.registry(i)
      if securityAddress is '0x0000000000000000000000000000000000000000' \
      or securityAddress is '0x'
        break
      else
        registryItems.push securityAddress
    Session.set('registryItems', registryItems)

  Meteor.startup updateRegistry

  UI.registerHelper 'getVar', (key) -> Session.get(key)

  # TODO - listen to all events and sync with mongo; nice pattern :)

  web3.eth.defaultAccount = web3.eth.accounts[0]

  Template.explorer.events
    'click .create-registry' : ->
      # let's deploy this shit
      Session.set 'loadingRegistry', true
      SecurityRegistryContract = web3.eth.contract(compiled['securityRegistry'].info.abiDefinition)
      SecurityRegistryContract.new
         data: compiled['securityRegistry'].code
         gas: 2000000
      , (err,res) ->
        if err
          console.log err
        else if res.address
          Session.set 'registryAddr', res.address

    'change .set-registry' : (e) ->
      Session.set 'registryAddr', e.currentTarget.value
      Session.set 'loadingRegistry', true

  Template.securities.helpers
    first10: ->
      console.log 'getting first 10 from', Session.get('registryItems')
      _.map Session.get('registryItems'), (addr) -> {address:addr}

  Template.securities.events
    'click .create-security' : ->
      # the current registry is
      if amount = parseInt prompt 'How much starting cash?'
        SecurityContract = web3.eth.contract(compiled['security'].info.abiDefinition)
        SecurityContract.new amount, Session.get('registryAddr'),
           data: compiled['security'].code
           gas: 2000000
        , (err,res) ->
          if err
            console.log err
          else if res.address
            updateRegistry()


  Template.security.helpers
    getBalance: ->
      console.log @address
      # console.log 'my balance is', securityContract.at(@address).balances(web3.eth.accounts[0]).toNumber()
      # securityContract.at(address)
      return {type: 'thingy'}
