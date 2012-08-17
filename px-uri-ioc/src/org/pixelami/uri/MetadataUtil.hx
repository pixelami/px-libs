package org.pixelami.uri;
class MetadataUtil
{
    public static function getMetaInfo(meta:Dynamic, name:String):Array<Dynamic>
    {
        var fields:Array<Dynamic> = [];
        for(f in Reflect.fields(meta))
        {
            var field = Reflect.field(meta,f);
            var metaValue = getFieldMetadata(field,name);
            if(metaValue != null)
            {
                fields.push({name:f, meta:metaValue});
            }

        }
        return fields;
    }

    public static function getFieldMetadata(metaField:Dynamic, name:String)
    {
        //trace("metaField:"+metaField);
        for(m in Reflect.fields(metaField))
        {
            //trace("m: "+m);
            if(m.toLowerCase() == name.toLowerCase())
            {
                return Reflect.field(metaField, m);
            }
        }
        return null;
    }
}
