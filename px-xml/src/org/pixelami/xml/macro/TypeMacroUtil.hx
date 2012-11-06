package org.pixelami.xml.macro;

import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;

class TypeMacroUtil
{
    /**
     * @arg fully qualified className
     * @return TypeInfo object
     *
     * Given a fully qualified class name the Type will have type info metadata added to its fields
     * Also a TypeInfo object is returned containing the typeName and a hash of fieldNames and Types
    **/
    public static function typeInfo(typeName:String):MacroTypeInfo
    {
        var type:Null<haxe.macro.Type> = null;
        try
        {
            type = Context.getType(typeName);
            //trace("Type: "+type);
        }
        catch(e:Dynamic)
        {
            trace(e);
        }
        if(type == null) return null;

        var typeInfo:MacroTypeInfo = new MacroTypeInfo();
        typeInfo.type = type;
        typeInfo.typeName = typeName;


        switch(type)
        {
            case TInst(classType, params):
                processType(classType.get(), typeInfo);

			case TType(defType, params):
				var t = haxe.macro.Context.follow(defType.get().type);

				switch(t)
				{
					case TInst(classType, params):
						processType(classType.get(), typeInfo);
					default:
				}

			case TDynamic(t):
				trace("TDynamic: " + t);

            default:
        }

        return typeInfo;
    }

	static function processType(type:haxe.macro.Type.ClassType, typeInfo:MacroTypeInfo, ?originalName:String)
	{
		var classType:ClassType = type;

		typeInfo.defaultPropertyField = getDefaultChildren(type);

		var fields:Array<ClassField> = classType.fields.get();

		var s = classType.superClass;
		while(s != null)
		{
			var _t:ClassType = s.t.get();
			typeInfo.inheritanceChain.push(_t.pack.join(".") + "." + _t.name);
			fields = fields.concat(_t.fields.get());
			s = _t.superClass;
		}



		for(field in fields)
		{
			var fieldMetaAccess:MetaAccess = field.meta;
			//trace(field);
			switch(field.type)
			{
				case TInst(fieldType, params):

					var fieldType:ClassType = fieldType.get();
					//trace("fieldType:"+fieldType.name);
					if(!fieldMetaAccess.has("type"))
					{
						var fqcn = fieldType.pack.join(".") + "." + fieldType.name;
						fieldMetaAccess.add("type", [{expr:EConst(CString(fqcn)),pos:classType.pos}], classType.pos);
						//fieldMetaAccess.add("type", [{expr:fieldType.name, pos:classType.pos}], classType.pos);
					}
				/*
				case TDynamic(t):
					//trace(field);
					trace("TDynamic: " + t + ", field: "+field.name); */

				default:
			}
			//trace("adding "+field.name);
			typeInfo.fields.set(field.name, field);
		}
	}

	static function getDefaultChildren(classType:haxe.macro.ClassType):String
	{
		var metaAccess:haxe.macro.MetaAccess = classType.meta;
		if(metaAccess.has("defaultProperty"))
		{
			var meta:haxe.macro.Metadata = metaAccess.get();
			for(m in meta)
			{
				if(m.name == "defaultProperty")
				{
					trace(m.params);
					var e:haxe.macro.Expr = m.params[0];
					switch(e.expr)
					{
						case EConst(c): switch(c){
							case CString(s): return s;
							default:
						}
						default:
					}
					break;
				}
			}
		}
		return null;
	}


    @:macro public static function mTypeInfo(expr:Expr):Expr
    {
        var pos = Context.currentPos();
        switch(expr.expr)
        {
            case EConst(c):
                switch(c)
                {
                    case CString(s):
                        typeInfo(s);
                    default:
                }
            default:
        }
        return expr;
    }

}
