Template.balances.helpers
  thisSecurity : ->
    Contracts.security.at FlowRouter.getParam('securityAddress')

  allStates: ->
    [0..@currentState().toNumber()]

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
    return accounts

  stateName: ->
    parentContract = Contracts.security.at FlowRouter.getParam('securityAddress')
    corpActContractAddress = parentContract.cAContracts @
    corpActContractType = parentContract.cAContractsType @
    if corpActContractAddress is '0x0000000000000000000000000000000000000000'
      return 'Mature state'
    else
      thisCa = getCorporateAction(corpActContractType)
      multiplier = Contracts[thisCa.key].at(corpActContractAddress)[thisCa.mainParam]()
      return "#{multiplier}x #{thisCa.name}"