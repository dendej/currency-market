Amount = require('./Amount')

module.exports = class Balance
  constructor: (params) ->
    @offers = Object.create null
    @funds = Amount.ZERO
    @lockedFunds = Amount.ZERO

  deposit: (amount) =>
    @funds = @funds.add(amount)

  submitOffer: (order) =>
    newLockedFunds = @lockedFunds.add order.offerAmount
    if newLockedFunds.compareTo(@funds) > 0
      throw new Error('Cannot lock funds that are not available')
    else
      @offers[order.id] = order
      @lockedFunds = newLockedFunds
      order.on 'fill', (fill) =>
        @lockedFunds = @lockedFunds.subtract fill.fundsUnlocked
        @funds = @funds.subtract fill.offerAmount
      order.on 'done', =>
        delete @offers[order.id]

  submitBid: (order) =>
    order.on 'fill', (fill) =>
      @funds = @funds.add fill.bidAmount

  cancel: (order) =>
    @lockedFunds = @lockedFunds.subtract order.offerAmount    
    delete @offers[order.id]

  withdraw: (amount) =>
    newFunds = @funds.subtract(amount)
    if newFunds.compareTo(@lockedFunds) < 0
      throw new Error('Cannot withdraw funds that are not available')
    else
      @funds = newFunds
