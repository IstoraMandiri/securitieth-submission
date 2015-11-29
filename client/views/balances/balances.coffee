Template.balances.helpers
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
    console.log accounts
    return accounts
