chai = require 'chai'
chai.should()
expect = chai.expect

Withdraw = require '../../src/Operation/Withdraw'
Amount = require '../../src/Amount'

describe 'Withdraw', ->
  it 'should error if no currency is supplied', ->
    expect ->
      withdraw = new Withdraw
        amount: new Amount '1000'
    .to.throw 'Must supply a currency'

  it 'should error if no amount is supplied', ->
    expect ->
      withdraw = new Withdraw
        currency: 'EUR'
    .to.throw 'Must supply an amount'

  it 'should instantiate recording the currency and amount', ->
    withdraw = new Withdraw
      currency: 'EUR'
      amount: new Amount '1000'
    withdraw.currency.should.equal 'EUR'
    withdraw.amount.compareTo(new Amount '1000').should.equal 0
    withdraw = new Withdraw
      exported: JSON.parse JSON.stringify withdraw
    withdraw.currency.should.equal 'EUR'
    withdraw.amount.compareTo(new Amount '1000').should.equal 0
