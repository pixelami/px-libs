package org.pixelami.binding;

import org.pixelami.binding.BindingType;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;


class MacroUtil
{

    public static function createPositionAfter(pos:Position, offset:Int):Position
    {
        var posInfo = Context.getPosInfos(pos);
        var newPos = {
        min: posInfo.max + offset,
        max: posInfo.max + offset,
        file: posInfo.file
        };

        return Context.makePosition(newPos);
    }

    public static function createPositionBefore(pos:Position, offset:Int):Position
    {
        var posInfo = Context.getPosInfos(pos);
        var newPos = {
        min: posInfo.min - offset,
        max: posInfo.min - offset,
        file: posInfo.file
        };

        return Context.makePosition(newPos);
    }

    public static function resolveFieldType(field:Field):Type
    {
        switch(field.kind)
        {
            case FVar(t,e):

                switch(t)
                {
                    case TPath(p):

                        return Context.getType(p.name);

                    default:
                        trace("type:" + Std.string(t));
                }

            case FProp(get, set, t,e):

                switch(t)
                {
                    case TPath(p):

                        return Context.getType(p.name);

                    default:
                        trace("type:" + Std.string(t));
                }


            default:
                trace("field:" + field.kind);
        }
        return null;
    }

    public static function processErrors(errors:Array<BindingError>, pos:Position)
    {
        var errorMsg:String = "";
        for(e in errors)
        {
            var posStr:String = Std.string(e.pos);
            var formattedPos =  posStr.substr(5,posStr.length-6);
            errorMsg += formattedPos + " : " + e.msg + "\n";

        }
        neko.Lib.print(errorMsg);
        Context.error("Errors encountered while building view", pos);
    }
}
