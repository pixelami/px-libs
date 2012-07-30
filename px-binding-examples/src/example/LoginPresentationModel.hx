package example;

import org.pixelami.binding.IBindableModel;

class LoginPresentationModel implements IBindableModel
{
    @Bindable
    public var submitLabel:String;

    @Bindable
    public var usernamePrompt:String;

    @Bindable
    public var passwordPrompt:String;

    @Bindable
    public var isRemembered:Bool;




    public function new()
    {
        submitLabel = "Submit";
        usernamePrompt = "Username";
        passwordPrompt = "Password";
        isRemembered = false;
    }

    public function submit()
    {
        trace("submit called");
    }

    public function updateUsername(text:String)
    {
        trace("updateInput called:" +text);
    }

    public function updatePassword(text:String)
    {
        trace("updateInput called:" +text);
    }

    public function toggleRemember()
    {
        trace("submit toggleRemember");
    }
}
