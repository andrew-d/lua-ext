local sio = require('stringio')

describe("String I/O module", function()
    describe('StringWriter', function()
        local s

        before_each(function()
            s = sio.create()
        end)

        it('will allow one to write like a file', function()
            s:write("foobar")
        end)

        it('will support writing multiple string arguments', function()
            s:write("foo", "bar", "baz")
            assert.equal("foobarbaz", s:value())
        end)

        it("can be turned into a string", function()
            s:write("foobar")
            assert.equal("foobar", tostring(s))
        end)

        it("has a .value method that returns a string", function()
            s:write("foobar")
            assert.equal("foobar", s:value())
        end)

        describe(':writef', function()
            it('will allow writing a single string', function()
                s:writef("foobar")
                assert.equal("foobar", s:value())
            end)

            it('will allow writing a formatted string', function()
                s:writef("foo %d bar", 1)
                assert.equal("foo 1 bar", s:value())
            end)
        end)

        it('can be closed and seeked', function()
            s:close()
            s:seek(10)
        end)
    end)


    describe('StringReader', function()
        local s

        local function open(val)
            s = sio.open(val)
        end

        it('reads a line by default', function()
            open('foo\nbar')

            assert.equal('foo', s:read())
        end)

        it('supports reading lines explicitly', function()
            open('foo\nbar\nbaz')

            assert.equal('foo', s:read('*l'))
            assert.equal('bar\n', s:read('*L'))
        end)

        it('allows one to read the entire string', function()
            open('foo bar\nbaz')

            assert.equal('foo bar\nbaz', s:read('*a'))
        end)

        it('supports reading a number of characters', function()
            open('1234567890')

            assert.equal('123', s:read(3))
            assert.equal('456', s:read(3))
            assert.equal('7890', s:read(10))
        end)

        it('supports reading numbers', function()
            open('1.234e5')
            assert.equal(1.234e5, s:read('*n'))

            open('456E7')
            assert.equal(456e7, s:read('*n'))

            open('123e-2')
            assert.equal(123e-2, s:read('*n'))
        end)

        it('will error with a bad format', function()
            open('abcd')
            assert.has.errors(function() s:read('foobar') end)
        end)

        it('will return nil on end', function()
            open('abcd')
            assert.equal('abcd', s:read('*a'))
            assert.is_true(s:read('*a') == nil)
        end)

        it('lets you read multiple formats', function()
            open("123 456 789")

            local a, b, c = s:read('*n', '*n', '*n')
            assert.equal(123, a)
            assert.equal(456, b)
            assert.equal(789, c)
        end)
    end)
end)
