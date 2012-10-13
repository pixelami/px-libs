class ObjectUtil
{
    static inline var INDENT:String = "  ";

    public static function toString(o:Dynamic)
    {
        return "\n" + _toString(o, 0);
    }

    static function _toString(o:Dynamic, indent:Int):String
    {
        var str:String = "";
        var type = Type.typeof(o);

        switch(type)
        {
            case TObject:

            ++indent;

            str += openObject();
            str += "\n";
            for(field in Reflect.fields(o))
            {
                str += setIndent(indent);
                str += printField(field);
                str += " : ";
                str += _toString(Reflect.field(o, field), indent);
                str += "\n";

            }

            --indent;
            str += setIndent(indent);
            str += closeObject();


            case TClass(t):

            var className = Type.getClassName(t);
            if(className == "Array")
            {


                var a:Array<Dynamic> = cast o;
                str += printSquare("[ ");
                for(item in a)
                {
                    str += _toString(item, indent);
                }
                str += printSquare(" ]");

            }
            if(className == "String")
            {
                str += printString('"' + o + '"');
            }


            case TUnknown:

            str += o;


            case TNull, TInt, TFunction, TFloat, TBool:

            str += o;


            case TEnum(v):

            str += o;
        }

        return str;
    }

    static function setIndent(indent:Int):String
    {
        var ind = "";
        for(i in 0...indent)
        {
            ind += INDENT;
        }
        return ind;
    }

    static function openArray():String
    {

    }

    static function closeArray():String
    {

    }

    static function openObject():String
    {
        return "{ ";
    }

    static function closeObject():String
    {
        return " }";
    }

    static function orange(str:String):String
    {

    }
    static function purple(str:String):String
    {

    }
    static function white(str:String):String
    {

    }
    static function red(str:String):String
    {

    }

    static function printField(field:String):String
    {
        return "\033[33m" + field + "\033[0m";
    }

    static function printBrace(field:String):String
    {
        return "\033[33m" + field + "\033[0m";
    }

    static function printSquare(field:String):String
    {
        return "\033[31m" + field + "\033[0m";
    }

    static function printString(field:String):String
    {
        return "\033[37m" + field + "\033[0m";
    }

    static function printValue(field:String):String
    {
        return "\033[33m" + field + "\033[0m";
    }
}

