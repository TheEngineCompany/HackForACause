package
{
    import feathers.controls.List;
    import feathers.data.ListCollection;
    import feathers.layout.AnchorLayoutData;
    import loom.modestmaps.geo.Location;
    import loom.modestmaps.Map;
    import loom.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider;
    import loom.modestmaps.overlays.ImageMarker;
    import loom.platform.LoomKey;
    import loom.platform.Timer;
    import system.platform.Platform;
    import loom2d.display.DisplayObjectContainer;
    import loom2d.display.Shape;
    import loom2d.display.Stage;
    import loom2d.display.TextFormat;
    import loom2d.display.TextAlign;
    import loom2d.events.Event;
    import loom2d.events.KeyboardEvent;
    import loom2d.events.Touch;
    import loom2d.events.TouchEvent;
    import loom2d.events.TouchPhase;
    import loom2d.math.Point;
    import loom2d.textures.Texture;

    delegate IdleDelegate():void;

    public class MapExplorer extends DisplayObjectContainer
    {
        private var _map:Map;
        private var _flyer:MapFlyer;
        private var _listAttractions:List;
        private var _listCategories:List;
        private var _detailsView:Shape;
        private var _data:MapData;
        private var _timer:Timer;

        private var _detailsTriggerTime:Number = NaN;

        public var onIdle:IdleDelegate;

        public function gotoCategories():void
        {
            _listCategories.visible = true;
            _listCategories.selectedIndex = -1;
            _listAttractions.visible = false;
            _listAttractions.selectedIndex = -1;
            _detailsView.visible = false;
        }

        public function gotoAttractions():void
        {
            _listCategories.visible = false;
            _listCategories.selectedIndex = -1;
            _listAttractions.visible = true;
            _listAttractions.selectedIndex = -1;
            _detailsView.visible = false;
        }

        public function gotoDetails(dict:Dictionary.<String, Object>):void
        {
            _listCategories.visible = false;
            _listCategories.selectedIndex = -1;
            _listAttractions.visible = false;
            _listAttractions.selectedIndex = -1;
            _detailsView.visible = true;

            // Draw some useful info.
            _detailsView.graphics.clear();
            
            var tfTitle = new TextFormat(null, 128, 0x0, true);
            tfTitle.align = TextAlign.CENTER;
            _detailsView.graphics.textFormat(tfTitle);
            _detailsView.graphics.drawTextLine(stage.stageWidth / 2, stage.stageHeight / 2 - 200, dict["name"] as String);

            var tfDetails = new TextFormat(null, 32, 0x0, true);
            tfDetails.align = TextAlign.CENTER;
            _detailsView.graphics.textFormat(tfDetails);
            _detailsView.graphics.drawTextLine(stage.stageWidth / 2, stage.stageHeight / 2 + 150, dict["details"] as String);

            _detailsTriggerTime = Platform.getTime();
        }

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

            _listAttractions = new List();
            _listAttractions.isSelectable = true;
            _listAttractions.allowMultipleSelection = false;
            _listAttractions.height = height;
            _listAttractions.itemRendererProperties["labelField"] = "name";
            _listAttractions.addEventListener(Event.CHANGE, list_changeHandler);
            _listAttractions.layoutData = new AnchorLayoutData(0, 0, 0, 0);
            addChild(_listAttractions);

            _listCategories = new List();
            _listCategories.visible = false;
            _listCategories.isSelectable = true;
            _listCategories.allowMultipleSelection = false;
            _listCategories.height = height;
            _listCategories.itemRendererProperties["labelField"] = "name";
            _listCategories.addEventListener(Event.CHANGE, listCategory_changeHandler);
            _listCategories.layoutData = new AnchorLayoutData(0, 0, 0, 0);
            addChild(_listCategories);

            _detailsView = new Shape();
            addChild(_detailsView);

            _timer = new Timer(5 * 60 * 1000); // 5 minute timeout
            _timer.onComplete += function()
            {
                if (this.visible)
                    onIdle();
            };
            _timer.start();

            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            stage.addEventListener(TouchEvent.TOUCH, touchHandler);
            _listAttractions.addEventListener(TouchEvent.TOUCH, touchHandler);
            _listCategories.addEventListener(TouchEvent.TOUCH, touchHandler);

            // Start in categories.
            gotoCategories();
        }

        public function setData(data:MapData)
        {
            _data = data;
            _listAttractions.dataProvider = new ListCollection(_data.locations);
            _listCategories.dataProvider = new ListCollection(_data.categories);
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

            // always zoom at the center of the screen
            var zoomPoint:Point = new Point(_map.getWidth() / 2, _map.getHeight() / 2);

            if (keycode == LoomKey.C) trace(_map.getCenter());

            // precise zooming
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

            if(Platform.getTime() - _detailsTriggerTime > 3000 && _detailsTriggerTime == _detailsTriggerTime)
            {
                _detailsTriggerTime = NaN;
                gotoCategories();
            }

            _timer.reset();
        }

        private function list_changeHandler(event:Event):void
        {
            var dict:Dictionary.<String, Object> = _listAttractions.selectedItem as Dictionary.<String, Object>;
            if(!dict)
                return;
            trace("Attraction selected: " + dict['name']);
            flyTo(new Location(Number(dict['lat']), Number(dict['lon'])));
            gotoDetails(dict);
            _timer.reset();
        }

        private function listCategory_changeHandler(event:Event):void
        {
            var dict:Dictionary.<String, Object> = _listCategories.selectedItem as Dictionary.<String, Object>;
            if(!dict)
                return;
            trace("Category selected: " + dict['name']);
            gotoAttractions();
            _timer.reset();
        }
    }
}