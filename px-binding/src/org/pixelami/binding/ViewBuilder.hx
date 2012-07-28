package org.pixelami.binding;

import haxe.macro.Expr;
import haxe.macro.Context;

class ViewBuilder
{
    // TODO enable switching of ViewProcessor implementation with -D compiler flags

    public static function build():Array<Field>
    {
        var processor:ViewProcessor = new ViewProcessor();
        return processor.process();
    }
}
