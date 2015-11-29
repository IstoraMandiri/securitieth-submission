FlowRouter.route '/',
  action: ->
    BlazeLayout.render 'defaultLayout',
      main: "registrySelect"

FlowRouter.route '/registry/:registryAddress',
  action: ->
    BlazeLayout.render 'defaultLayout',
      main: "registry"

FlowRouter.route '/registry/:registryAddress/:securityAddress',
  action: ->
    BlazeLayout.render 'defaultLayout',
      main: "security"

FlowRouter.route '/registry/:registryAddress/:securityAddress/balances',
  action: ->
    BlazeLayout.render 'defaultLayout',
      main: "balances"