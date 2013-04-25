(function() {
  var Amount, BigDecimal, ROUND_HALF_UP, SCALE,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  BigDecimal = require('bigdecimal').BigDecimal;

  ROUND_HALF_UP = require('bigdecimal').RoundingMode.HALF_UP();

  SCALE = 25;

  module.exports = Amount = (function() {
    function Amount(value) {
      this.toString = __bind(this.toString, this);
      this.divide = __bind(this.divide, this);
      this.multiply = __bind(this.multiply, this);
      this.subtract = __bind(this.subtract, this);
      this.add = __bind(this.add, this);
      this.compareTo = __bind(this.compareTo, this);
      var e;

      if (value instanceof BigDecimal) {
        this.value = value;
      } else if (typeof value === 'string') {
        try {
          this.value = new BigDecimal(value);
        } catch (_error) {
          e = _error;
          throw new Error('String initializer cannot be parsed to a number');
        }
      } else {
        throw new Error('Must intialize from string');
      }
    }

    Amount.prototype.compareTo = function(amount) {
      if (amount instanceof Amount) {
        return this.value.compareTo(amount.value);
      } else {
        throw new Error('Can only compare to Amount objects');
      }
    };

    Amount.prototype.add = function(amount) {
      if (amount instanceof Amount) {
        return new Amount(this.value.add(amount.value));
      } else {
        throw new Error('Can only add Amount objects');
      }
    };

    Amount.prototype.subtract = function(amount) {
      if (amount instanceof Amount) {
        return new Amount(this.value.subtract(amount.value));
      } else {
        throw new Error('Can only subtract Amount objects');
      }
    };

    Amount.prototype.multiply = function(amount) {
      if (amount instanceof Amount) {
        return new Amount(this.value.multiply(amount.value));
      } else {
        throw new Error('Can only multiply Amount objects');
      }
    };

    Amount.prototype.divide = function(amount) {
      if (amount instanceof Amount) {
        return new Amount(this.value.divide(amount.value, SCALE, ROUND_HALF_UP).stripTrailingZeros());
      } else {
        throw new Error('Can only divide Amount objects');
      }
    };

    Amount.prototype.toString = function() {
      return this.value.toString();
    };

    return Amount;

  })();

  Amount.ZERO = new Amount('0');

}).call(this);