local tx = require('tablex')

describe("Table extension library", function()
    describe('copy', function()
        local t, c

        setup(function()
            t = {1, {2}}
        end)

        teardown(function()
            t = nil
        end)

        it('will copy a table', function()
            c = tx.copy(t, false)
            assert.equal(c[1], 1)
            assert.equal(c[2][1], 2)

            -- Mutate the table.  The embedded table should be modified.
            t[1] = 3
            assert.equal(c[1], 1)

            t[2][1] = 4
            assert.equal(c[2][1], 4)
        end)

        it('will not preserve the metatable by default', function()
            local mt = {}
            setmetatable(t, mt)

            c = tx.copy(t, false)
            assert.not_equal(getmetatable(c), mt)
        end)

        it('will preserve the metatable when asked', function()
            local mt = {}
            setmetatable(t, mt)

            c = tx.copy(t, true)
            assert.equal(getmetatable(c), mt)
        end)
    end)

    describe('deepcopy', function()
        local t, c

        setup(function()
            t = {1, {2}}
        end)

        teardown(function()
            t = nil
        end)

        it('will deep-copy a table', function()
            c = tx.deepcopy(t, false)
            assert.equal(c[1], 1)
            assert.equal(c[2][1], 2)

            -- Mutate the table.  The embedded table should remain the same.
            t[1] = 3
            assert.equal(c[1], 1)

            t[2][1] = 4
            assert.equal(c[2][1], 2)
        end)

        it('will preserve the metatable', function()
            local mt = {}
            setmetatable(t, mt)

            c = tx.deepcopy(t)
            assert.equal(getmetatable(c), mt)
        end)
    end)

    describe('sort', function()
        it('will return the original table', function()
            local t = {3, 2, 1}
            assert.equal(tx.sort(t), t)
        end)
    end)

    describe('isempty', function()
        it('will detect empty tables', function()
            assert.is_true(tx.isempty({}))
        end)

        it('will not return true for non-empty tables', function()
            assert.is_false(tx.isempty({1}))
            assert.is_false(tx.isempty({foo='bar'}))
        end)
    end)

    describe('size', function()
        it('will return the size of list-like tables', function()
            assert.equal(tx.size({1,2,3}), 3)
        end)

        it('will return the size of sparse list-like tables', function()
            assert.equal(tx.size({1,2,[4] = 3}), 3)
        end)

        it('will return the size of all other tables', function()
            assert.equal(tx.size({foo='bar', asdf='baz'}), 2)
        end)

        it('is also aliased as length and count', function()
            assert.equal(tx.length, tx.size)
            assert.equal(tx.count, tx.size)
        end)
    end)

    describe('keys', function()
        it('will return the keys of a table', function()
            local ks = tx.keys({foo='bar', asdf='baz'})

            assert.equal(ks[1], 'foo')
            assert.equal(ks[2], 'asdf')
        end)

        it('will return the keys of a list-like table', function()
            local ks = tx.keys({1, 2})

            assert.equal(ks[1], 1)
            assert.equal(ks[2], 2)
        end)
    end)

    describe('values', function()
        it('will return the values of a table', function()
            local vs = tx.values({foo='bar', asdf='baz'})

            assert.equal(vs[1], 'bar')
            assert.equal(vs[2], 'baz')
        end)

        it('will return the values of a list-like table', function()
            local vs = tx.values({3, 4})

            assert.equal(vs[1], 3)
            assert.equal(vs[2], 4)
        end)
    end)

    describe('clear', function()
        it('will clear a list-like table', function()
            local t = {1,2,3}
            local u = tx.clear(t)

            assert.equal(#u, 0)
        end)

        it('will clear a table', function()
            local t = {foo='bar', asdf='baz'}
            local u = tx.clear(t)

            assert.equal(tx.count(u), 0)
        end)

        it('will return the original table', function()
            local t = {foo='bar', asdf='baz'}
            local u = tx.clear(t)

            assert.equal(t, u)
        end)
    end)

    describe('update', function()
        it('will copy values to the new table', function()
            local t = {}
            local u = {1, 2, foo='bar'}

            tx.update(t, u)

            assert.equal(t[1], 1)
            assert.equal(t[2], 2)
            assert.equal(t['foo'], 'bar')
        end)

        it('will overwrite the existing values', function()
            local t = {9, foo='gone'}
            local u = {1, foo='bar'}

            tx.update(t, u)

            assert.equal(t[1], 1)
            assert.equal(t['foo'], 'bar')
        end)
    end)

    describe('range', function()
        local c = function(x, y) return x == y end

        local function assert_range(t, ...)
            local ra = tx.range(...)
            assert.is_true(tx.compare(ra, t, c))
        end

        it('will generate a simple range', function()
            assert_range({1,2,3,4,5,6,7,8,9,10}, 1, 10)
        end)

        it('will generate a more complex range', function()
            assert_range({1,4,7,10}, 1, 10, 3)
        end)

        it('will generate a single-value range', function()
            assert_range({1}, 1, 1)
        end)

        it('will generate a empty range', function()
            assert_range({}, 3, 1)
            assert_range({}, 1, 3, -1)
        end)

        it("will generate a simple range that's reversed", function()
            assert_range({10,9,8,7,6,5,4,3,2,1}, 10, 1, -1)
        end)

        it("will generate a more complex range that's reversed", function()
            assert_range({10,7,4,1}, 10, 1, -3)
        end)
    end)

    describe('transpose', function()
        it('will transpose a table', function()
            local t = {1, 3, foo='bar'}
            local u = tx.transpose(t)

            assert.equal(u[1], 1)
            assert.equal(u[3], 2)
            assert.equal(u['bar'], 'foo')
        end)

        it('will do nothing to an empty table', function()
            assert.is_true(tx.isempty(tx.transpose({})))
        end)
    end)

    describe('compare', function()
        it('will compare tables using the given function', function()
            local cmp = spy.new(function(x, y) return x == y end)

            local t = {1, 2, foo='bar'}
            local u = {1, 2, foo='bar'}

            assert.is_true(tx.compare(t, u, cmp))
            assert.spy(cmp).was.called()
        end)
    end)

    describe('comparei', function()
        it('will compare tables using the given function', function()
            local cmp = spy.new(function(x, y) return x == y end)

            local t = {1, 2, 3}
            local u = {1, 2, 3}

            assert.is_true(tx.comparei(t, u, cmp))
            assert.spy(cmp).was.called(3)
        end)

        it('will ignore non-integer keys', function()
            local f = function(x, y) return x == y end
            assert.is_true(tx.comparei({1, foo='bar'}, {1, foo='baz'}, f))
        end)
    end)

    describe('compare_unordered', function()
        local cmp

        setup(function()
            cmp = spy.new(function(x, y) return x == y end)
        end)

        it('will compare tables using the given function', function()
            local t = {1, 2, 3}
            local u = {1, 2, 3}

            assert.is_true(tx.compare_unordered(t, u, cmp))
            assert.spy(cmp).was.called()
        end)

        it('will compare ignoring order', function()
            local t = {1,2,3}
            local u = {3,2,1}

            assert.is_true(tx.compare_unordered(t, u, cmp))
        end)
    end)

    describe('find', function()
        it('will find a value in a table', function()
            assert.equal(tx.find({3,4,5}, 5), 3)
        end)

        it('will respect the start parameter', function()
            assert.equal(tx.find({3,4,5,3}, 3, 2), 4)
        end)

        it('supports negative start indexes', function()
            assert.equal(tx.find({3,3,3,3,3}, 3, -2), 4)
        end)
    end)

    describe('rfind', function()
        it('will find a value in a table', function()
            assert.equal(tx.rfind({3,4,5}, 5), 3)
        end)

        it('will respect the start parameter', function()
            assert.equal(tx.rfind({3,4,5,3}, 3, 2), 4)
        end)

        it('supports negative start indexes', function()
            assert.equal(tx.rfind({4,3,3,3,3}, 4, -2), nil)
        end)
    end)

    describe('map', function()
        it('will map a table', function()
            local function map_fn(x)
                return x + 1
            end

            local t = tx.map({1,2,foo=3}, map_fn)

            assert.equal(t[1], 2)
            assert.equal(t[2], 3)
            assert.equal(t['foo'], 4)
        end)

        it('will copy the metatable', function()
            local mt = {}
            local t = {}
            setmetatable(t, mt)

            local u = tx.map(t, function(x) return x end)
            assert.equal(getmetatable(u), mt)
        end)
    end)

    describe('transform', function()
        it('will transform a table in place', function()
            local t = {1,2,foo=3}
            local u = tx.transform(t, function(x) return x + 1 end)

            assert.equal(u, t)
            assert.equal(u[1], 2)
            assert.equal(u[2], 3)
            assert.equal(u['foo'], 4)
        end)
    end)

    describe('mapi', function()
        it('will map only integer keys', function()
            local t = {1,2,foo=3}
            local u = tx.mapi(t, function(x) return x + 1 end)

            assert.equal(u[1], 2)
            assert.equal(u[2], 3)
            assert.equal(u['foo'], nil)
        end)

        it('will copy the metatable', function()
            local mt = {}
            local t = {}
            setmetatable(t, mt)

            local u = tx.mapi(t, function(x) return x end)
            assert.equal(getmetatable(u), mt)
        end)
    end)

end)
