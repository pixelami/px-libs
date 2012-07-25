package org.pixelami.binding;

import haxe.macro.Expr;
import haxe.macro.Context;

class BindingBuilder
{
    public function new()
    {
    }

    public static function build():Array<Field>
    {
        //trace("Building model " + Context.getLocalClass());

        var processor:BindingProcessor = new BindingProcessor();
        processor.pos = Context.currentPos();
        processor.currentClass = Context.getLocalClass();
        processor.fields = Context.getBuildFields();

        processor.processFields();
        processor.processBindables();
        processor.createTypeIdentifierField();
        processor.processErrors();

        return processor.fields;
    }
}
