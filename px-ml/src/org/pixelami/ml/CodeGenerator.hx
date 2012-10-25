package org.pixelami.ml;

import org.pixelami.collection.ArraySet;
import org.pixelami.binding.BindingManager;
import org.pixelami.ml.TypeElement;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

typedef IdField = {
    id:String,
    value:String,
    field:String
}

class CodeGenerator
{


    //public static inline var UI_TEMPLATE = '/Users/a/dev/workspaces/pihx/px-libs/px-ml/resource/UIType.hx.template';
    public static inline var UI_TEMPLATE = '/Users/a/dev/workspaces/pihx/px-libs/px-ml/resource/MUIComponent.hx.template';

    public var packagePath:String;
    public var moduleName:String;

    public var publicFields(default,null):Hash<TypeElement>;

    var boundValues:Array<IdField>;
    var bindingHosts:Hash<TypeElement>;
    var bindingListeners:Hash<TypeElement>;

    var typeCount:Hash<Int>;
    var root:TypeElement;

    var classBodyLines:Array<String>;

    var scriptBlock:String;
    var imports:String;

    public function new()
    {
        classBodyLines = [];
        publicFields = new Hash<TypeElement>();
        typeCount = new Hash<Int>();
    }

    public function generate(t:TypeElement)
    {
        boundValues = [];
        root = t;


        generateChildren("this", t);
    }

    function _generate(t:TypeElement, ?parentId:String = null)
    {
        if(Std.is(t, ScriptElement))
        {
            appendCodeBlock(cast t);
            return;
        }

        var id:String = makeId(t);

        trace("propertValueMap: "+t.propertyValueMap);
        generateType(id, t);
        generateChildren(id, t);
        if(parentId != null)
        {
            // TODO this needs to be overridable to be able support different component libraries
			// The alternative is to extend the components to all support set_children property
			// so that they can handle adding children internally. Actually for runtime ml this is necessary.
            //append(parentId + ".addChild(" +id+ ")");
            append(parentId + ".addComponent(" +id+ ")");
        }
    }

    function generateChildren(id:String, t:TypeElement)
    {
        trace(t);
        //if(Reflect.hasField(t, "children"))
        {
            for(c in t.children)
            {
                _generate(c, id);
            }
        }

    }

    function appendCodeBlock(element:ScriptElement)
    {
        //trace(element);
        //trace("codeBlock: "+element.block);
        imports = element.imports.join("\n");
        scriptBlock = element.body;
    }

    function makeId(t:TypeElement):String
    {
        if(t.idField != null)
        {
            publicFields.set(t.idField, t);
            return t.idField;
        }

        var count = 0;
        if(!typeCount.exists(t.typeInfo.elementName))
        {
            typeCount.set(t.typeInfo.elementName, count);
        }
        else
        {
            count = typeCount.get(t.typeInfo.elementName) + 1;
        }
        return getInstanceName(t) + Std.string(count);
    }

    public function getInstanceName(t:TypeElement):String
    {
        var name = t.typeInfo.elementName;
        var idx = name.indexOf(":");
        if(idx > -1)
        {
            name = name.substring(idx+1, name.length);
        }
        name = name.charAt(0).toLowerCase() + name.substr(1, name.length);
        return name;
    }

    function append(line:String)
    {
        //code += line + ";\n";
        classBodyLines.push(line);
    }

    function getChildrenBody():String
    {
        var indent:String = "        ";
        var lines:Array<String> = [];
        for(l in classBodyLines)
        {
            lines.push(indent + l + ";");
        }
        return lines.join("\n");
    }

    function generateType(id:String, t:TypeElement)
    {
        append(generateConstructor(id, t));
        for(f in t.propertyValueMap.keys())
        {
            var tv:FieldValue = t.propertyValueMap.get(f);
            generateValue(id, f, tv, t);
        }
    }

    function generateConstructor(id:String, t:TypeElement):String
    {
        if(t.idField == null)  return "var " + id + " = new "+t.typeInfo.typeName+"()";
        return id + " = new "+t.typeInfo.typeName+"()";
    }

