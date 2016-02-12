package
{
    import feathers.controls.List;
    import loom.modestmaps.geo.Location;
    import loom2d.display.DisplayObjectContainer;
    import loom.modestmaps.Map;
    import loom2d.events.KeyboardEvent;
    import feathers.layout.AnchorLayoutData;
    import feathers.data.ListCollection;
    import loom2d.events.Event;
    import loom2d.math.Point;
    import loom.platform.LoomKey;
    import loom.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider;
    import loom2d.display.Stage;
    import loom.platform.Timer;
    import loom2d.events.TouchEvent;
    import loom2d.events.TouchPhase;
    import loom2d.events.Touch;

    delegate IdleDelegate():void;

    public class MapExplorer extends DisplayObjectContainer
    {


        private var _map:Map;
        private var _flyer:MapFlyer;
        private var _list:List;
        private var _data:Vector.<Dictionary.<String, Object>>;
        private var _timer:Timer;

        public var onIdle:IdleDelegate;

        public function MapExplorer(stage:Stage)
        {
            _map = new Map(stage.stageWidth,
                           stage.stageHeight,
                           true,
                           new MicrosoftRoadMapProvider(true),
                           stage,
                           null);
            addChild(_map);

            _flyer = new MapFlyer(_map);

            _list = new List();
            _list.isSelectable = true;
            _list.allowMultipleSelection = false;
            _list.height = height;
            _list.itemRendererProperties["labelField"] = "name";
            _list.addEventListener(Event.CHANGE, list_changeHandler);
            _list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
            addChild(_list);

            _timer = new Timer(10000);
            _timer.onComplete += function()
            {
                if (this.visible)
                    onIdle();
            };
            _timer.start();

            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            stage.addEventListener(TouchEvent.TOUCH, touchHandler);
            _list.addEventListener(TouchEvent.TOUCH, touchHandler);
        }

        public function setData(data:Vector.<Dictionary.<String, Object>>)
        {
            _data = data;
            _list.dataProvider = new ListCollection(_data);
        }

        public function goTo(location:Location, zoom:Number)
        {
            _map.setCenter(location);
            _map.setZoom(zoom);
        }

        public function flyTo(location:Location)
        {
            _flyer.flyTo(location);
        }

        public function onShown()
        {
            _timer.reset();
        }

        private function keyDownHandler(event:KeyboardEvent):void
        {
            var keycode = event.keyCode;

            //always zoom at the center of the screen
            var zoomPoint:Point = new Point(_map.getWidth() / 2, _map.getHeight() / 2);

            if (keycode == LoomKey.C) trace(_map.getCenter());

            //process zooming
            if (keycode == LoomKey.EQUALS)
                _map.zoomByAbout(0.05, zoomPoint);
            if (keycode == LoomKey.HYPHEN)
                _map.zoomByAbout( -0.05, zoomPoint);

            _timer.reset();
        }

        private function touchHandler(e:TouchEvent):void
        {
            var t:Touch = e.getTouch(stage, TouchPhase.HOVER);
            if (t)
                return;

            _timer.reset();
        }

        private function list_changeHandler(event:Event):void
        {
            var dict:Dictionary.<String, Object> = _list.selectedItem as Dictionary.<String, Object>;
            flyTo(new Location(Number(dict['lat']), Number(dict['lon'])));
            _timer.reset();
        }
    }
}