package example;

import nl.emceekay.ui.HBox;
import org.pixelami.binding.IBindingView;
import nl.emceekay.ui.CheckBox;
import nl.emceekay.ui.Component;
import nl.emceekay.ui.VBox;
import nl.emceekay.ui.PushButton;
import nl.emceekay.ui.InputText;
import nme.events.Event;
import nme.events.MouseEvent;

class LoginView extends Component , implements IBindingView
{
    var container:VBox;

    @Bind({ label:'model.submitLabel' })
    var submitBtn:PushButton;

    @Bind( {text:'model.usernamePrompt'} )
    var userInput:InputText;

    @Bind( {text:'model.passwordPrompt'} )
    var passInput:InputText;

    @Bind({ selected:'model.isRemembered' })
    var checkbox:CheckBox;

    public var model:LoginPresentationModel;

    public function new(?parent:Dynamic = null, ?xpos:Float = 0, ?ypos:Float =  0)
    {
         super(parent, xpos, ypos);
    }

    override function addChildren()
    {
        container = new VBox(this, 10 , 10);
        container.spacing = 20;

        userInput = new InputText(container, 0,0);
        userInput.addEventListener(Event.CHANGE, userInput_changeHandler);
        userInput.addDownAsset = nme.Assets.getBitmapData("assets/android_ui/input_down.png");
        userInput.addUpAsset = nme.Assets.getBitmapData("assets/android_ui/input_up.png");

        passInput = new InputText(container, 0,0);
        passInput.addEventListener(Event.CHANGE, passInput_changeHandler);
        passInput.addDownAsset = nme.Assets.getBitmapData("assets/android_ui/input_down.png");
        passInput.addUpAsset = nme.Assets.getBitmapData("assets/android_ui/input_up.png");


        var hbox:HBox = new HBox(container);

        checkbox = new CheckBox(hbox,0,0);
        checkbox.addEventListener(Event.CHANGE, checkBox_changeHandler);
        checkbox.addUpAsset = nme.Assets.getBitmapData("assets/android_ui/checkbox_uncheck.png");
        checkbox.addDownAsset = nme.Assets.getBitmapData("assets/android_ui/checkbox_check.png");

        submitBtn = new PushButton(hbox, 0,0);
        submitBtn.addEventListener(MouseEvent.MOUSE_UP, submitBtn_mouseUpHandler);
        submitBtn.addUpAsset = nme.Assets.getBitmapData("assets/android_ui/button_up.png");
        submitBtn.addDownAsset = nme.Assets.getBitmapData("assets/android_ui/button_down.png");
    }

    function submitBtn_mouseUpHandler(event:Event) :Void
    {
        model.submit();
    }

    function userInput_changeHandler(event:Event) :Void
    {
        model.updateUsername(userInput.text);
    }

    function passInput_changeHandler(event:Event) :Void
    {
        model.updatePassword(passInput.text);
    }

    function checkBox_changeHandler(event:Event) :Void
    {
        if(model != null) model.toggleRemember();
    }



    public function onInjectionComplete()
    {

    }
}
