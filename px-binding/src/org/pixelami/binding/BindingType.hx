package org.pixelami.binding;

import haxe.macro.Expr;

typedef BindingInfo = {
    type:haxe.macro.Type,
    property:String,
    hostPath:Array<String>,
    pos:Position,
    field:Field
}

typedef BindingError = {
    msg:String,
    pos:haxe.macro.Position
}
