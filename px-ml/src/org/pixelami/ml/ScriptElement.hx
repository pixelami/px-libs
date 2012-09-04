package org.pixelami.ml;

@defaultChildren('codeBlock')
class ScriptElement extends TypeElement
{
    public static var CDATA_PATTERN:EReg = ~/<!\[CDATA\[([^\]]*)\]\]>/m;
    public static var IMPORT_PATTERN:EReg = ~/import [^;]*;/;

    public var block(default,set_block):String;
    function set_block(value:String):String
    {
        block = null;
        if(CDATA_PATTERN.match(value))
        {
            block = CDATA_PATTERN.matched(1);
        }
        return block;
    }

    public var imports(get_imports,null):Array<String>;
    var _imports:Array<String>;

    public function get_imports():Array<String>
    {
        if(_imports == null)
        {

            var pos = 0;
            var input = block.substring(0);

            _imports = [];

            while(IMPORT_PATTERN.match(input))
            {
                _imports.push(IMPORT_PATTERN.matched(0));
                var p = IMPORT_PATTERN.matchedPos();
                pos += p.pos + p.len;
                input = block.substring(pos);
            }
            trace(_imports);
        }

        return _imports;
    }

    public var body(get_body,null):String;
    var _body:String;
    function get_body():String
    {
        if(_body == null)
        {
            _body = block;
            for(i in imports)
            {
                _body = StringTools.replace(_body, i, "");
            }
        }
        return _body;
    }

    public function new()
    {
        super();
    }
}
