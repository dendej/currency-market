chai = require 'chai'
chai.should()
expect = chai.expect
assert = chai.assert

Amount = require('../src/Amount')

describe 'Amount', ->
  it 'cannot be initialized from Javascript Numbers as they are inherently innacurate', ->
    expect ->
      amount = new Amount(5)
    .to.throw('Must intialize from string')

  it 'cannot be initialized with a string that cannot be parsed to a number', ->
    expect ->
      amount = new Amount('This is not a number')
    .to.throw('String initializer cannot be parsed to a number')

  describe '#compareTo', ->
    it 'cannot be called with Javascript Numbers as they are inherently innacurate', ->
      amount = Amount.ZERO
      expect ->
        amount.compareTo(0)
      .to.throw('Can only compare to Amount objects')

    it 'should return 0 if 2 amounts are equal', ->
      amount1 = new Amount('5')
      amount2 = new Amount('5')
      amount1.compareTo(amount2).should.equal(0)

    it 'should return -1 if the first amount is less than the second amount', ->
      amount1 = Amount.ZERO
      amount2 = new Amount('5')
      amount1.compareTo(amount2).should.equal(-1)

    it 'should return 1 if the first amount is greater than the second amount', ->
      amount1 = new Amount('5')
      amount2 = Amount.ZERO
      amount1.compareTo(amount2).should.equal(1)

  describe '#add', ->
    it 'cannot be called with Javascript Numbers as they are inherently innacurate', ->
      amount = Amount.ZERO
      expect ->
        amount.add(5)
      .to.throw('Can only add Amount objects')

    it 'should return a new Amount which is the sum of 2 amounts', ->
      amount3 = new Amount('3')
      amount4 = new Amount('4')
      anotherAmount3 = new Amount('3')
      anotherAmount4 = new Amount('4')
      amount7 = new Amount('7')
      amountSum = amount3.add(amount4)
      amountSum.compareTo(amount7).should.equal(0, 'Sum should be correct')
      amount3.compareTo(anotherAmount3).should.equal(0, 'First amount should not change')
      amount4.compareTo(anotherAmount4).should.equal(0, 'Second amount should not change')

    it 'should correctly add 0.1 to 0.2 so that we avoid Javascript Number issues', ->
      amountPoint1 = new Amount('0.1')
      amountPoint2 = new Amount('0.2')
      amountPoint3 = new Amount('0.3')
      amountSum = amountPoint1.add(amountPoint2)
      amountSum.compareTo(amountPoint3).should.equal(0, 'Sum should be correct')

  describe '#subtract', ->
    it 'cannot be called with Javascript Numbers as they are inherently innacurate', ->
      amount = Amount.ZERO
      expect ->
        amount.subtract(5)
      .to.throw('Can only subtract Amount objects')

    it 'should return a new Amount which is the difference of 2 amounts', ->
      amount3 = new Amount('3')
      amount4 = new Amount('4')
      anotherAmount3 = new Amount('3')
      anotherAmount4 = new Amount('4')
      amountMinus1 = new Amount('-1')
      amountDifference = amount3.subtract(amount4)
      amountDifference.compareTo(amountMinus1).should.equal(0, 'Difference should be correct')
      amount3.compareTo(anotherAmount3).should.equal(0, 'First amount should not change')
      amount4.compareTo(anotherAmount4).should.equal(0, 'Second amount should not change')

  describe '#multiply', ->
    it 'cannot be called with Javascript Numbers as they are inherently innacurate', ->
      amount = Amount.ZERO
      expect ->
        amount.multiply(5)
      .to.throw('Can only multiply Amount objects')

    it 'should return a new Amount which is the product of 2 amounts', ->
      amount3 = new Amount('3')
      amount4 = new Amount('4')
      anotherAmount3 = new Amount('3')
      anotherAmount4 = new Amount('4')
      amount12 = new Amount('12')
      amountProduct = amount3.multiply(amount4)
      amountProduct.compareTo(amount12).should.equal(0, 'Product should be correct')
      amount3.compareTo(anotherAmount3).should.equal(0, 'First amount should not change')
      amount4.compareTo(anotherAmount4).should.equal(0, 'Second amount should not change')

  describe '#toString', ->
    it 'should return a string representation of the amount', ->
      amount = new Amount('3.14')
      amount.toString().should.equal('3.14')

    it 'should retrun a string representation that is suitable for exporting and later importing amounts', ->
      amount1 = new Amount('3.14')
      amount2 = new Amount amount1.toString()
      amount1.compareTo(amount2).should.equal 0

  describe '#export', ->
    it 'should export the state of the Amount as a JSON stringifiable object that can be used to initialise a new Amount in the exact same state', ->
      amount3 = new Amount('3')
      state = amount3.export()
      json = JSON.stringify state
      newAmount = new Amount
        state: JSON.parse(json)
      newAmount.compareTo(amount3).should.equal 0
