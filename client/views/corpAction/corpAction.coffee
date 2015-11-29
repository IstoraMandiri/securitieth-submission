

Template.corpAction.events
  'click .execute-action' : (e, tmpl) ->
    securityContract = Contracts.security.at(tmpl.data.parentSecurity())
    state = tmpl.data.corpAct().toNumber()
    defaultAmount = securityContract.balances(web3.eth.accounts[0], state).toNumber()
    if amount = prompt "[amount] How much to transact?", defaultAmount
      good = true
      # todo ignore this if not needed
      # TODO add this back in once we havethe need to
      # extra = prompt "[extra] Extra option (or blank)"
      securityContract.runCA.sendTransaction amount, state, extra, {gas:3000000}, (err,res) ->
        console.log 'executed', err, res

    unless good
      alert 'tx cancelled'

  'click .send-coin-from-act' : (e, tmpl) ->
    state = tmpl.data.corpAct().toNumber()
    if amount = parseInt prompt "How many to send?"
      to = prompt "Who to send to? (address)"
      if web3.isAddress(to)
        complete = true
        securityContract = Contracts.security.at(tmpl.data.parentSecurity())
        # always send from latest state
        securityContract.sendCoin.sendTransaction to, amount, state, {gas: 3000000}, (err,res) ->
          # get the transaction result and track it for updates
          console.log 'did the thing', err, res

    unless complete
      alert 'Cancelled TX'

Template.corpAction.helpers
  caInfo : ->
    self = _.clone @
    for key, val of getCorporateAction(@type)
      self[key] = val
    return self

  titleModifier: ->
    "#{@[@mainParam]().toString()}x"

  stateBalance: ->
    Contracts.security.at(@parentSecurity()).balances(web3.eth.accounts[0], @corpAct()).toNumber()

  balance: ->
    web3.eth.getBalance(@address)

  methods: ->
    methods = []
    for method in _.clone @abi
      thisMethod = _.clone method
      if method.type isnt 'constructor' \
      and method.type isnt 'execute'
        if method.constant
          thisMethod.value = @[method.name]()
        methods.push thisMethod
    return methods

# 0x3f997957bd2ad11a8716a88f50bf5b828731eb92