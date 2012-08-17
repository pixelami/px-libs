package example;

class Video
{
    public function new()
    {
    }

    @Uri('^/video')
    public function start(uri:String)
    {
         trace(uri);
    }
}
