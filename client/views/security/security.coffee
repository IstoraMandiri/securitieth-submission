
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

  allStates: -> [0..@currentState().toNumber()]

  accountStates: ->
    # create accounts object
    accounts = []
    for i in [0...@accountsCount().toNumber()]
      thisAccount =
        address: @accounts(i)
        balances: []
      for j in [0..@currentState().toNumber()]
        thisAccount.balances.push @balances(thisAccount.address, j).toNumber()
      accounts.push thisAccount
    console.log accounts
    return accounts

  myLatestState: ->
    @latestState(web3.eth.accounts[0]).toNumber()

  getBalance: (state) ->
    @balances(web3.eth.accounts[0], state).toNumber()

  getCorporateActions: ->
    cas = []
    for i in [0...parseInt(@currentState())]
      type = @cAContractsType(i).toString()
      address = @cAContracts(i).toString()
      caContract = Contracts[type].at(address)
      caContract.type = type
      cas.push caContract
    return cas


Template.security.events
  'click .send-coin' : (e, tmpl) ->
    console.log 'sending coin :)', @
    state = parseInt prompt "From which state?"
    if state or state is 0
      if amount = parseInt prompt "How many to send?"
        to = prompt "Who to send to? (address)"
        if web3.isAddress(to)
          complete = true
          # always send from latest state
          @sendCoin.sendTransaction to, amount, state, {gas: 3000000}, (err,res) ->
            # get the transaction result and track it for updates
            console.log 'did the thing', err, res

    unless complete
      alert 'Cancelled TX'


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
      gas: 3000000

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
        alert err
      else if res.address
        parentContract.addCorporateAction.sendTransaction res.address, @key, {gas: 3000000}, (err,res) ->
          # get the transaction result and track it for updates
          console.log err, res


    # deploy the contract
    thisContract.new.apply(thisContract, args)
