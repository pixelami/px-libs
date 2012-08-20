package org.pixelami.binding;

import org.pixelami.binding.MacroUtil;
import org.pixelami.binding.BindingType;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

class ViewProcessor
{

    var localClass:haxe.macro.Ref<ClassType>;
    var bindingInfos:Array<BindingInfo>;
    var fieldHash:Hash<Field>;
    var pos:Position;
    var fields:Array<Field>;

    public function new()
    {
    }


    public function process():Array<Field>
    {
        fields = Context.getBuildFields();
        pos = Context.currentPos();
        localClass = Context.getLocalClass();
        bindingInfos = [];
        fieldHash = new Hash<Field>();

        for(field in fields)
        {
            trace(field);
            fieldHash.set(field.name, field);

            var bindInfos:Array<BindingInfo> = processFieldBindMeta(field);

            if(bindInfos == null) continue;
            bindingInfos = bindingInfos.concat( bindInfos );
        }

        // these are the local host objects that are bound to
        var localHostFields:Hash<Array<BindingInfo>> = new Hash<Array<BindingInfo>>();
        var localHostSources:Hash<Array<String>> = new Hash<Array<String>>();

        for(info in bindingInfos)
        {

            var hostField = info.hostPath[0];
            //trace("hostField: "+hostField);

            var hostFieldBindingInfos:Array<BindingInfo> = localHostFields.get(hostField);
            if(hostFieldBindingInfos == null)
            {
                hostFieldBindingInfos = [];
                localHostFields.set(hostField, hostFieldBindingInfos);
            }
            hostFieldBindingInfos.push(info);


            var sources:Array<String> = localHostSources.get(hostField);
            if(sources == null)
            {
                sources = [];
                localHostSources.set(hostField,sources);
            }
            sources.push(createLocalBindableRegistationSource(info));

        }

        for (hostField in localHostFields.keys())
        {
            //trace("hostField: "+hostField);
            var f:Field = fieldHash.get(hostField);
            var bindingInfos:Array<BindingInfo> = localHostFields.get(hostField);


            // get the type and modify it to
            var hostType:Type = MacroUtil.resolveFieldType(f);


            processHostField(f, localHostSources.get(hostField), fields);

            switch(hostType)
            {
                case TInst(t, params):

                    var errors:Array<BindingError> = validateBindings(f, t, bindingInfos);
                    if(errors.length > 0)
                    {
                        MacroUtil.processErrors(errors, pos);
                    }

                default:
                    Context.error("Expected host object to be TInst",pos);
            }
        }

        return fields;
    }


    function processHostField(field:Field, sources:Array<String>, fields:Array<Field>)
    {
        switch(field.kind)
        {
            case FVar(t,exp):

                var setterName = "set_"+field.name;

                var newPos:Position = MacroUtil.createPositionAfter(field.pos, 1);


                var src:String = createConstructorBlockSource(sources);
                //trace(src);
                var setterExpr = Context.parse(src, newPos);

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

                var newProp = FProp("default",setterName,t,exp);
                // replace the old FVar with our newly generated FProp
                field.kind = newProp;

                fields.push(setterField);

            case FProp(get,set,t,exp):
                // TODO adjust setter


            default:
                Context.error("FProp(get,set,t,e) required", field.pos);
        }
    }

    function createConstructorBlockSource(lines:Array<String>):String
    {
        var src:String = "{";
        for(line in lines)
        {
            src += "\n\t" + line;
        }

        src += "\n\treturn model = value;";
        src += "\n}";
        return src;
    }


    /**
     * Creates the source that registers a view @Bindable with the BindingManager
     * Typically a view @Bindable is a local reference in the view to a IBindableModel
    **/
    function createLocalBindableRegistationSource(info:BindingInfo):String
    {
        // trace("target field name: "+info.field.name);
        // trace("target property name: "+info.property);
        // trace("source name: "+info.hostPath);

        var targetPath = info.field.name;
        if(info.property != null) targetPath  += "." + info.property;
        var sourcePropertyName = info.hostPath[info.hostPath.length - 1];

        var source:String = BindingManager.CREATE_BINDING + "(this,\""+targetPath+"\", value, \""+sourcePropertyName+"\");";
        //trace(source);
        return source;
    }

