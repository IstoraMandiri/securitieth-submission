
Session.set('registryItems', [])

gasLimit = -> 3000000

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

  Session.set('registryItems', [])
  Tracker.flush()
  Session.set('registryItems', registryItems)

Meteor.startup ->
  setTimeout ->
    updateRegistry()
  , 500

UI.registerHelper 'getVar', (key) -> Session.get(key)

# TODO - listen to all events and rerender with mongo; nice pattern :)

Template.explorer.events
  'click .refresh' : -> updateRegistry()

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
    setTimeout ->
      updateRegistry()
    , 500


Template.securities.helpers
  securities: ->
    _.map Session.get('registryItems'), (addr) -> {address:addr}

Template.securities.events
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

corporateActions = [
  key:'coupon'
  name: 'Create Coupon'
  description: 'Contract is funded with ether to pay the coupon'
  funded: true
,
  key:'dividend'
  name: 'Create Dividend'
  description: 'Contract is funded with ether to out a dividend'
  funded: true
,
  key:'proxyVote'
  name: 'Start Proxy Vote'
  description: 'Voting contract tallies votes of share holders'
  funded: false
,
  key:'redemption'
  name: 'Allow Redemption'
  description: 'Contract is funded with ether to pay the redemption'
  funded: true
,
  key:'spinOff'
  name: 'Create Spin Off Company'
  description: 'Credits users with a certain number of new shares in a new company'
  funded: false
,
  key:'stockSplit'
  name: 'Allow Stock Split'
  description: 'Stock splits increase the number of shares in existence (ie for evry 1 share you own you get three new shares)'
  funded: false
]

Template.security.helpers
  availableActions : corporateActions

  security: ->
    Contracts.security.at(@address)

  getLatestBalance: ->
    thisContract = Contracts.security.at(@address)
    currentState = parseInt(thisContract.currentState())
    thisContract.balances(web3.eth.accounts[0]).toNumber()

  getCorporateActions: ->
    thisSecurity = Contracts.security.at(@address)
    cas = []
    for i in [0...parseInt(thisSecurity.currentState())]
      type = thisSecurity.cAContractsType(i).toString()
      address = thisSecurity.cAContracts(i).toString()
      caContract = Contracts[type].at(address)
      caContract.type = type
      cas.push caContract
    return cas


Template.security.events
  'click .add-corporate-action' : (e, tmpl) ->
    thisContract = Contracts[@key]
    parentContract = Contracts.security.at(tmpl.data.address)

    # Params for CAs look like: (address parent, [address x, uint y], uint ca)
    # so we'll need to programatically generate and apply the second n arguments

    # first argument is always parent address
    args  = [parentContract.address]

    # parse the ABI and ask for the input parameters
    argsRequred = 1
    for abiItem in thisContract.abi
      if abiItem.type is 'constructor'
        for input in abiItem.inputs
          if input.name isnt 'parent' \
          and input.name isnt 'ca'
            argsRequred++
            paramInfo = prompt """
              #{@name}
              #{@description}
              ---
              Please supply #{input.name} (#{input.type}):
              """

            if input.type.indexOf('int') > -1
              paramInfo = parseInt paramInfo
              unless paramInfo
                alert "#{input.name} must be a non-zero integer"

            if paramInfo
              args.push paramInfo

    # a bit of validation
    if args.length < args.required
      alert 'tx Cancelled'
      return false

    # last CA argument is always the state
    args.push parentContract.currentState().toNumber()

    # this argument is for deployment transaction data
    txData =
      data: thisContract.code
      gas: gasLimit()

    # if this CA requires ether, let's send it some
    if @funded
      if amount = parseInt prompt "How much should we fund this contract with?"
        txData.value = amount
      else
        alert 'tx cancelled'
        return false

    args.push txData

    # add the callback
    args.push (err,res) =>
      if err
      else if res.address
        parentContract.addCorporateAction res.address, @key, {gas: gasLimit()}, (err, res) ->
          updateRegistry()

    # deploy the contract
    thisContract.new.apply(thisContract, args)

Template.ca.helpers
  balance: ->
    web3.eth.getBalance(@address)

  methods: ->
    methods = []
    for method in _.clone @abi
      thisMethod = _.clone method
      if method.type isnt 'constructor'
        if method.constant
          thisMethod.value = @[method.name]()
        methods.push thisMethod
    return methods