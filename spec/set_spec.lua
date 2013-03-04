local set = require("set")

describe('The set module', function()
    describe('intersection', function()
        it('will calculate the intersection between two tables', function()
            assert.same(
                {three=3},
                set.intersection({one=1,two=2,three=3}, {three=3, four=4})
            )
        end)

        it('will handle empty tables', function()
            assert.same({}, set.intersection({one=1}, {}))
            assert.same({}, set.intersection({}, {one=1}))
            assert.same({}, set.intersection({}, {}))
        end)
    end)

    describe('union', function()
        it('will calculate the union of two tables', function()
            assert.same(
                {one=1, two=2, three=3},
                set.union({one=1}, {two=2, three=3})
            )
        end)

        it('will handle empty tables', function()
            assert.same({one=1}, set.union({one=1}, {}))
            assert.same({one=1}, set.union({}, {one=1}))
            assert.same({}, set.union({}, {}))
        end)
    end)

    describe('difference', function()
        it('will calculate the difference between two tables', function()
            assert.same({two=2}, set.difference({one=1, two=2}, {one=1}))
            assert.same({}, set.difference({one=1, two=2}, {one=1, two=2}))
        end)

        it('will handle empty tables', function()
            assert.same({}, set.difference({}, {}))
            assert.same({one=1}, set.difference({one=1}, {}))
        end)

        it('is not symmetric', function()
            assert.same({}, set.difference({}, {one=1}))
        end)
    end)

    describe('symmetric_difference', function()
        it('will calculate the difference between two tables', function()
            assert.same({two=2}, set.symmetric_difference({one=1, two=2}, {one=1}))
            assert.same({}, set.symmetric_difference({one=1, two=2}, {one=1, two=2}))
        end)

        it('will handle empty tables', function()
            assert.same({}, set.symmetric_difference({}, {}))
            assert.same({one=1}, set.symmetric_difference({one=1}, {}))
        end)

        it('is symmetric', function()
            assert.same({one=1}, set.symmetric_difference({}, {one=1}))
        end)
    end)

    describe('issubset', function()
        it('will check for a subset', function()
            assert.is_true(set.issubset({one=1}, {one=1, two=2}))
            assert.is_false(set.issubset({three=3}, {one=1, two=2}))
        end)

        it('will support empty tables', function()
            assert.is_true(set.issubset({}, {}))
            assert.is_true(set.issubset({}, {one=1}))
            assert.is_false(set.issubset({one=1}, {}))
        end)
    end)

    describe('isdisjoint', function()
        it('will check for disjointedness', function()
            assert.is_true(set.isdisjoint({one=1}, {two=2}))
            assert.is_false(set.isdisjoint({one=1}, {one=1, two=2}))
        end)

        it('will handle empty tables', function()
            assert.is_true(set.isdisjoint({}, {}))
            assert.is_true(set.isdisjoint({one=1}, {}))
            assert.is_true(set.isdisjoint({}, {one=1}))
        end)
    end)

    describe('equal', function()
        it('will compare two sets', function()
            assert.is_true(set.equal({one=1}, {one=1}))
            assert.is_false(set.equal({one=1, two=2}, {one=1}))
            assert.is_false(set.equal({one=1}, {one=1, two=2}))
        end)

        it('will handle empty tables', function()
            assert.is_true(set.equal({}, {}))
            assert.is_false(set.equal({one=1}, {}))
            assert.is_false(set.equal({}, {one=1}))
        end)
    end)

    describe('The set object', function()
        it('will create a set object from a list-like table', function()
            local s = set.makeset({4,5,3,6})

            assert.is_true(s[3])
            assert.is_true(s[4])
            assert.is_true(s[5])
            assert.is_true(s[5])
        end)

        it('will have a sensible string representation', function()
            local s = set.makeset({4,5,3,6})

            assert.equal('[3, 4, 5, 6]', tostring(s))
        end)

        it('has appropriate metamethods', function()
            local ret
            local s = set.makeset({4,5,3,6})
            local t = set.makeset({4,5,3,6})

            assert.is_true(s == t)

            assert.equal(4, s:len())
            if string.sub(_VERSION, 5) == '5.2' then
                assert.equal(4, #s)
            end

            ret = set.makeset({3}) + set.makeset({4})
            assert.is_true(ret[3])
            assert.is_true(ret[4])

            ret = set.makeset({3,4}) * set.makeset({4})
            assert.is_falsy(ret[3])
            assert.is_true(ret[4])

            ret = set.makeset({3,4}) - set.makeset({4,5})
            assert.is_true(ret[3])
            assert.is_falsy(ret[5])
            assert.is_falsy(ret[4])

            ret = set.makeset({3,4}) ^ set.makeset({4,5})
            assert.is_true(ret[3])
            assert.is_true(ret[5])
            assert.is_falsy(ret[4])

            ret = set.makeset({3}) < set.makeset({3,4,5})
            assert.is_true(ret)
        end)

        it('has methods on the returned object', function()
            local s = set.makeset()

            assert.is_true(s:isempty())
        end)
    end)
end)
