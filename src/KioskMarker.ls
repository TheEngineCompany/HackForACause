package
{
    import loom2d.display.Image;
    import loom2d.textures.Texture;

    /**
     * ...
     * 
     * @author Tristan
     * based on MapMarker by Tadej
     *
     */
    public class KioskMarker extends Image
    {
        private static var _pinNormal:Texture = null;

        public function KioskMarker()
        {
            super();

            if (_pinNormal == null) {
                _pinNormal = Texture.fromAsset("assets/kiosk_pin.png");
            }
			this.texture = _pinNormal;

            // Move pin so it points to proper location
            pivotX = width / scaleX / 2;
            pivotY = height / scaleY;
        }
    }
}