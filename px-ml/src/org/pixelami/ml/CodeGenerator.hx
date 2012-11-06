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

	static inline var IFACTORY_DEF:String = "org.pixelami.ml.IFactory";
	static inline var CLASS_FACTORY_IMPL:String = "org.pixelami.ml.ClassFactory";

    //public static inline var UI_TEMPLATE = '/Users/a/dev/workspaces/pihx/px-libs/px-ml/resource/UIType.hx.template';
    public static inline var UI_TEMPLATE = '/Users/a/dev/workspaces/pihx/px-libs/px-ml/resource/MUIComponent.hx.template';
    public static inline var METHOD_TEMPLATE = '/Users/a/dev/workspaces/pihx/px-libs/px-ml/resource/HaxeMethod.template';

	var methodTemplate:String;

    public var packagePath:String;
    public var moduleName:String;
	var classMeta:String;

    public var publicFields(default,null):Hash<TypeElement>;

    var boundValues:Array<IdField>;
    var bindingHosts:Hash<TypeElement>;
    var bindingListeners:Hash<TypeElement>;

    var typeCount:Hash<Int>;
    var root:TypeElement;

    var classBodyLines:Array<String>;

    var scriptBlock:String;
    var imports:String;
	var methods:Array<String>;

    public function new()
    {
        classBodyLines = [];
		methods = [];
        publicFields = new Hash<TypeElement>();
        typeCount = new Hash<Int>();
		classMeta = "";
    }

	function loadTemplates()
	{
		methodTemplate = sys.io.File.getContent(METHOD_TEMPLATE);
	}

    public function generate(t:TypeElement)
    {
        boundValues = [];
        root = t;

		generateProperties("this", t);

        generateChildren("this", t);
    }

    function _generate(t:TypeElement, ?parentId:String = null):String
    {
        if(Std.is(t, ScriptElement))
        {
            appendCodeBlock(cast t);
            return null;
        }

        var id:String = makeId(t);

        //trace("propertValueMap: "+t.propertyValueMap);
        generateType(id, t);
        generateChildren(id, t);
        if(parentId != null)
        {
            // TODO this needs to be overridable to be able support different component libraries
			// The alternative is to extend the components to all support set_children property and just pass
			// array of child objects so that they can handle adding children internally.
			// Actually for runtime ml this is necessary.
            //append(parentId + ".addChild(" +id+ ")");
            //append(parentId + ".addComponent(" +id+ ")");
			//append(parentId + "." + t.defaultPropertyField + " = " + id )
        }
		return id;
    }

    function generateChildren(id:String, t:TypeElement)
    {
		var ids:Array<String> = [];
		for(c in t.children)
		{

			var cid:String = _generate(c, id);

			if(cid != null)
			{
				if(t.defaultPropertyField == null) append(id + ".addChild(" + cid + ")");
				else ids.push(cid);
			}
		}
		if(ids.length > 0) append(id + "." + t.defaultPropertyField + " = [" + ids.join(", ") + "]" );
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
			typeCount.set(t.typeInfo.elementName, count);
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
        generateProperties(id, t);
    }

	function generateProperties(id:String, t:TypeElement)
	{
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
        //trace("generating: "+fieldValue.value);
        var v:Dynamic = fieldValue.value;

		//trace(fieldValue.field);
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
						// assign the literal binding value anyway.
                        v = "\"" + fieldValue.value + "\"";

                    case "Float":

                        if(StringTools.endsWith(fieldValue.value, "%"))
                        {
                            v = null;
                            var val:String = fieldValue.value.substr(0, fieldValue.value.length - 1);
                            assignPercentageValue( id, field, val, owner );
                            return;
                        }
					// TODO this needs to be from the target type
					case "IFactory":

						// TODO - if the value is also a pxml - then it may need to be generated
						// before we use it.... and then we face the potential problem of circular references...
						// The way to handle that is to only load modules after all source has been created.
						v = "new " + CLASS_FACTORY_IMPL + "("+fieldValue.value+")";

                    default:
                }
            default:

        }

		if(owner.hasField(field))
		{
			append(id + "." + field + " = " + v);
		}
		else
		{

			haxe.macro.Context.warning(owner.typeInfo.typeName + " does not contain property '"+ field +"'", haxe.macro.Context.currentPos());
		}
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
		var localBindablesMap:ArraySet<IdField> = new ArraySet<IdField>();
        var bindablesMap:ArraySet<IdField> = new ArraySet<IdField>();

		// TODO mui specific
		var nodeBindings:ArraySet<IdField> = new ArraySet<IdField>();

        for(idField in boundValues)
        {

			var value:String = getValueFromBinding(idField.value);
			var segs = value.split(".");
			var property = segs.shift();

			// does this property already exist in the local instance ?
			//trace("looking for: "+property);
			if(root.hasField(property))
			{
				trace("local var found:  "+property);
				trace("extends: "+root.typeInfo.inheritanceChain);
				if(root.isExtending("mui.core.Node"))
				{
					trace("found local Node binding to: " + idField);
					nodeBindings.add(property, idField);
				}

				//trace(idField.id + "." + idField.value + "=" + value);
				//bindLocalVar();
				// data = changValue override change()
				// if flag.fieldName
				//localId.localField = flag.fieldNameValue

			}
			else
			{

				//if(!publicFields.exists(property)) throw "Property not found: "+property;
				trace(segs);
				bindablesMap.add(property, idField);
			}


        }


		if(nodeBindings.iterator().hasNext())
		{
			var methodLines = [];
			methodLines.push("super.change(flag);");
			for(nBindable in nodeBindings.keys())
			{
				var idFields:Array<IdField> = nodeBindings.get(nBindable);
				var str = "";
				methodLines.push("if(flag." + nBindable + ")");
				methodLines.push("{");
				for (idField in idFields)
				{
					methodLines.push(idField.id + "." + idField.field + " = " + getValueFromBinding(idField.value) + ";");
				}
				methodLines.push("}");
			}

			methods.push( methodToString({
				prefix: "override", name:"change", args:"flag:Dynamic", returnType:"", body: methodLines.join("\n")
			}));
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


	function getMethods()
	{
		return methods.join("\n\n");
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
        classString = StringTools.replace(classString, "${classMeta}", classMeta);
        classString = StringTools.replace(classString, "${className}", moduleName);
        classString = StringTools.replace(classString, "${extendedComponent}", root.typeInfo.typeName);
        classString = StringTools.replace(classString, "${constructorBody}", getChildrenBody());
        classString = StringTools.replace(classString, "${bindings}", getBindables());
        classString = StringTools.replace(classString, "${publicVars}", getPublicVars());
        classString = StringTools.replace(classString, "${classBody}", getMethods());
        classString = StringTools.replace(classString, "${scriptBlock}", "");
        classString = StringTools.replace(classString, "${imports}", getImports());

        return classString;
    }

	function methodToString(method:Method):String
	{
		var template:String = neko.io.File.getContent(METHOD_TEMPLATE);
		var m = StringTools.replace(template, "${name}", method.name);
		m = StringTools.replace(m, "${args}", method.args);
		m = StringTools.replace(m, "${prefix}", method.prefix);
		m = StringTools.replace(m, "${returnType}", method.returnType);
		m = StringTools.replace(m, "${body}", method.body);
		return m;
	}
}

typedef Method = {
	prefix:String,
	name:String,
	args:String,
	returnType:String,
	body:String
}