import org.pixelami.uri.context.Context;
import org.pixelami.uri.URIController;
import example.Info;
import example.Now;
import example.Notifiy;
import example.Recommend;
import example.Video;

class Main
{
    var context:Context;

    public static function main()
    {
         var app:Main = new Main();
    }

    public function new()
    {
        context = Context.instance;
        context.objects = [Video, Info, Recommend, Now, Notifiy]; //

        URIController.instance.setURI("/video/1236667");
    }


}
