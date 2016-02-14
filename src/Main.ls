package
{
    import system.JSON;
    import system.debugger.ObjectInspector;
    import system.platform.File;
    import system.platform.Platform;

    import loom.HTTPRequest;

    import loom.Application;
    import loom.modestmaps.geo.Location;
    import loom.modestmaps.Map;
    import loom.modestmaps.core.TileGrid;
    import loom.modestmaps.mapproviders.AbstractMapProvider;
    import loom.modestmaps.mapproviders.IMapProvider;
    import loom.modestmaps.mapproviders.MapboxProvider;
    import loom.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider;
    import loom.modestmaps.mapproviders.OpenStreetMapProvider;
    import loom.modestmaps.mapproviders.BlueMarbleMapProvider;
    import loom.modestmaps.overlays.ImageMarker;
    import loom.platform.TimerCallback;
    import loom.platform.LoomKey;
    import loom.platform.Timer;

    import loom2d.Loom2D;
    import loom2d.display.Image;
    import loom2d.display.StageScaleMode;
    import loom2d.events.*;
    import loom2d.math.Point;
    import loom2d.textures.Texture;
    import loom2d.text.BitmapFont;
    import loom2d.text.TextField;

    import feathers.controls.List;
    import feathers.controls.Button;
    import feathers.controls.renderers.DefaultListItemRenderer;
    import feathers.controls.renderers.IListItemRenderer;
    import feathers.data.ListCollection;
    import feathers.data.VectorListCollectionDataDescriptor;
    import feathers.layout.AnchorLayout;
    import feathers.layout.AnchorLayoutData;
    import feathers.themes.MetalWorksMobileVectorTheme;
    import feathers.system.DeviceCapabilities;

    public class Main extends Application
    {
        public static const startLocation = new Location(44.04935,-123.09195);

        private var map:MapExplorer;
        private var data:MapData;
        private var slideshow:Slideshow;
        private var updateTimer:Timer;

        private var updateRequest:HTTPRequest;

        private function initiateJSONRequest():void
        {
            if(updateRequest)
            {
                trace("Request already in flight, waiting.");
                return;
            }

            updateRequest = new HTTPRequest("http://downtowneug.hour.li/dwtn/make_json/");
            updateRequest.method = "GET";
            updateRequest.onSuccess += handleJSONRequest_success;
            updateRequest.onFailure += handleJSONRequest_failure;
            updateRequest.send();
        }

        private function handleJSONRequest_success(v:ByteArray):void
        {
            trace("JSON Request Success.");
            var str = v.readUTFBytes(v.length);
            trace("Parsing...");
            data = MapData.parse(JSON.parse(str));
            trace("OK!");
            updateRequest = null;

            updateData();
        }

        private function handleJSONRequest_failure(v:ByteArray):void
        {
            trace("JSON Request Failed.");
            updateRequest = null;            
        }

        override public function run():void
        {
            TextField.registerBitmapFont( BitmapFont.load( "assets/arialComplete.fnt" ), "SourceSansPro" );
            DeviceCapabilities.dpi = 300;
            new MetalWorksMobileVectorTheme();

            stage.scaleMode = StageScaleMode.NONE;

            // Set to false for development.
            if(true)
            {
                stage.fingerEnabled = true;
                stage.mouseEnabled = false;
            }
            else 
            {
                stage.fingerEnabled = false;
                stage.mouseEnabled = true;                
            }

            // Increase map cache size to preserve cached data.
            TileGrid.MaxTilePixels = 4096*256*256;

            map = new MapExplorer(stage);
            map.onIdle += map_onIdle;
            map.gotoLocation(startLocation, 17);
            map.visible = false;
            stage.addChild(map);

            slideshow = new Slideshow();
            slideshow.onLocate += slideshow_onLocate;
            slideshow.onStop += slideshow_onStop;

            slideshow.start();
            stage.addChild(slideshow);

            updateTimer = new Timer(1000  * 30); // Update once per 30 seconds
            updateTimer.onComplete += updateTimer_onComplete;
            updateTimer.start();

            // Inital data update
            initiateJSONRequest();
        }

        private function updateTimer_onComplete(timer:Timer)
        {
            initiateJSONRequest();
            updateTimer.reset();
        }

        private function updateData()
        {
            slideshow.setData(data);
            map.setData(data);
        }

        private function map_onIdle()
        {
            map.visible = false;

            slideshow.visible = true;
            slideshow.start();
            slideshow.changeImage();
        }

        private function slideshow_onStop()
        {
            slideshow.stop();
            slideshow.visible = false;

            map.visible = true;
            map.onShown();
        }

        private function slideshow_onLocate(item:Dictionary.<String, Object>)
        {
            slideshow.stop();
            slideshow.visible = false;

            var targetLat = Number.fromString(item['lat'] as String);
            var targetLon = Number.fromString(item['lon'] as String);
            var loc = new Location(targetLat, targetLon);
            map.flyTo(loc);
            map.visible = true;
            map.onShown();
        }
    }
}