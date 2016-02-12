package
{
    import feathers.data.VectorListCollectionDataDescriptor;
    import loom.Application;
    import loom.modestmaps.geo.Location;
    import loom.modestmaps.Map;
    import loom.modestmaps.mapproviders.AbstractMapProvider;
    import loom.modestmaps.mapproviders.IMapProvider;
    import loom.modestmaps.mapproviders.MapboxProvider;
    import loom.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider;
    import loom.modestmaps.mapproviders.OpenStreetMapProvider;
    import loom.modestmaps.mapproviders.BlueMarbleMapProvider;
    import loom.modestmaps.overlays.ImageMarker;
    import loom2d.Loom2D;
    import loom2d.text.BitmapFont;
    import loom2d.text.TextField;
    import system.debugger.ObjectInspector;
    import system.platform.File;

    import loom.platform.LoomKey;
    import loom.platform.Timer;
    import loom2d.display.Image;
    import loom2d.display.StageScaleMode;
    import loom2d.events.*;
    import loom2d.math.Point;
    import loom2d.textures.Texture;

    import feathers.controls.List;
    import feathers.controls.Button;
    import feathers.controls.renderers.DefaultListItemRenderer;
    import feathers.controls.renderers.IListItemRenderer;
    import feathers.data.ListCollection;
    import feathers.layout.AnchorLayout;
    import feathers.layout.AnchorLayoutData;
    import feathers.themes.MetalWorksMobileVectorTheme;

    public class Main extends Application
    {
        private var _map:Map;
        private var _flyer:MapFlyer;

        private const StartLocation = new Location(44.052473, -123.100890);

        private var list:List;

        private const pointsOfInterest:Vector.<Dictionary.<String, Object>> = [
            {'name': 'Test 1', 'lat': 44.052453, 'lon': -123.101880},
            {'name': 'Test 2', 'lat': 44.052473, 'lon': -123.100890},
            {'name': 'Test 3', 'lat': 44.042493, 'lon': -123.103890 },
            {'name': 'Test 1', 'lat': 44.052453, 'lon': -123.101880},
            {'name': 'Test 2', 'lat': 44.052473, 'lon': -123.100890},
            {'name': 'Test 3', 'lat': 44.042493, 'lon': -123.103890 },
            {'name': 'Test 1', 'lat': 44.052453, 'lon': -123.101880},
            {'name': 'Test 2', 'lat': 44.052473, 'lon': -123.100890},
            {'name': 'Test 3', 'lat': 44.042493, 'lon': -123.103890 },
            {'name': 'Test 1', 'lat': 44.052453, 'lon': -123.101880},
            {'name': 'Test 2', 'lat': 44.052473, 'lon': -123.100890},
            {'name': 'Test 3', 'lat': 44.042493, 'lon': -123.103890 },
            {'name': 'Test 1', 'lat': 44.052453, 'lon': -123.101880},
            {'name': 'Test 2', 'lat': 44.052473, 'lon': -123.100890},
            {'name': 'Test 3', 'lat': 44.042493, 'lon': -123.103890},
        ];

        override public function run():void
        {
            TextField.registerBitmapFont( BitmapFont.load( "assets/arialComplete.fnt" ), "SourceSansPro" );
            new MetalWorksMobileVectorTheme();

            stage.scaleMode = StageScaleMode.LETTERBOX;
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

            //creat the map with our default provider
            _map = new Map(stage.stageWidth,
                                stage.stageHeight,
                                true,
                                new MicrosoftRoadMapProvider(true),
                                stage,
                                null);
            _map.setCenter(StartLocation);
            _map.setZoom( 13);
            stage.addChild(_map);

            _flyer = new MapFlyer(_map);

            list = new List();
            list.dataProvider = new ListCollection(pointsOfInterest);
            list.isSelectable = true;
            list.allowMultipleSelection = false;
            list.height = stage.stageHeight;
            list.itemRendererProperties["labelField"] = "name";
            list.addEventListener(Event.CHANGE, list_changeHandler);
            list.layoutData = new AnchorLayoutData(0, 0, 0, 0);

            stage.addChild(list);
        }

        private function list_changeHandler(event:Event):void
        {
            var dict:Dictionary.<String, Object> = list.selectedItem as Dictionary.<String, Object>;

            trace("List onChange:", dict["name"]);

            _flyer.flyTo(new Location(Number(dict["lat"]), Number(dict["lon"])));

        }

        override public function onTick()
        {
            _flyer.onTick();
        }

        //keyboard handler
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

            var switched = false;
        }

        //touch handler
        private function touchHandler(event:TouchEvent):void
        {

        }
    }
}