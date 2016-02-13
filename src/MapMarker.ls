package
{
    import loom2d.display.Image;
    import loom2d.textures.Texture;

    /**
     * ...
     * @author Tadej
     */
    public class MapMarker extends Image
    {
        private static var _pinNormal:Texture = null;
        private static var _pinSelected:Texture = null;

        private var selected:Boolean = false;
        private var _id:int;

        public function MapMarker(id:int = -1)
        {
            super();

            _id = id;

            if (_pinNormal == null) {
                _pinNormal = Texture.fromAsset("assets/pin.png");
            }
            if (_pinSelected == null)
                _pinSelected = Texture.fromAsset("assets/pin2.png");

            updateTexture();

            // Move pin so it points to proper location
            pivotX = width / scaleX / 2;
            pivotY = height / scaleY;
        }

        public function select()
        {
            selected = true;
            updateTexture();
        }

        public function deselect()
        {
            selected = false;
            updateTexture();
        }

        private function updateTexture()
        {
            if (selected)
                this.texture = _pinSelected;
            else
                this.texture = _pinNormal;
        }

        public function get id():int
        {
            return _id;
        }
    }

}