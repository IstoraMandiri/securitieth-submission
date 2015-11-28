

Template.corpAction.events
  'click .execute-action' : (e, tmpl) ->
    securityContract = Contracts.security.at(tmpl.data.parentSecurity())
    state = tmpl.data.corpAct().toNumber()
    defaultAmount = securityContract.balances(web3.eth.accounts[0], state).toNumber()
    if amount = prompt "[amount] How much to transact?", defaultAmount
      good = true
      # todo ignore this if not needed
      extra = prompt "[extra] Extra option (or blank)"
      securityContract.runCA.sendTransaction amount, state, extra, {gas:3000000}, (err,res) ->
        console.log 'executed', err, res

    unless good
      alert 'tx cancelled'


Template.corpAction.helpers
  stateBalance: ->
    Contracts.security.at(@parentSecurity()).balances(web3.eth.accounts[0], @corpAct()).toNumber()


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

# 0x3f997957bd2ad11a8716a88f50bf5b828731eb92