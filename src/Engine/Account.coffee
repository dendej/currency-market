Balance = require './Balance'
Order = require './Order'

module.exports = class Account
  constructor: (params) ->
    @orders = Object.create null
    if params && params.id
      @id = params.id
      @commission = params.commission
      @balances = Object.create null
    else
      throw new Error 'Account ID must be specified'

  getBalance: (currency) =>
    if !@balances[currency]
      @balances[currency] = new Balance
        account: @
        currency: currency
        commission: @commission
    return @balances[currency]

  deposit: (params) =>
    if params.currency
      if params.amount
        @getBalance(params.currency).deposit params.amount
      else
        throw new Error 'Must supply an amount'
    else
      throw new Error 'Must supply a currency'

  withdraw: (params) =>
    if params.currency
      if params.amount
        @getBalance(params.currency).withdraw params.amount
      else
        throw new Error 'Must supply an amount'
    else
      throw new Error 'Must supply a currency'

  submit: (order) =>
    lockedFunds = @getBalance(order.book.offerCurrency).lock order.offerAmount
    @orders[order.sequence] = order
    return lockedFunds

  complete: (order) =>
    delete @orders[order.sequence]    

  getOrder: (sequence) =>
    order = @orders[sequence]
    if !order
      throw new Error 'Order cannot be found'
    else
      return order

  cancel: (order) =>
    delete @orders[order.sequence]
    @getBalance(order.book.offerCurrency).unlock order.offerAmount

  export: =>
    object = Object.create null
    object.id = @id
    object.balances = Object.create null
    for currency, balance of @balances
      object.balances[currency] = balance.export()
    return object
