Book = require('../../src/Market/Book')
Order = require('../../src/Market/Order')
BigDecimal = require('BigDecimal').BigDecimal

newOrder = (id, price) ->
  new Order
    id: id
    timestamp: '987654321'
    account: 'name',
    bidCurrency: 'BTC',
    offerCurrency: 'EUR',
    bidAmount: '100',
    bidPrice: price

describe 'Book', ->
  describe '#add', ->
    it 'should keep track of the order with the highest bid price', ->
      #
      #                       1
      #                      / \
      #                     /   \
      #                    /     \
      #                   /       \
      #                  /         \
      #                 3           2
      #                / \         / \
      #               /   \       /   \
      #              7     6     5     4
      #             / \   / \   / \   / \
      #            8   9 10 11 12 13 14 15
      #
      book = new Book()
      order1 = newOrder('1', '50')
      book.add(order1)
      book.highest.should.equal(order1)

      order2 = newOrder('2', '51')
      book.add(order2)
      book.highest.should.equal(order2)

      order3 = newOrder('3', '49')
      book.add(order3)
      book.highest.should.equal(order2)

      order4 = newOrder('4', '52')
      book.add(order4)
      book.highest.should.equal(order4)

      order5 = newOrder('5', '50.5')
      book.add(order5)
      book.highest.should.equal(order4)

      order6 = newOrder('6', '49.5')
      book.add(order6)
      book.highest.should.equal(order4)

      order7 = newOrder('7', '48.5')
      book.add(order7)
      book.highest.should.equal(order4)

      order8 = newOrder('8', '48.5') # is equal to but should be placed lower than order 7
      book.add(order8)
      book.highest.should.equal(order4)

      order9 = newOrder('9', '48.75')
      book.add(order9)
      book.highest.should.equal(order4)

      order10 = newOrder('10', '49.5') # is equal to but should be placed lower than order 6
      book.add(order10)
      book.highest.should.equal(order4)

      order11 = newOrder('11', '49.75')
      book.add(order11)
      book.highest.should.equal(order4)

      order12 = newOrder('12', '50.5') # is equal to but should be placed lower than order 5
      book.add(order12)
      book.highest.should.equal(order4)

      order13 = newOrder('13', '50.75')
      book.add(order13)
      book.highest.should.equal(order4)

      order14 = newOrder('14', '52') # is equal to but should be placed lower than order 4
      book.add(order14)
      book.highest.should.equal(order4)

      order15 = newOrder('15', '53')
      book.add(order15)
      book.highest.should.equal(order15)

  describe '#delete', ->
    beforeEach ->
      @book = new Book()
      #
      #                       1
      #                      / \
      #                     /   \
      #                    /     \
      #                   /       \
      #                  /         \
      #                 3           2
      #                / \         / \
      #               /   \       /   \
      #              7     6     5     4
      #             / \   / \   / \   / \
      #            8   9 10 11 12 13 14 15
      #
      @order1 = newOrder('1', '50')
      @book.add(@order1)
      @order2 = newOrder('2', '51')
      @book.add(@order2)
      @order3 = newOrder('3', '49')
      @book.add(@order3)
      @order4 = newOrder('4', '52')
      @book.add(@order4)
      @order5 = newOrder('5', '50.5')
      @book.add(@order5)
      @order6 = newOrder('6', '49.5')
      @book.add(@order6)
      @order7 = newOrder('7', '48.5')
      @book.add(@order7)
      @order8 = newOrder('8', '48.5') # is equal to but should be placed lower than order 7
      @book.add(@order8)
      @order9 = newOrder('9', '48.75')
      @book.add(@order9)
      @order10 = newOrder('10', '49.5') # is equal to but should be placed lower than order 6
      @book.add(@order10)
      @order11 = newOrder('11', '49.75')
      @book.add(@order11)
      @order12 = newOrder('12', '50.5') # is equal to but should be placed lower than order 5
      @book.add(@order12)
      @order13 = newOrder('13', '50.75')
      @book.add(@order13)
      @order14 = newOrder('14', '52') # is equal to but should be placed lower than order 4
      @book.add(@order14)
      @order15 = newOrder('15', '53')
      @book.add(@order15)

    it 'should throw an error if the order ID cannot be found', ->
      order = newOrder('16', '53')
      expect =>
        @book.delete(order)
      .to.throw('Order cannot be found')

    it 'should throw an error if the order does not match', ->
      order = newOrder('15', '54')
      expect =>
        @book.delete(order)
      .to.throw('Orders do not match')

    it 'should keep track of the order with the highest bid price', ->
      order = newOrder('1', '50')
      @book.delete(order) # delete head order with both lower and higher orders
      @book.highest.should.equal(@order15)
      #                         2
      #                        / \
      #                       /   \
      #                      5     4
      #                     / \   / \
      #                    12 13 14 15
      #                   /  
      #                  3   
      #                 / \  
      #                /   \ 
      #               7     6 
      #              / \   / \ 
      #             8   9 10 11
      order = newOrder('12', '50.5')
      @book.delete(order) # delete order without higher order
      @book.highest.should.equal(@order15)
      #                         2
      #                        / \
      #                       /   \
      #                      5     4
      #                     / \   / \
      #                    3  13 14 15
      #                   / \  
      #                  /   \ 
      #                 7     6 
      #                / \   / \ 
      #               8   9 10 11
      order = newOrder('10', '49.5')
      @book.delete(order) # delete order on a lower branch with no lower order
      @book.highest.should.equal(@order15)
      #                         2
      #                        / \
      #                       /   \
      #                      5     4
      #                     / \   / \
      #                    3  13 14 15
      #                   / \  
      #                  /   \ 
      #                 7     6 
      #                / \     \ 
      #               8   9    11
      order = newOrder('6', '49.5')
      @book.delete(order) # delete order with no lower order
      @book.highest.should.equal(@order15)
      #                         2
      #                        / \
      #                       /   \
      #                      5     4
      #                     / \   / \
      #                    3  13 14 15
      #                   / \  
      #                  /   \ 
      #                 7    11
      #                / \    
      #               8   9   
      order = newOrder('11', '49.75')
      @book.delete(order)
      @book.highest.should.equal(@order15)
      order = newOrder('8', '48.5')
      @book.delete(order)
      @book.highest.should.equal(@order15)
      #                         2
      #                        / \
      #                       /   \
      #                      5     4
      #                     / \   / \
      #                    3  13 14 15
      #                   /   
      #                  /   
      #                 7   
      #                  \    
      #                   9   
      #
      # Now remove highest until all elements have been removed and verify the new highest each time
      # this time we'll use the actual references added as this should also be safe
      @book.delete(@order15)
      @book.highest.should.equal(@order4)
      @book.delete(@order4)
      @book.highest.should.equal(@order14)
      @book.delete(@order14)
      @book.highest.should.equal(@order2)
      @book.delete(@order2)
      @book.highest.should.equal(@order13)
      @book.delete(@order13)
      @book.highest.should.equal(@order5)
      @book.delete(@order5)
      @book.highest.should.equal(@order3)
      @book.delete(@order3)
      @book.highest.should.equal(@order9)
      @book.delete(@order9)
      @book.highest.should.equal(@order7)
      @book.delete(@order7)
      expect(@book.highest).to.not.be.ok
