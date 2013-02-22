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
            assert.same(tx.sort(t), t)
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

            assert.same({'foo', 'asdf'}, ks)
        end)

        it('will return the keys of a list-like table', function()
            local ks = tx.keys({1, 2})

            assert.same({1,2}, ks)
        end)
    end)

    describe('values', function()
        it('will return the values of a table', function()
            local vs = tx.values({foo='bar', asdf='baz'})

            assert.same({'bar', 'baz'}, vs)
        end)

        it('will return the values of a list-like table', function()
            local vs = tx.values({3, 4})

            assert.same({3, 4}, vs)
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

            assert.same({1,2,foo='bar'}, t)
        end)

        it('will overwrite the existing values', function()
            local t = {9, foo='gone'}
            local u = {1, foo='bar'}

            tx.update(t, u)

            assert.same({1,foo='bar'}, t)
        end)
    end)

    describe('range', function()
        local function assert_range(t, ...)
            local ra = tx.range(...)
            assert.same(t, ra)
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

            assert.same({1,[3]=2,bar='foo'}, u)
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

        it('will default to comparing for equality', function()
            assert.is_true(tx.compare({1,2,3}, {1,2,3}))
            assert.is_false(tx.compare({1,2,3}, {1,2,4}))
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

        it('will default to comparing for equality', function()
            assert.is_true(tx.comparei({1,2,3}, {1,2,3}))
            assert.is_false(tx.comparei({1,2,3}, {1,2,4}))
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

        it('will default to comparing for equality', function()
            assert.is_true(tx.compare_unordered({1,2,3}, {1,2,3}))
            assert.is_false(tx.compare_unordered({1,2,3}, {1,2,4}))
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

            assert.same({2,3,foo=4}, t)
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

            assert.same({2,3,foo=4}, u)
            assert.equal(u, t)
        end)
    end)

    describe('mapi', function()
        it('will map only integer keys', function()
            local t = {1,2,foo=3}
            local u = tx.mapi(t, function(x) return x + 1 end)

            assert.same({2,3,foo=nil}, u)
        end)

        it('will copy the metatable', function()
            local mt = {}
            local t = {}
            setmetatable(t, mt)

            local u = tx.mapi(t, function(x) return x end)
            assert.equal(getmetatable(u), mt)
        end)
    end)

    describe('mapn', function()
        it('will map a single table', function()
            local ret = tx.mapn(function(x) return x + 1 end, {1,2,3})
            assert.same({2,3,4}, ret)
        end)

        it('will map multiple tables', function()
            local ret = tx.mapn(function(x, y) return x + y end, {1,2,3}, {3,2,1})
            assert.same({4,4,4}, ret)
        end)

        it('properly handles no tables', function()
            assert.same(tx.mapn(function() end, {}), {})
        end)

        it('will truncate to the shortest list', function()
            local ret = tx.mapn(function(x, y) return x + y end, {1,2,3}, {1,2})
            assert.same({2,4}, ret)
        end)
    end)

    describe('reduce', function()
        local function add(x, y) return x + y end

        it('will reduce a simple sequence', function()
            assert.equal(6, tx.reduce({1,2,3}, add))
        end)

        it('will reduce with a default value', function()
            assert.equal(10, tx.reduce({1,2,3}, add, 4))
        end)

        it('will reduce an empty sequence to nil', function()
            assert.equal(nil, tx.reduce({}, add))
        end)

        it('will reduce an empty sequence with initial to initial', function()
            assert.equal(1, tx.reduce({}, add, 1))
        end)

        it('is also aliased as "foldl"', function()
            assert.equal(tx.reduce, tx.foldl)
        end)
    end)

    describe('zip', function()
        local function assert_zip(res, num, ...)
            local z = tx.zip(...)
            assert.equal(#z, num)
            for i, v in ipairs(z) do
                assert.same(res[i], v)
            end
        end

        it('wlll zip together two lists', function()
            assert_zip({{1, 10}, {2, 11}, {3, 12}}, 3, {1, 2, 3}, {10, 11, 12})
        end)

        it('will truncate to the shortest length', function()
            assert_zip({{1,11}, {2, 12}}, 2, {1,2,3}, {11,12})
        end)

        it('will handle empty lists', function()
            assert_zip({}, 0, {}, {})
            assert_zip({}, 0, {1}, {})
            assert_zip({}, 0, {}, {2})
        end)
    end)

    describe('zipn', function()
        local function assert_zipn(res, num, ...)
            local z = tx.zipn(...)
            assert.equal(#z, num)
            for i, v in ipairs(z) do
                assert.same(res[i], v)
            end
        end

        it('wlll zip together two lists', function()
            assert_zipn({{1, 10}, {2, 11}, {3, 12}}, 3, {1, 2, 3}, {10, 11, 12})
        end)

        it('will truncate to the shortest length', function()
            assert_zipn({{1,11}, {2, 12}}, 2, {1,2,3}, {11,12})
        end)

        it('will handle empty lists', function()
            assert_zipn({}, 0, {}, {})
            assert_zipn({}, 0, {1}, {})
            assert_zipn({}, 0, {}, {2})
        end)

        it('can handle multiple lists', function()
            assert_zipn({{1,2,3},{4,5,6}}, 2, {1,4}, {2,5}, {3,6})
        end)
    end)

    -- Note that this also tests normalize_slice too.
    describe('sub', function()
        local t = {1,2,3,4,5,6,7,8,9,10}

        it('will extract simple ranges from the list', function()
            assert.same({3,4,5}, tx.sub(t, 3, 5))
        end)

        it('will extract given just a start', function()
            assert.same({8,9,10}, tx.sub(t, 8))
        end)

        it('will extract given just a end', function()
            assert.same({1,2,3}, tx.sub(t, nil, 3))
        end)

        it('supports using negative start indexes', function()
            assert.same({8,9,10}, tx.sub(t, -3))
        end)

        it('supports using negative end indexes', function()
            assert.same({1,2,3}, tx.sub(t, nil, -8))
        end)

        it('supports both negative indexes', function()
            assert.same({8,9}, tx.sub(t, -3, -2))
        end)
    end)

end)
