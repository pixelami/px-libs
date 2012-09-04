package example;

import example.LoginPresentationModel;

class LoginView extends nl.emceekay.ui.Component
{
    public var usernameInput:nl.emceekay.ui.InputText;
    public var passwordInput:nl.emceekay.ui.InputText;
public var model(default, set_model):Dynamic;
function set_model(value)
{
    org.pixelami.binding.BindingManager.getInstance().createBinding(this, "usernameInput.text", value, "usernamePrompt");
    return model = value;
}


    public function new(?parent:Dynamic)
    {
        super(parent);


    }

    override public function addChildren()
    {
        super.addChildren();

        var vBox0 = new nl.emceekay.ui.VBox();
        vBox0.width = 200;
        vBox0.y = 0;
        vBox0.x = 0;
        usernameInput = new nl.emceekay.ui.InputText();
        usernameInput.percentWidth = 100;
        usernameInput.text = "{model.usernamePrompt}";
        vBox0.addChild(usernameInput);
        passwordInput = new nl.emceekay.ui.InputText();
        passwordInput.percentWidth = 100;
        vBox0.addChild(passwordInput);
        var hBox0 = new nl.emceekay.ui.HBox();
        hBox0.percentWidth = 100;
        var checkBox0 = new nl.emceekay.ui.CheckBox();
        hBox0.addChild(checkBox0);
        var pushButton0 = new nl.emceekay.ui.PushButton();
        hBox0.addChild(pushButton0);
        vBox0.addChild(hBox0);
        this.addChild(vBox0);

    }
///////////////////////////////////////////////////////////////////////////////
// Begin <Script> block
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// End <Script> block
///////////////////////////////////////////////////////////////////////////////
}