    function generateValue(id:String, field:String, fieldValue:FieldValue, owner:TypeElement)
    {
        trace("generating: "+fieldValue.value);
        var v:Dynamic = fieldValue.value;
		trace(fieldValue.field);
        if(fieldValue.field == null) return;

		if(Std.is(v, TypeElement))
		{
			var typeElement:TypeElement = cast v;
			v = makeId(typeElement);
			generateType(v,typeElement);

		}

        switch(fieldValue.field.type)
        {
            case TInst(t, params):

                var c:ClassType = t.get();
			    trace("generate "+c.name);
                switch(c.name)
                {
                    case "String":

                        var stringValue = cast(fieldValue.value, String);
                        if(stringValue != null && stringValue.charAt(0) == "{" && stringValue.charAt(stringValue.length -1) == "}")
                        {
                            boundValues.push({id:id, value:fieldValue.value, field:field});
                        }

                        v = "\"" + fieldValue.value + "\"";

                    case "Float":

                        if(StringTools.endsWith(fieldValue.value, "%"))
                        {
                            v = null;
                            var val:String = fieldValue.value.substr(0, fieldValue.value.length - 1);
                            assignPercentageValue( id, field, val, owner );
                            return;
                        }

                    default:
                }
            default:

        }

        append(id + "." + field + " = " + v);
    }


    function assignPercentageValue(id:String, field:String, value:String, owner:TypeElement)
    {
        var f:ClassField = owner.typeInfo.fields.get(field);

        for(m in f.meta.get())
        {
            if(m.name == "percentageProxy")
            {
                var proxyField:haxe.macro.Expr =  m.params[0];
                switch(proxyField.expr)
                {
                    case ExprDef.EConst(c):
                        switch(c)
                        {
                            case CString(s):

                                append(id + "." + s + " = " + value );

                            default:
                        }

                    default:
                }
            }
        }
    }

    function getPublicVars():String
    {
        var indent:String = "    ";
        var lines:Array<String> = [];
        for(f in publicFields.keys())
        {
            var t:TypeElement = publicFields.get(f);
            lines.push(indent + "public var " + f + ":" + t.typeInfo.typeName + ";");
        }
        return lines.join("\n");
    }

    function getBindables():String
    {

        var bindablesMap:ArraySet<IdField> = new ArraySet<IdField>();

        for(idField in boundValues)
        {
            var value:String = getValueFromBinding(idField.value);
            var segs = value.split(".");
            var property = segs.shift();
            //if(!publicFields.exists(property)) throw "Property not found: "+property;
            trace(segs);
            bindablesMap.add(property, idField);
        }

        var bindableSource:Array<String> = [];

        for(bindable in bindablesMap.keys())
        {
            var idFields:Array<IdField> = bindablesMap.get(bindable);

            for(idField in idFields)
            {

                var src:String = createBindingRegistrationSource(bindable, idField);
                bindableSource.push(src);
            }

        }
        return bindableSource.join("\n");
    }

    function getImports()
    {
        return imports == null ? "" : imports;
    }

    function getValueFromBinding(binding:String):String
    {
        var val:String = binding.substr(1, binding.length - 2);
        return val;
    }


    function createBindingRegistrationSource(id:String, idField:IdField)
    {
        trace(id);
        trace(idField);
        var targetPath = idField.id + "." + idField.field;
        var sourcePath = getValueFromBinding(idField.value);
        var sourceProperty = sourcePath.split(".").pop();
        var src:String = "public var "+id+"(default, set_"+id+"):Dynamic;\n";
        src += "function set_"+id+"(value)\n";
        src += "{\n";
        src += "    "+BindingManager.CREATE_BINDING + "(this, \"" + targetPath + "\", value, \"" + sourceProperty + "\");\n";
        src += "    return "+id+" = value;\n";
        src += "}\n";
        trace(src);
        return src;
    }


    public function toClassString():String
    {
        var template:String = neko.io.File.getContent(UI_TEMPLATE);
        var classString = StringTools.replace(template, "${package}", packagePath);
        classString = StringTools.replace(classString, "${className}", moduleName);
        classString = StringTools.replace(classString, "${extendedComponent}", root.typeInfo.typeName);
        classString = StringTools.replace(classString, "${constructorBody}", "");
        classString = StringTools.replace(classString, "${bindings}", getBindables());
        classString = StringTools.replace(classString, "${publicVars}", getPublicVars());
        classString = StringTools.replace(classString, "${classBody}", getChildrenBody());
        classString = StringTools.replace(classString, "${scriptBlock}", "");
        classString = StringTools.replace(classString, "${imports}", getImports());
        return classString;
    }
}