    /**
    * Validates all properties marked with @Bind metadata
    * Checks the following
    * a. The object being bound contains the properties that are being bound
    * b. The binding source object contains the properties that are being bound
    * c. properties are not being bound more than once.
    **/
    function validateBindings(
        field:Field,
        ref:haxe.macro.Ref<ClassType>,
        bindingInfos:Array<BindingInfo>):Array<BindingError>
    {
        var errors:Array<BindingError> = [];
        var classType:ClassType = ref.get();
        // hash to keep property names in order to check for duplicates
        var bindingInfoPropertyHash:Hash<Bool> = new Hash<Bool>();

        for(bindingInfo in bindingInfos)
        {
            var fields:Array<ClassField> = getAllClassFieldsForType(ref);

            if(!Lambda.exists(fields, function(classField:ClassField){
                var path:Array<String> = bindingInfo.hostPath.copy();
                var fname:String = path.shift();
                if(fname != field.name) return false;
                if(path.shift() != classField.name) return false;
                return true;
            }))
            {
                var hostPath:String = bindingInfo.hostPath.join(".");
                errors.push({
                    msg: classType.name + " does not contain property with name '"+ hostPath +"'",
                    pos:bindingInfo.pos
                });
            }




            switch(bindingInfo.type)
            {
                case TInst(t,params):

                    fields = getAllClassFieldsForType(t);

                    if(bindingInfo.property != null)
                    {
                        if(!Lambda.exists(fields, function(classField:ClassField){
                            return classField.name == bindingInfo.property;
                        }))
                        {
                            errors.push({
                                msg: t.toString() + " does not contain property with name '"+ bindingInfo.property +"'",
                                pos:bindingInfo.pos
                            });
                        }
                    }


                default:
            }

            // If the binding property is null this means that there is no child view object that
            // is being bound to. Instead it means the binding is happening to a property
            // of the view object itself.
            if(bindingInfo.property == null) return errors;

            var hasProperty = bindingInfoPropertyHash.get(bindingInfo.field.name + "." + bindingInfo.property);
            if(hasProperty)
            {

                errors.push({
                    msg: "Ambiguous binding detected for '"+ bindingInfo.property + "'. It seems to be bound more than once",
                    pos:bindingInfo.pos
                });
            }
            bindingInfoPropertyHash.set(bindingInfo.property, true);
        }
        return errors;
    }


    function getAllClassFieldsForType(ref:haxe.macro.Ref<ClassType>):Array<ClassField>
    {
        var classFields:Array<ClassField> = [];
        var r = ref;
        while(r != null)
        {
            var cType:ClassType = r.get();
            classFields = classFields.concat(cType.fields.get());
            if(cType.superClass == null) break;
            r = cType.superClass.t;
        }
        return classFields;
    }




    function validateHostProperties(hostType:ClassType, properties:Array<String>):Bool
    {
        var fields:Array<ClassField> = hostType.fields.get();
        for(field in fields)
        {
            if(Lambda.indexOf(properties, field.name) == -1) return false;
        }
        return true;
    }


    function processFieldBindMeta(f:Field):Array<BindingInfo>
    {
        var bindings:Array<BindingInfo> = null;
        for(meta in f.meta)
        {
            if(meta.name == "Bind")
            {
                bindings = processBindings(f, meta);
            }
        }
        return bindings;
    }


    function processBindings(
        field:Field,
        bindingMeta:{pos:Position, params:Array<Expr>, name:String}
    ):Array<BindingInfo>
    {
        var bindingInfos:Array<BindingInfo> = [];
        for(binding in bindingMeta.params)
        {
            var bindingInfo:Array<BindingInfo> = processBinding(field, binding);
            //log("bindingInfo: "+bindingInfo);
            bindingInfos = bindingInfos.concat(bindingInfo);
        }
        return bindingInfos;
    }

    function processBinding(
        field:Field,
        binding:Expr
    ):Array<BindingInfo>
    {
        var bindingInfos:Array<BindingInfo> = [];
        var fieldType:haxe.macro.Type = null;
        var property:String;
        var path:Array<String>;

        fieldType = MacroUtil.resolveFieldType(field);

        // replace the var with a setter that registers the instance
        // with the BindingManager to receive updates to the target property.
        //createSetterWrapper(field);

        switch(binding.expr)
        {
            case EObjectDecl(oFields):

                // we process 'complex' bindings here
                for(oField in oFields)
                {
                    property = oField.field;
                    //trace("oField: "+oField.expr);
                    var e = oField.expr;


                    switch(e.expr)
                    {
                        case EConst(c):
                            switch(c)
                            {
                                case CString(s):
                                    //trace("binding source:"+s);
                                    path = s.split(".");

                                case CIdent(s):
                                //trace("binding source:"+s);

                                default:
                                    trace("invalid binding source:"+c);
                            }

                        default:
                            trace("oField expr: "+oField.expr);
                    }

                    bindingInfos.push({
                        type: fieldType,
                        hostPath: path,
                        property: property,
                        pos: e.pos,
                        field: field
                        });

                }


            case EConst(c):

                // we process 'simple' bindings here

                switch(c)
                {
                    case CString(s):
                        //trace("binding source:"+s);
                        path = s.split(".");
                    default:
                }
                bindingInfos.push({
                    type: fieldType,
                    hostPath: path,
                    property: null,
                    pos: binding.pos,
                    field: field
                    });
            default:
                Context.error("could not find binding declaration",pos);
        }
        return bindingInfos;
    }

}
