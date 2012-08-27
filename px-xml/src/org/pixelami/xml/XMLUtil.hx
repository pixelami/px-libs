package org.pixelami.xml;

class XMLUtil
{
    public static function parseHexValue(value:String):Int
    {
        return Std.parseInt(value.substr(1, value.length));
    }

    public static function parsePercentageValue(value:String):Float
    {
        return Std.parseFloat(value.substr(0, value.length - 1));
    }
}
