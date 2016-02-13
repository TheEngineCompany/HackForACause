package
{
    import loom2d.display.Image;
    import loom2d.display.Sprite;
    import loom2d.display.TextFormat;
    import loom2d.events.Event;
    import loom2d.math.Rectangle;
    import loom2d.textures.Texture;
    import loom2d.display.Shape;
    import loom2d.display.AsyncImage;

    public class DetailsView extends Sprite
    {
        private static var _defaultTexture:Texture = null;

        private var _bg:Shape;

        private var _name:Shape;
        private var _details:Shape;

        private var _nameFormat:TextFormat;
        private var _detailsFormat:TextFormat;

        private var _preview:Sprite;
        private var _previewImg:Image;
        private var _QRImage:AsyncImage;

        public function DetailsView()
        {
            if (_defaultTexture == null)
                _defaultTexture = Texture.fromAsset("assets/no-image.jpg");

            _bg = new Shape();

            _preview = new Sprite();
            _name = new Shape();
            _details = new Shape();
            _nameFormat = new TextFormat(null, 30, 0x0, true);
            _detailsFormat = new TextFormat(null, 25, 0x0, true);
            _previewImg = new Image(_defaultTexture);
            _preview.addChild(_previewImg);

            _QRImage = new AsyncImage(null, null, 0, 0);

            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        public function init():void
        {
            _bg.graphics.beginFill(0xececec, 1);
            _bg.graphics.lineStyle(0, 0x000000, 0);
            _bg.graphics.drawRect(0, 0, 320, stage.stageHeight);
            _bg.graphics.endFill();

            _preview.clipRect = new Rectangle(0, 0, 320, 200);

            _name.y = 220;
            _name.x = 10;

            _details.y = 270;
            _details.x = 10;

            addChild(_bg);
            addChild(_name);
            addChild(_details);
            addChild(_preview);
            addChild(_QRImage);
        }

        public function setData(data:Dictionary.<String, Object>)
        {
            if (data == null) return;
            //var tfTitle = new TextFormat(null, 128, 0x0, true);
            //tfTitle.align = TextAlign.CENTER;
            _name.graphics.clear();
            _details.graphics.clear();

            _name.graphics.textFormat(_nameFormat);
            _details.graphics.textFormat(_detailsFormat);

            _name.graphics.drawTextBox(0, 0, 300, data["name"] as String);
            _details.graphics.drawTextBox(0, 0, 300, data["details"] as String);

            if ((data["img"] as String).length > 0)
                _previewImg.texture = Texture.fromAsset(data["img"] as String);
            else
                _previewImg.texture = _defaultTexture;

            // Resize preview image to fit into preview nicely
            _previewImg.width = 320;
            _previewImg.scaleY = _previewImg.scaleX;
            if (_previewImg.height < 200)
            {
                _previewImg.height = 200;
                _previewImg.scaleX = _previewImg.scaleY;
            }
            _previewImg.x = -(_previewImg.width - 320);
            _previewImg.y = -(_previewImg.height - 200);

            removeChild(_QRImage);
            _QRImage.dispose();
            _QRImage = QRMaker.generateFromLocation(data["lat"] as String,data["lon"] as String,256);
            _QRImage.x = _bg.width/2;
            _QRImage.y = (stage.stageHeight - _QRImage.height/2) - 30;
            addChild(_QRImage);
        }

        private function addedToStage(e:Event):void
        {
            init();
        }
    }

}