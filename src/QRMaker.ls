package
{
    import loom2d.textures.Texture;
    import loom2d.display.AsyncImage;
    import loom2d.display.MovieClip;
    import loom.HTTPRequest;

    public class QRMaker
    {
        
        public static function generateFromLocation(latitude:String, longitude:String, size:Number):AsyncImage
        {
            var sprite:AsyncImage;
            var prefix:String = "geo:";
            var apiPrefix:String = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=";
            var suffix:String = "&type=.png";
            sprite = new AsyncImage(null, null, size, size);
            sprite.center();
            var apiCall:String = apiPrefix + prefix + latitude + "," + longitude + suffix;
            sprite.loadTextureFromHTTP(apiCall, loadComplete, loadFailure, false, true);
            
            return sprite;
        }
        
        private static function loadComplete(texture:Texture) {
        }
        
        private static function loadFailure(texture:Texture) {
            trace("Unable to load texture from HTTP");
        }
    }
}