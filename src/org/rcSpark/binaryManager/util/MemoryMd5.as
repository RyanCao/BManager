package org.rcSpark.binaryManager.util {

import flash.Memory;
import flash.SetDomainMemory;
import flash.utils.ByteArray;

/*
 * MD5
 * flash.Memory
 * Directed by kiwiw3
 * */

public class MemoryMd5 {

    public static var digest:ByteArray;
    static private var hexChars:String = "0123456789abcdef";

    public static function hash(s:String) :String{
        var ba:ByteArray = new ByteArray();
        ba.writeUTFBytes(s);
        return hashBinary(ba);
    }

    public static function hashBytes(s:ByteArray) :String{
        return hashBinary(s);
    }

    public static function hashBinary( sa:ByteArray ):String {
        var a:int = 1732584193;
        var b:int = -271733879;
        var c:int = -1732584194;
        var d:int = 271733878;
//var tmp:int;
        var x0:int;
        var x1:int;
        var x2:int;
        var x3:int;
        var x4:int;
        var x5:int;
        var x6:int;
        var x7:int;
        var x8:int;
        var x9:int;
        var x10:int;
        var x11:int;
        var x12:int;
        var x13:int;
        var x14:int;
        var x15:int;

        var aa:int;
        var bb:int;
        var cc:int;
        var dd:int;

        var rx:Array= createBlocksVector(sa);
        var x:ByteArray = rx[0];

        var len:int = rx[1];

//��ȫ16�ı���λ
        var rest:int = len % 16;
        if(rest>0){
            x.length += rest * 4;
            for ( i = 0; i < rest; i ++) {
//x[int(len + i)] = 0;
                Memory.setI32(0,int(len + i)*4);
            }
        }
// loop over all of the blocks

        for ( var i:int = 0; i < len; i += 16){
            aa = a;
            bb = b;
            cc = c;
            dd = d;

            var t:int = i * 4;
            x0 = Memory.getI32(int(t))
            x1 = Memory.getI32(int(t+ 4))
            x2 = Memory.getI32(int(t+ 8))
            x3 = Memory.getI32(int(t+ 12))
            x4 = Memory.getI32(int(t+ 16))
            x5 = Memory.getI32(int(t+ 20))
            x6 = Memory.getI32(int(t+ 24))
            x7 = Memory.getI32(int(t+ 28))
            x8 = Memory.getI32(int(t+ 32))
            x9 = Memory.getI32(int(t+ 36))
            x10 = Memory.getI32(int(t+ 40))
            x11 = Memory.getI32(int(t+ 44))
            x12 = Memory.getI32(int(t+ 48))
            x13 = Memory.getI32(int(t+ 52))
            x14 = Memory.getI32(int(t+ 56))
            x15 = Memory.getI32(int(t+ 60))


// Round 1
            a = ff( a, b, c, d, x0, 7, -680876936 ); // 1
            d = ff( d, a, b, c, x1, 12, -389564586 ); // 2
            c = ff( c, d, a, b, x2, 17, 606105819 ); // 3
            b = ff( b, c, d, a, x3, 22, -1044525330 ); // 4
            a = ff( a, b, c, d, x4, 7, -176418897 ); // 5
            d = ff( d, a, b, c, x5, 12, 1200080426 ); // 6
            c = ff( c, d, a, b, x6, 17, -1473231341 ); // 7
            b = ff( b, c, d, a, x7, 22, -45705983 ); // 8
            a = ff( a, b, c, d, x8, 7, 1770035416 ); // 9
            d = ff( d, a, b, c, x9, 12, -1958414417 ); // 10
            c = ff( c, d, a, b, x10, 17, -42063 ); // 11
            b = ff( b, c, d, a, x11, 22, -1990404162 ); // 12
            a = ff( a, b, c, d, x12, 7, 1804603682 ); // 13
            d = ff( d, a, b, c, x13, 12, -40341101 ); // 14
            c = ff( c, d, a, b, x14, 17, -1502002290 ); // 15
            b = ff( b, c, d, a, x15, 22, 1236535329 ); // 16

// Round 2
            a = gg( a, b, c, d, x1, 5, -165796510 ); // 17
            d = gg( d, a, b, c, x6, 9, -1069501632 ); // 18
            c = gg( c, d, a, b, x11, 14, 643717713 ); // 19
            b = gg( b, c, d, a, x0, 20, -373897302 ); // 20
            a = gg( a, b, c, d, x5, 5, -701558691 ); // 21
            d = gg( d, a, b, c, x10, 9, 38016083 ); // 22
            c = gg( c, d, a, b, x15, 14, -660478335 ); // 23
            b = gg( b, c, d, a, x4, 20, -405537848 ); // 24
            a = gg( a, b, c, d, x9, 5, 568446438 ); // 25
            d = gg( d, a, b, c, x14, 9, -1019803690 ); // 26
            c = gg( c, d, a, b, x3, 14, -187363961 ); // 27
            b = gg( b, c, d, a, x8, 20, 1163531501 ); // 28
            a = gg( a, b, c, d, x13, 5, -1444681467 ); // 29
            d = gg( d, a, b, c, x2, 9, -51403784 ); // 30
            c = gg( c, d, a, b, x7, 14, 1735328473 ); // 31
            b = gg( b, c, d, a, x12, 20, -1926607734 ); // 32

// Round 3
            a = hh( a, b, c, d, x5, 4, -378558 ); // 33
            d = hh( d, a, b, c, x8, 11, -2022574463 ); // 34
            c = hh( c, d, a, b, x11, 16, 1839030562 ); // 35
            b = hh( b, c, d, a, x14, 23, -35309556 ); // 36
            a = hh( a, b, c, d, x1, 4, -1530992060 ); // 37
            d = hh( d, a, b, c, x4, 11, 1272893353 ); // 38
            c = hh( c, d, a, b, x7, 16, -155497632 ); // 39
            b = hh( b, c, d, a, x10, 23, -1094730640 ); // 40
            a = hh( a, b, c, d, x13, 4, 681279174 ); // 41
            d = hh( d, a, b, c, x0, 11, -358537222 ); // 42
            c = hh( c, d, a, b, x3, 16, -722521979 ); // 43
            b = hh( b, c, d, a, x6, 23, 76029189 ); // 44
            a = hh( a, b, c, d, x9, 4, -640364487 ); // 45
            d = hh( d, a, b, c, x12, 11, -421815835 ); // 46
            c = hh( c, d, a, b, x15, 16, 530742520 ); // 47
            b = hh( b, c, d, a, x2, 23, -995338651 ); // 48

// Round 4
            a = ii( a, b, c, d, x0, 6, -198630844 ); // 49
            d = ii( d, a, b, c, x7, 10, 1126891415 ); // 50
            c = ii( c, d, a, b, x14, 15, -1416354905 ); // 51
            b = ii( b, c, d, a, x5, 21, -57434055 ); // 52
            a = ii( a, b, c, d, x12, 6, 1700485571 ); // 53
            d = ii( d, a, b, c, x3, 10, -1894986606 ); // 54
            c = ii( c, d, a, b, x10, 15, -1051523 ); // 55
            b = ii( b, c, d, a, x1, 21, -2054922799 ); // 56
            a = ii( a, b, c, d, x8, 6, 1873313359 ); // 57
            d = ii( d, a, b, c, x15, 10, -30611744 ); // 58
            c = ii( c, d, a, b, x6, 15, -1560198380 ); // 59
            b = ii( b, c, d, a, x13, 21, 1309151649 ); // 60
            a = ii( a, b, c, d, x4, 6, -145523070 ); // 61
            d = ii( d, a, b, c, x11, 10, -1120210379 ); // 62
            c = ii( c, d, a, b, x2, 15, 718787259 ); // 63
            b = ii( b, c, d, a, x9, 21, -343485551 ); // 64

            a += aa;
            b += bb;
            c += cc;
            d += dd;
        }

        digest = new ByteArray()
        digest.writeInt(a);
        digest.writeInt(b);
        digest.writeInt(c);
        digest.writeInt(d);
        digest.position = 0;
// Finish up by concatening the buffers with their hex output
        return toHex( a ) + toHex( b ) + toHex( c ) + toHex( d );
    }

    public static  function toHex( n:int):String {
        var s:String = "";

        for ( var x:int = 0; x < 4; x++ ) {
            s += hexChars.charAt( ( n >> ( x * 8 + 4 ) ) & 0xF )
                    + hexChars.charAt( ( n >> ( x * 8 ) ) & 0xF );
        }
        return s;
    }

    private static  function rol(num:int, cnt:int):int
    {
        return (num << cnt) | (num >>> (32 - cnt));
    }

    /**
     * ff function
     */
    private static  function ff ( a:int, b:int, c:int, d:int, x:int, s:int, t:int ):int {
        return rol( a + (( b & c ) | ( ~b & d )) + x + t, s ) + b;
    }

    /**
     * gg function
     */
    private static  function gg ( a:int, b:int, c:int, d:int, x:int, s:int, t:int ):int {
        return rol( a + (( b & d ) | ( c & ~d)) + x + t, s ) + b;
    }

    /**
     * hh function
     */
    private static  function hh ( a:int, b:int, c:int, d:int, x:int, s:int, t:int ):int {
        return rol( a + (b ^ c ^ d) + x + t, s ) + b;
    }

    /**
     * ii function
     */
    private static  function ii ( a:int, b:int, c:int, d:int, x:int, s:int, t:int ):int {
        return rol( a + (c ^ ( b | ~d )) + x + t, s ) + b;
    }

    private static  function createBlocksVector( sa:ByteArray ):Array {
        var len:int = sa.length * 8;
        var blen:int=sa.length = (int(( ( ( len + 64 ) >>> 9 ) << 4 ) + 14) + 1) * 4;
        if (sa.length < 1024) {
            sa.length = 1024;
        }
//ApplicationDomain.currentDomain.domainMemory = sa;
        SetDomainMemory(sa);
        for ( var i:int = 0, j:int = 0; i < len; i += 8, j+=4) {

            Memory.setI32(Memory.getI32((i >> 5) * 4) | ( Memory.getByte(j) & 0xFF ), (i >> 5) * 4);
            i+=8
            Memory.setI32(Memory.getI32((i >> 5)*4)|(( Memory.getByte(j+1) & 0xFF) << 8), (i >> 5)*4);
            i+=8
            Memory.setI32(Memory.getI32((i >> 5)*4)|(( Memory.getByte(j+2) & 0xFF) << 16), (i >> 5)*4);
            i+=8
            Memory.setI32(Memory.getI32((i >> 5)*4)|(( Memory.getByte(j+3) & 0xFF) << 24), (i >> 5)*4);

        }

        Memory.setI32(Memory.getI32((len >> 5) * 4)|(0x80 << ( len % 32 )), (len >> 5) * 4);
        Memory.setI32(len,(int(( ( ( len + 64 ) >>> 9 ) << 4 ) + 14))*4);
        return [sa,int(blen/4)];
    }
}
}