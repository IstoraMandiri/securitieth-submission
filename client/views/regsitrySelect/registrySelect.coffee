Template.registrySelect.events

  'click .create-registry' : ->
    unless title = prompt "Name Regsitry (32 chars or less)"
      alert 'tx cancelled'
      return false

    # deploy new securities contracts
    Contracts.securityRegistry.new title,
       data: Contracts.securityRegistry.code
       gas: 3000000
    , (err,res) ->
      if err
        alert err
      else if res.address
        FlowRouter.go "/registry/#{res.address}"

  'change .set-registry' : (e) ->
    FlowRouter.go "/registry/#{e.currentTarget.value}"