BigDecimal = require('bigdecimal').BigDecimal
ROUND_HALF_UP = require('bigdecimal').RoundingMode.HALF_UP()
SCALE = 25

module.exports = class Amount
  constructor: (string_value) ->
    if typeof string_value == 'undefined'
      string_value = '0'

    if typeof string_value == 'string'
      try
        @value = new BigDecimal(string_value)
      catch e
        throw new Error('String initializer cannot be parsed to a number')
    else
      throw new Error('Must intialize from string')

  compareTo: (amount) =>
    if amount instanceof Amount
      return @value.compareTo(amount.value)
    else
      throw new Error('Can only compare to Amount objects')

  add: (amount) =>
    if amount instanceof Amount
      sum = new Amount()
      sum.value = @value.add(amount.value)
      return sum
    else
      throw new Error('Can only add Amount objects')

  subtract: (amount) =>
    if amount instanceof Amount
      difference = new Amount()
      difference.value = @value.subtract(amount.value)
      return difference
    else
      throw new Error('Can only subtract Amount objects')

  multiply: (amount) =>
    if amount instanceof Amount
      product = new Amount()
      product.value = @value.multiply(amount.value)
      return product
    else
      throw new Error('Can only multiply Amount objects')    

  divide: (amount) =>
    if amount instanceof Amount
      ratio = new Amount()
      ratio.value = @value.divide(amount.value, SCALE, ROUND_HALF_UP).stripTrailingZeros()
      return ratio
    else
      throw new Error('Can only divide Amount objects')    

  toString: =>
    return @value.toString()

Amount.ZERO = new Amount('0')