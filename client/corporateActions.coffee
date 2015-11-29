@getCorporateAction = (type) ->
  return (val for val in corporateActions when val.key is type)[0]



@corporateActions = [
  key:'coupon'
  name: 'Coupon'
  description: 'Contract is funded with ether to pay the coupon'
  mainParam: 'couponRate'
  funded: true
  icon: 'ticket'
,
  key:'dividend'
  name: 'Dividend'
  description: 'Contract is funded with ether to out a dividend'
  mainParam: 'dividendRate'
  funded: true
  icon: 'money'
,
  key:'redemption'
  name: 'Redemption'
  description: 'Contract is funded with ether to pay the redemption'
  mainParam: 'redemptionRate'
  funded: true
  icon: 'recycle'
# TODO MAKE IT MORE COMPLICATED :)
#   key:'proxyVote'
#   name: 'Proxy Vote'
#   description: 'Voting contract tallies votes of share holders'
#   funded: false
#   icon : 'pie-chart'
# ,
# ,
#   key:'spinOff'
#   name: 'Spin Off Company'
#   description: 'Credits users with a certain number of new shares in a new company'
#   mainParam: 'ratio'
#   funded: false
#   icon: 'building-o'
,
  key:'stockSplit'
  name: 'Stock Split'
  description: 'Stock splits increase the number of shares in existence (ie for evry 1 share you own you get three new shares)'
  mainParam: 'ratio'
  funded: false
  icon: 'share-alt'
]