package org.pixelami.uri.macro;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

class ContextBuilder
{
    static function build()
    {
        var localClass:haxe.macro.Ref<ClassType> = Context.getLocalClass();
        trace(Context.getLocalType());
        trace(localClass);
        //var type:ClassType = localClass.get();

        //var meta:MetaAccess = type.meta;
        //trace(meta);
        //return null;
    }
}
