local sx = require('stringx')

describe("String extension library", function()
    describe('escape_pattern', function()
        it('should properly escape strings', function()
            assert.equal('%%asdf', sx.escape_pattern('%asdf'))
        end)
    end)

    describe('isalpha', function()
        it('should detect alphabetic strings', function()
            assert.is_true(sx.isalpha('asdfASDF'))
        end)

        it('should return false for others', function()
            assert.is_false(sx.isalpha('asdf1'))
        end)
    end)

    describe('isdigit', function()
        it('should detect numeric strings', function()
            assert.is_true(sx.isdigit('1234'))
        end)

        it('should return false for others', function()
            assert.is_false(sx.isdigit('1234a'))
        end)
    end)

    describe('isalnum', function()
        it('should detect alphanumeric strings', function()
            assert.is_true(sx.isalnum('asdf123'))
        end)

        it('should return false for others', function()
            assert.is_false(sx.isalnum('asdf!123'))
        end)
    end)

    describe('isspace', function()
        it('should detect strings that are whitespace', function()
            assert.is_true(sx.isspace('  \r\n\t'))
        end)

        it('should return false for others', function()
            assert.is_false(sx.isspace('  asd  '))
        end)
    end)

    describe('islower', function()
        it('should detect strings that are lowercase', function()
            assert.is_true(sx.islower('lowercase'))
        end)

        it('should return false for others', function()
            assert.is_false(sx.islower('not LOWERcase'))
        end)
    end)

    describe('isupper', function()
        it('should detect strings that are lowercase', function()
            assert.is_true(sx.isupper('UPPERCASE'))
        end)

        it('should return false for others', function()
            assert.is_false(sx.isupper('NOT upperCASE'))
        end)
    end)

    describe('at', function()
        it('will return the character at the given index', function()
            assert.equal('b', sx.at('foobar', 4))
        end)
    end)

    describe('shorten', function()
        it('should not change short strings', function()
            assert.equal('foo', sx.shorten('foo', 10))
        end)

        it('should shorten to just dots', function()
            assert.equal('', sx.shorten('bar', 0))
            assert.equal('.', sx.shorten('bar', 1))
            assert.equal('..', sx.shorten('bar', 2))
        end)

        it('should shorten long strings', function()
            assert.equal('foo...', sx.shorten('foobar123', 6))
        end)

        it('should shorten in reverse properly', function()
            assert.equal('...123', sx.shorten('foobar123', 6, true))
        end)

        it('properly handles exact-sized strings', function()
            assert.equal('foobar', sx.shorten('foobar', 6))
            assert.equal('foobar', sx.shorten('foobar', 6, true))
        end)
    end)

    describe('capitalize', function()
        it('will capitalize a string', function()
            assert.equal('Foobar', sx.capitalize('foobar'))
        end)

        it('will handle short strings', function()
            assert.equal('F', sx.capitalize('f'))
            assert.equal('', sx.capitalize(''))
        end)
    end)

    describe('chomp', function()
        it('will trim all types of newlines', function()
            assert.equal('foobar', sx.chomp('foobar\r'))
            assert.equal('foobar', sx.chomp('foobar\n'))
            assert.equal('foobar', sx.chomp('foobar\r\n'))
            assert.equal('foobar\n', sx.chomp('foobar\n\r'))
        end)

        it('will trim user-defined separators', function()
            assert.equal('fooba', sx.chomp('foobar', 'r'))
            assert.equal('foobaq', sx.chomp('foobaq', 'r'))
        end)
    end)

    describe('chop', function()
        it('will remove the last character', function()
            assert.equal('fooba', sx.chop('foobar'))
        end)

        it('will remove a trailing newline pair', function()
            assert.equal('foobar', sx.chop('foobar\r\n'))
        end)
    end)

    describe('delete', function()
        it('will remove a single character from the string', function()
            assert.equal('fbar', sx.delete('foobar', 'o'))
        end)

        it('will remove multiple characters from the string', function()
            assert.equal('fbr', sx.delete('foobar', {'o', 'a'}))
        end)
    end)

    describe('lstrip', function()
        it('will strip whitespace by default', function()
            assert.equal('asdf', sx.lstrip('   asdf'))
        end)

        it('will strip user-given patterns', function()
            assert.equal('foobar', sx.lstrip('aaaaaafoobar', 'a+'))
        end)
    end)

    describe('rstrip', function()
        it('will strip whitespace by default', function()
            assert.equal('asdf', sx.rstrip('asdf     '))
        end)

        it('will strip user-given patterns', function()
            assert.equal('foobar', sx.rstrip('foobaraaaaaaaa', 'a+'))
        end)
    end)

    describe('strip', function()
        it('will strip whitespace by default', function()
            assert.equal('asdf', sx.strip('  asdf  '))
        end)

        it('will strip user-given patterns', function()
            assert.equal('foobar', sx.strip('aaaafoobaraaaa', 'a+'))
        end)
    end)

    describe('lfind', function()
        it('will find a given pattern', function()
            assert.equal(2, sx.lfind('foobar', 'o'))
        end)

        it('will respect the "first" parameter', function()
            assert.equal(3, sx.lfind('foobar', 'o', 3))
        end)

        it('will respect the "last" parameter', function()
            assert.equal(3, sx.lfind('ababab', 'ab', 2, 5))
            assert.equal(nil, sx.lfind('ababab', 'ab', 2, 3))
        end)

        it('will find multi-character strings', function()
            assert.equal(4, sx.lfind('foobar', 'bar'))
        end)

        it('will return nil on failure', function()
            assert.equal(nil, sx.lfind('foobar', 'q'))
        end)
    end)

    describe('rfind', function()
        it('will find a given pattern', function()
            assert.equal(3, sx.rfind('foobar', 'o'))
        end)

        it('will respect the "first" parameter', function()
            assert.equal(3, sx.rfind('foobar', 'o', 3))
        end)

        it('will respect the "last" parameter', function()
            assert.equal(nil, sx.rfind('asdfqwerty', 'y', 2, 5))
            assert.equal(3, sx.rfind('ababab', 'ab', 2, 5))
        end)

        it('will find multi-character strings', function()
            assert.equal(4, sx.rfind('foobar', 'bar'))
        end)

        it('will return nil on failure', function()
            assert.equal(nil, sx.rfind('foobar', 'q'))
        end)
    end)

    describe('replace', function()
        it('will replace strings', function()
            assert.equal('barbar', sx.replace('foobar', 'foo', 'bar'))
        end)

        it('respects the "count" parameter', function()
            assert.equal('71223344', sx.replace('11223344', '1', '7', 1))
        end)

        it('will replace pattern characters', function()
            assert.equal('fooqqbar', sx.replace('foo%abar', '%a', 'qq'))
            assert.equal('fooqqbar', sx.replace('foo[a-z].?bar', '[a-z].?', 'qq'))
        end)
    end)

    describe('endswith', function()
        it('will check simple strings', function()
            assert.is_true(sx.endswith('foobar', 'bar'))
            assert.is_false(sx.endswith('foobar', 'qar'))
        end)

        it('will check multiple suffixes', function()
            assert.is_false(sx.endswith('foobar', {'aa', 'bb'}))
            assert.is_true(sx.endswith('foobar', {'aa', 'bb', 'bar'}))
        end)
    end)

    describe('startswith', function()
        it('will check simple strings', function()
            assert.is_true(sx.startswith('foobar', 'foo'))
            assert.is_false(sx.startswith('foobar', 'qoo'))
        end)

        it('will check multiple suffixes', function()
            assert.is_false(sx.startswith('foobar', {'aa', 'bb'}))
            assert.is_true(sx.startswith('foobar', {'aa', 'bb', 'foo'}))
        end)
    end)

    describe('count', function()
        it('will count the number of characters in a string', function()
            assert.equal(1, sx.count('1223334444', '1'))
            assert.equal(0, sx.count('1223334444', '0'))
        end)

        it('respects the "start" parameter', function()
            assert.equal(1, sx.count('1223334444', '2', 3))
        end)

        it('respects the "fin" parameter', function()
            assert.equal(2, sx.count('4444', '4', 2, 3))
        end)
    end)

    describe('partition', function()
        it('will split the string', function()
            local before, match, after = sx.partition('asdf', 's')
            assert.equal('a', before)
            assert.equal('s', match)
            assert.equal('df', after)
        end)

        it('will return blanks if no match', function()
            local before, match, after = sx.partition('asdf', 'q')
            assert.equal('asdf', before)
            assert.equal('', match)
            assert.equal('', after)
        end)

        it('handles matches at string ends', function()
            local before, match, after = sx.partition('asdf', 'f')
            assert.equal('asd', before)
            assert.equal('f', match)
            assert.equal('', after)

            before, match, after = sx.partition('asdf', 'a')
            assert.equal('', before)
            assert.equal('a', match)
            assert.equal('sdf', after)
        end)
    end)

    describe('rpartition', function()
        it('will split the string', function()
            local before, match, after = sx.rpartition('asdfasdf', 'a')
            assert.equal('asdf', before)
            assert.equal('a', match)
            assert.equal('sdf', after)
        end)

        it('will return blanks if no match', function()
            local before, match, after = sx.rpartition('asdf', 'q')
            assert.equal('asdf', before)
            assert.equal('', match)
            assert.equal('', after)
        end)
    end)

    describe('ljust', function()
        it('will justify to the given length', function()
            assert.equal('foo  ', sx.ljust('foo', 5))
        end)

        it('will not truncate longer strings', function()
            assert.equal('foobarbaz', sx.ljust('foobarbaz', 5))
        end)

        it('will pad with the given character', function()
            assert.equal('fooaa', sx.ljust('foo', 5, 'a'))
        end)
    end)

    describe('rjust', function()
        it('will justify to the given length', function()
            assert.equal('  foo', sx.rjust('foo', 5))
        end)

        it('will not truncate longer strings', function()
            assert.equal('foobarbaz', sx.rjust('foobarbaz', 5))
        end)

        it('will pad with the given character', function()
            assert.equal('aafoo', sx.rjust('foo', 5, 'a'))
        end)
    end)

    describe('zfill', function()
        it('will pad to the given length', function()
            assert.equal('00123', sx.zfill('123', 5))
        end)

        it('will not truncate longer strings', function()
            assert.equal('123456', sx.zfill('123456', 5))
        end)
    end)

    describe('join', function()
        it('will join a table', function()
            assert.equal('1,2,3', sx.join(',', {1,2,3}))
        end)

        it('will join with longer strings', function()
            assert.equal('1XYZ2XYZ3', sx.join('XYZ', {1,2,3}))
        end)
    end)
end)
