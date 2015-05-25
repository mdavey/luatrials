-- Description: Trying to use busted --

package.path = package.path .. ";../?.lua"

BigNumber = require('36_big_numbers')

describe('BigNumberAdder Module', function()

    it('should init to zero', function()
        local bn = BigNumber.new()
        assert.equal(tostring(bn), '0')
    end)

    it('should be able to inc numbers', function()
        local bn = BigNumber.new()
        bn:inc(10)
        bn:inc(321)
        assert.equal(tostring(bn), '331')
    end)

    it('should be able to inc by other big numbers', function()
        local bn1 = BigNumber.new(123)
        local bn2 = BigNumber.new(123)
        bn2:inc(bn1)
        assert.equal(tostring(bn2), '246')
        assert.equal(tostring(bn1), '123')
    end)

    it('should take a inital number', function()
        local bn = BigNumber.new(1234)
        assert.equal(tostring(bn), '1234')
    end)

    it('should be able to set any number', function()
        local bn = BigNumber.new(1234)
        assert.equal(tostring(bn), '1234')
        bn:set(4321)
        assert.equal(tostring(bn), '4321')
    end)

    it('should be able to inc by big numbers', function()
        local bn = BigNumber.new(1)

        for i=1, 100, 1 do
            bn:inc(bn)
        end
        
        assert.equal(tostring(bn), '1267650600228229401496703205376')
    end)

    it('should only accept numbers and big numbers', function()
        assert.has_error(function()
            BigNumber.new('a')
        end)
    
        assert.has_error(function()
            BigNumber.new({})
        end)
    end)

    it('should add big numbers together and get a new big number', function()
        local a = BigNumber.new(123)
        local b = BigNumber.new(234)
        local c = BigNumber.add(a, b)
        assert.equal(tostring(a), '123')
        assert.equal(tostring(b), '234')
        assert.equal(tostring(c), '357')
    end)

    it('should add two numbers via oo too', function()
        local a = BigNumber.new(123)
        local b = BigNumber.new(234)
        local c = a:add(b)
        local d = b:add(a)
        assert.equal(tostring(a), '123')
        assert.equal(tostring(b), '234')
        assert.equal(tostring(c), '357')
        assert.equal(tostring(c), '357')
    end)

    it('should add two numbers via "+"', function()
        local a = BigNumber.new(123)
        local b = BigNumber.new(234)
        local c = a + b
        assert.equal(tostring(a), '123')
        assert.equal(tostring(b), '234')
        assert.equal(tostring(c), '357')
    end)

end)