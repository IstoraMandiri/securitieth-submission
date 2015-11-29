# naively and inefficiently poll for data
Template.security.onCreated ->
  @security = new ReactiveVar();
  do interval = =>
    @security.set Contracts.security.at FlowRouter.getParam('securityAddress')
  @handle = Meteor.setInterval interval, 2000

Template.security.onDestroyed ->
  Meteor.clearInterval @handle

Template.security.helpers
  availableActions : -> corporateActions

  iAmIssuer: ->
    @issuer() is web3.eth.accounts[0]

  security: ->
    Template.instance().security.get()

  matureBalance: ->
    @balances(web3.eth.accounts[0], @currentState().toNumber()).toNumber()

  getCorporateActions: ->
    cas = []
    for i in [parseInt(@currentState())-1..0]
      address = @cAContracts(i).toString()
      if address isnt '0x0000000000000000000000000000000000000000'
        type = @cAContractsType(i).toString()
        caContract = Contracts[type].at(address)
        caContract.type = type
        cas.push caContract
    return cas

Template.security.events
  'click .send-coin' : (e, tmpl) ->
    state = @currentState().toNumber()
    if amount = parseInt prompt "How many to send?"
      to = prompt "Who to send to? (address)"
      if web3.isAddress(to)
        complete = true
        @sendCoin.sendTransaction to, amount, state, {gas: 3000000}, (err,res) ->
          # get the transaction result and track it for updates
          console.log 'did the thing', err, res

    unless complete
      alert 'Cancelled TX'

  'click .add-corporate-action' : (e, tmpl) ->
    thisContract = Contracts[@key]
    parentContract = Contracts.security.at FlowRouter.getParam 'securityAddress'
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
              Please supply a "#{input.name}":
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
      gas: 3000000

    # if this CA requires ether, let's send it some
    if @funded
      if amount = parseInt prompt "How much should we fund this contract with (in wei)x?"
        txData.value = amount
      else
        alert 'tx cancelled'
        return false

    args.push txData

    # add the callback
    args.push (err,res) =>
      if err
        alert err
      else if res.address
        parentContract.addCorporateAction.sendTransaction res.address, @key, {gas: 3000000}, (err,res) ->
          # get the transaction result and track it for updates
          console.log err, res

    # deploy the contract
    thisContract.new.apply(thisContract, args)
