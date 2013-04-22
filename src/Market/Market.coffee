Account = require('./Account/Account')
Book = require('./Book')
Order = require('./Order')
Amount = require('./Amount')

module.exports = class Market
  constructor: (@currencies) ->
    @accounts = Object.create null
    @books = Object.create null
    @currencies.forEach (bidCurrency) =>
      @books[bidCurrency] = Object.create null
      @currencies.forEach (orderCurrency) =>
        if bidCurrency != orderCurrency
          @books[bidCurrency][orderCurrency] = new Book()

  addAccount: (name) ->
    if @accounts[name]
      throw new Error('Account already exists')
    else
      @accounts[name] = new Account(@currencies)

  deposit: (deposit) =>
    account = @accounts[deposit.account]
    if typeof account == 'undefined'
      throw new Error('Account does not exist')
    else
      balance = account.balances[deposit.currency]
      if typeof balance == 'undefined'
        throw new Error('Currency is not supported')
      else
        balance.deposit(new Amount(deposit.amount))

  withdraw: (withdrawal) =>
    account = @accounts[withdrawal.account]
    if typeof account == 'undefined'
      throw new Error('Account does not exist')
    else
      balance = account.balances[withdrawal.currency]
      if typeof balance == 'undefined'
        throw new Error('Currency is not supported')
      else
        balance.withdraw(new Amount(withdrawal.amount))

  add: (order) =>
    order = new Order(order)
    account = @accounts[order.account]
    if typeof account == 'undefined'
      throw new Error('Account does not exist')
    else
      balance = account.balances[order.offerCurrency]
      if typeof balance == 'undefined'
        throw new Error('Offer currency is not supported')
      else
        books = @books[order.bidCurrency]
        if typeof books == 'undefined'
          throw new Error('Bid currency is not supported')
        else
          book = books[order.offerCurrency]
          balance.lock(order.offerAmount)
          book.add(order)
          # check the books to see if any orders can be executed
          @execute(book, @books[order.offerCurrency][order.bidCurrency])

  delete: (order) =>
    order = new Order(order)
    account = @accounts[order.account]
    if typeof account == 'undefined'
      throw new Error('Account does not exist')
    else
      balance = account.balances[order.offerCurrency]
      if typeof balance == 'undefined'
        throw new Error('Offer currency is not supported')
      else
        books = @books[order.bidCurrency]
        if typeof books == 'undefined'
          throw new Error('Bid currency is not supported')
        else
          book = books[order.offerCurrency]
          book.delete(order)
          balance.unlock(order.offerAmount)

  execute: (leftBook, rightBook) =>
    leftOrder = leftBook.highest
    rightOrder = rightBook.highest
    if typeof leftOrder != 'undefined' && typeof rightOrder != 'undefined'
      if leftOrder.bidPrice.compareTo(rightOrder.offerPrice) >= 0
        # just added an order to the left book so the left order must be
        # the most recent addition if we get here. This means that we should
        # take the price from the right order

        leftBalances = @accounts[leftOrder.account].balances
        rightBalances = @accounts[rightOrder.account].balances
        leftOfferCurrency = leftOrder.offerCurrency
        leftBidCurrency = leftOrder.bidCurrency

        rightMaxBidAmount = rightOrder.bidAmount
        rightMaxOfferAmount = rightOrder.offerAmount
        if leftOrder.fillOffer
          leftMaxOfferAmount = leftOrder.offerAmount
          leftMaxBidAmount = leftOrder.offerAmount.multiply(rightOrder.bidPrice)
        else
          leftMaxBidAmount = leftOrder.bidAmount
          leftMaxOfferAmount = leftMaxBidAmount.multiply(rightOrder.offerPrice)

        if leftMaxOfferAmount.compareTo(rightMaxBidAmount) > 0
          # trade the rightMaxBidAmount at the right order price
          leftOfferReduction = rightMaxOfferAmount.multiply(rightOrder.bidPrice)
          leftBalances[leftOfferCurrency].unlock(leftOfferReduction)
          leftBalances[leftOfferCurrency].withdraw(rightMaxBidAmount)
          rightBalances[leftOfferCurrency].deposit(rightMaxBidAmount)
          rightBalances[leftBidCurrency].unlock(rightMaxOfferAmount)
          rightBalances[leftBidCurrency].withdraw(rightMaxOfferAmount)
          leftBalances[leftBidCurrency].deposit(rightMaxOfferAmount)
          # delete the right order
          rightBook.delete(rightOrder)
          # reduce the left order
          leftOrder.reduceOffer(leftOfferReduction)
        else
          # trade the leftMaxOfferAmount at the right order price
          leftBalances[leftOfferCurrency].unlock(leftOrder.offerAmount)
          leftBalances[leftOfferCurrency].withdraw(leftMaxOfferAmount)
          rightBalances[leftOfferCurrency].deposit(leftMaxOfferAmount)
          rightBalances[leftBidCurrency].unlock(leftMaxBidAmount)
          rightBalances[leftBidCurrency].withdraw(leftMaxBidAmount)
          leftBalances[leftBidCurrency].deposit(leftMaxBidAmount)
          # delete the left order
          leftBook.delete(leftOrder)
          # reduce the right order
          rightOrder.reduceBid(leftMaxOfferAmount)
          # delete the right order if now has a zero amount
          if rightOrder.bidAmount.compareTo(Amount.ZERO) == 0
            rightBook.delete(rightOrder)
