import example.LoginPresentationModel;
import nme.Lib;
import nme.events.Event;
import nme.display.Sprite;

class Main extends Sprite
{
    public function new()
    {
        super();

        #if iphone
		Lib.current.stage.addEventListener(Event.RESIZE, init);
		#else
		addEventListener(Event.ADDED_TO_STAGE, init);
        #end

    }

    function init(e):Void
    {
        // Stage:
        // stage.stageWidth x stage.stageHeight @ nme.system.Capabilities.screenDPI

        // Assets:
        // nme.Assets.getBitmapData("assets/assetname.jpg");

        #if iphone
		Lib.current.stage.removeEventListener(Event.RESIZE, init);
		#else
		removeEventListener(Event.ADDED_TO_STAGE, init);
        #end


        var view:example.LoginView = new example.LoginView(this);
        //addChild(view);
        view.model = new LoginPresentationModel();
        //view.onInjectionComplete();

    }




    public static function main()
    {

        // Static entry point
        Lib.current.stage.align = nme.display.StageAlign.TOP_LEFT;
        Lib.current.stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
        Lib.current.addChild(new Main());

    }
}
