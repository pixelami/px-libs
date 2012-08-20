package org.pixelami.binding;

import org.pixelami.binding.MacroUtil;
import org.pixelami.binding.MacroUtil;
import org.pixelami.binding.MacroUtil;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

typedef Error = {
    msg:String,
    pos:Position
}

class BindingProcessor
{
    public var bindables:Array<Field>;
    var fields:Array<Field>;
    var currentClass:haxe.macro.Ref<ClassType>;
    var pos:Position;

    var errorStack:Array<Error>;
    var constructor:Field;

    public function new()
    {
        errorStack = [];
    }

    public function process():Array<Field>
    {
        pos = Context.currentPos();
        currentClass = Context.getLocalClass();
        fields = Context.getBuildFields();

        processFields();
        processBindables();
        createTypeIdentifierField();
        processErrors();

        return fields;
    }

    public function processFields()
    {
        bindables = [];

        for(field in fields)
        {
            switch(field.kind)
            {
                case FVar(read,write):
                    for(meta in field.meta)
                    {
                        if(meta.name == "Bindable")
                        {
                            bindables.push(field);
                        }
                    }
                case FFun(f):
                    if(field.name == "new")
                    {
                        constructor = field;
                    }
                default:
            }
        }
    }

    public function processErrors()
    {
        if(errorStack.length == 0) return;

        var errorMsg = "";
        for(e in errorStack)
        {
            var posStr:String = Std.string(e.pos);
            var formattedPos =  posStr.substr(5, posStr.length-6);
            errorMsg += formattedPos + " : " + e.msg + "\n";
        }

        neko.Lib.print(errorMsg);
        Context.error("Encountered error while building "+currentClass, pos);
    }


    public function processBindables()
    {
        if(bindables.length > 0)
        {
            for(field in bindables)
            {
                switch(field.kind)
                {
                    // currently only supporting FVar until flash stack overflow issue is fixed.
                    case FVar(t,exp):

                        var setterName = "set_"+field.name;

                        var setterSource:String = createSetterSrc(field.name);
                        //trace(setterSource);
                        var newPos:Position = MacroUtil.createPositionAfter(field.pos, 1);

                        var setterExpr = Context.parse(setterSource, newPos);

                        var setterFunction = FFun({
                            expr: setterExpr,
                            args: [{name:"value", type:t, opt:false, value:null}],
                            ret: t,
                            params: []
                        });

                        var setterField:Field = {
                            kind: setterFunction,
                            meta: field.meta,
                            name: setterName,
                            doc: field.doc,
                            pos: newPos,
                            access: field.access
                        }

                        var newProp = FProp("default", setterName, t, exp);
                        // replace the old FVar with our newly generated FProp
                        field.kind = newProp;

                        fields.push(setterField);


                    default:
                        Context.error("FProp(get,set,t,e) required", field.pos);
                }
            }

        }
    }

    function createSetterSrc(propertyName:String):String
    {
        var wrapperSrc:String = "{";
        wrapperSrc += "\n\t" + BindingManager.SINGLETON +".updateValue(this, \""+propertyName+"\", value);";
        wrapperSrc += "\n\treturn "+ propertyName +" = value;";
        wrapperSrc += "\n}";
        return wrapperSrc;
    }

    /**
     *  Inserts an __ID__ field and modifies constructor to set the __ID__ field to the current ClassType.toString()
     *  This avoids a runtime look up by the BindingManager
    **/
    public function createTypeIdentifierField()
    {
        var newPos = MacroUtil.createPositionBefore(fields[0].pos, 1);
        var idField:haxe.macro.Field = {
            kind: FVar(TPath({ name : "String", pack : [], params : [], sub : null }), null),
            meta: [],
            name: "__ID__",
            doc: null,
            pos: newPos,
            access: [Access.APublic]
        };

        fields.push(idField);

        switch(constructor.kind)
        {
            case FFun(f):
                switch(f.expr.expr)
                {
                    case EBlock(block):

                        //trace(block[0].pos);
                        var p = MacroUtil.createPositionBefore(block[0].pos, 1);
                        var fqcn:String = "\""+currentClass.toString()+"\"";
                        var src:String = "__ID__ = "+fqcn;
                        //trace(src);
                        var expr = Context.parse(src, p);
                        block.unshift(expr);
                    default:
                }
            default:
        }

    }

}
