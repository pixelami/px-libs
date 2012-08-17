package org.pixelami.binding;

#if binding_1
typedef BindingManager =  BindingManagerDefaultImpl
#else
typedef BindingManager =  BindingManagerDefaultImpl
#end

typedef Binding = {
    hostObject:Dynamic,
    hostPropertyName:String,
    listeningObject:Dynamic,
    listeningObjectProperty:String,
    listeningObjectPropertyPath:Array<String>,
    resolvedTargetObject:Dynamic
}


class BindingManagerDefaultImpl
{
    public static inline var SINGLETON:String = "org.pixelami.binding.BindingManager.getInstance()";
    public static inline var CREATE_BINDING:String = SINGLETON + ".createBinding";
    public static inline var UPDATE:String = SINGLETON + ".update";

    private static var _instance:BindingManager;

    public static function getInstance():BindingManager
    {
        if(_instance == null) _instance = new BindingManager();
        return _instance;
    }

    var bindableHostsHash:Hash<Array<Binding>>;

    public function new()
    {
        bindableHostsHash = new Hash<Array<Binding>>();
    }


    /**
    *  Creates a binding between two properties from two objects.
    *  If the binding does not exist already it is created
    *  If it exists it is fire
    **/
    public function createBinding(listenerObject:Dynamic, listenerProperty:String, hostObject:Dynamic, hostProperty:String)
    {
        var bindingSourceId:String = getBindingSourceId(hostObject, hostProperty);
        //trace("bindingSourceId:"+bindingSourceId);

        var bindings:Array<Binding> = bindableHostsHash.get(bindingSourceId);
        if(bindings == null)
        {
            bindings = [];
            bindableHostsHash.set(bindingSourceId, bindings);
        }
        var binding:Binding = null;
        for(b in bindings)
        {
           if(b.hostObject == hostObject)
           {
               binding = b;
               break;
           }
        }
        if(binding == null)
        {
            binding = _createBinding(listenerObject, listenerProperty, hostObject, hostProperty);
            bindings.push(binding);
        }

        updateBinding(binding, Reflect.getProperty(binding.hostObject, binding.hostPropertyName));
    }

    function _createBinding(listenerObject:Dynamic, listenerProperty:String, hostObject:Dynamic, hostProperty:String):Binding
    {
        var pathComponents:Array<String> = listenerProperty.split(".");
        var property:String = pathComponents.pop();
        var b:Binding = {
            hostObject: hostObject,
            hostPropertyName: hostProperty,
            listeningObject: listenerObject,
            listeningObjectProperty: property,
            listeningObjectPropertyPath: pathComponents,
            resolvedTargetObject:null
        }
        return b;
    }

    /**
     * Removes all bindings to a View @Bindable, for example when a new IBindableModel is injected into a view.
    **/
    public function releaseBinding(listenerInstance:Dynamic, bindablePropertyHostObject:Dynamic)
    {
        removeAllBindingsFor(listenerInstance, bindablePropertyHostObject);
    }

    public function removeAllBindingsFor(listenerInstance:Dynamic, bindablePropertyHostObject:Dynamic)
    {
        for(bindings in bindableHostsHash.iterator())
        {
            removeBindingsFor(bindings, listenerInstance, bindablePropertyHostObject);
        }
    }

    public function removeBindingsFor(bindings:Array<Binding>, listenerInstance:Dynamic, bindablePropertyHostObject:Dynamic)
    {
        var bindingsToRemove:Array<Binding> = [];
        for(binding in bindings)
        {
            if(binding.listeningObject == listenerInstance && binding.hostObject == bindablePropertyHostObject)
            {
                bindingsToRemove.push(binding);
            }
        }

        for(b in bindingsToRemove)
        {
            bindings.remove(b);
        }
    }

    /**
    *  Any property marked bindable will call this method to notify that its value has changed
    **/
    public function updateValue(bindablePropertyHostObject:Dynamic, propertyName:String, value:Dynamic)
    {
        //trace("updateValue" + bindablePropertyHostObject + ", " + propertyName + ", " + value);
        var bindingSourceId:String = getBindingSourceId(bindablePropertyHostObject, propertyName);
        //trace("bindingSourceId: "+bindingSourceId);
        var bindings:Array<Dynamic> = bindableHostsHash.get(bindingSourceId);

        if(bindings == null || bindings.length == 0) return;

        for(binding in bindings)
        {
            // we are only going to update objects listening to the instance of bindablePropertyHostObject
            if(binding.hostObject == bindablePropertyHostObject)
            {
                updateBinding(binding, value);
            }
        }
    }

    function updateBinding(binding:Binding, value:Dynamic)
    {
        var target:Dynamic = binding.resolvedTargetObject;

        if(target == null)
        {
            var pathComponents:Array<String> = binding.listeningObjectPropertyPath;


            //trace("pathComponents: "+pathComponents);
            target = binding.listeningObject;
            for(component in pathComponents)
            {
                target = Reflect.getProperty(target, component);
                //trace("resolving target: "+target);
                if(target == null)
                {
                    //trace("WARNING: unable to resolve target for "+pathComponents);
                    return;
                }
            }
            // lookup is little expensive so cache the target in the binding
            // for re-use on the next update
            binding.resolvedTargetObject = target;

        }

        var property = binding.listeningObjectProperty;
        Reflect.setProperty(
            target,
            property,
            value
        );
    }

    /**
    * Attempts to use the __ID__ created by the BindingProcessor at macro time.
    * Otherwise..
    * Creates a key for a property based on the host Object type and the property name
    * This key is not unique
    **/
    function getBindingSourceId(bindablePropertyHostObject:Dynamic, propertyName:String):String
    {
        //trace("__ID__ "+bindablePropertyHostObject.__ID__);
        try
        {
            return bindablePropertyHostObject.__ID__ + "::" + propertyName;
        }
        catch(e:Dynamic)
        {
            return Type.getClassName(Type.getClass(bindablePropertyHostObject)) + "::" + propertyName;
        }

    }
}

