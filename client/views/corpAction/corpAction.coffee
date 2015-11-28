Template.corpAction.events
  'click .execute-action' : (e, tmpl) ->
    console.log tmpl.data.corpAct().toNumber(), tmpl.data.parentSecurity()
    # TODO: generate 'EXTRA' input based on ABI again
    if amount = parseInt prompt "How much to send?"
      console.log 'sending', amount
    else
      alert 'tx cancelled'
    # executionMethod = Contracts.security.at(tmpl.data.parentSecurity())


Template.corpAction.helpers
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