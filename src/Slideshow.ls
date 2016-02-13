package
{
    import feathers.layout.AnchorLayoutData;
    import loom2d.display.DisplayObjectContainer;
    import loom.gameframework.ITicked;
    import loom.gameframework.TimeManager;
    import loom.gameframework.LoomGroup;
    import loom2d.display.Image;
    import loom2d.events.Event;
    import system.Math;
    import loom2d.textures.Texture;
    import loom.platform.Timer;
    import feathers.controls.Button;
    import loom2d.events.TouchEvent;
    import loom2d.events.TouchPhase;
    import loom2d.events.Touch;

    delegate LocateDelegate(item:Dictionary.<String, Object>):void;
    delegate StopDelegate():void;

    public class Slideshow extends DisplayObjectContainer implements ITicked
    {


        private var _data:MapData;
        private var _currentImage:Image;
        private var _currentItem:Dictionary.<String, Object>;
        private var _locateButton:Button;
        private var _timer:Timer;

        public var onLocate:LocateDelegate;
        public var onStop:StopDelegate;

        public function Slideshow()
        {
            var timeManager:TimeManager = LoomGroup.rootGroup.getManager(TimeManager) as TimeManager;
            timeManager.addTickedObject(this);

            _timer = new Timer(5000);
            _timer.onComplete = function()
            {
                changeImage();
                _timer.reset();
            };

            _currentImage = new Image();
            _currentImage.addEventListener(TouchEvent.TOUCH, currentImage_touchHandler);
            addChild(_currentImage);

            _locateButton = new Button();
            _locateButton.label = "Locate";
            _locateButton.defaultIcon = new Image(Texture.fromAsset("assets/locate.png"));
            _locateButton.defaultIcon.scale = 0.5;
            _locateButton.addEventListener(Event.TRIGGERED, locateButton_handler);
            addChild(_locateButton);
        }

        public function setData(data:MapData)
        {
            _data = data;
        }

        public function start()
        {
            _timer.start();
        }

        public function stop()
        {
            _timer.stop();
        }

        override public function onTick()
        {
            // Some late initalization here
            if (_currentItem == null)
            {
                var centerX = stage.stageWidth * 0.5;
                var centerY = stage.stageHeight * 0.9;

                _locateButton.x = centerX;
                _locateButton.y = centerY;
                _locateButton.scaleX = 4;
                _locateButton.scaleY = 4;
                _locateButton.center();

                changeImage();
            }
        }

        public function changeImage()
        {
            _currentItem = (Dictionary.<String, Object>)(_data.locations[Math.randomRangeInt(0, _data.locations.length - 1)]);
            _currentImage.texture = Texture.fromAsset(String(_currentItem['img']));
            _currentImage.scale = stage.stageHeight / _currentImage.texture.nativeHeight;
            _currentImage.x = stage.stageWidth / 2;
            _currentImage.y = stage.stageHeight / 2;
            _currentImage.center();
        }

        private function locateButton_handler()
        {
            onLocate(_currentItem);
        }

        private function currentImage_touchHandler(e:TouchEvent)
        {
            var t:Touch = e.getTouch(stage, TouchPhase.HOVER);
            if (t)
                return;

            onStop();
        }
    }
}