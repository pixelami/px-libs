package org.pixelami.binding;

import haxe.macro.Expr;
import haxe.macro.Context;

class BindingBuilder
{
    // TODO enable switching of BindingProcessor implementation with -D compiler flags

    public static function build():Array<Field>
    {
        var processor:BindingProcessor = new BindingProcessor();
        return processor.process();
    }
}
