
if Meteor.isClient

  Template.securities.helpers
    securities: [
      address: 'test1'
      balances: {'addr': 3, 'addr2': 2}
      cas: [
        'addr'
        'addr2'
        'addr3'
      ]
    ]

  Template.security.helpers
    getCA: (address) ->
      console.log 'getting ca', address
      return {type: 'thingy'}
