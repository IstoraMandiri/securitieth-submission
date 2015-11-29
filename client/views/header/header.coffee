Template.header.onCreated ->

  @myEth = new ReactiveVar();

  do interval = =>
    @myEth.set Math.round(web3.fromWei(web3.eth.getBalance(web3.eth.accounts[0]).toNumber(), "ether") * 100) / 100

  @handle = Meteor.setInterval interval, 2000

Template.header.onDestroyed ->
  Meteor.clearInterval @handle

Template.header.helpers
  myEth: ->
    Template.instance().myEth.get() || '...'