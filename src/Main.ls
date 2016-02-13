package
{
    import system.JSON;
    import system.debugger.ObjectInspector;
    import system.platform.File;
    import system.platform.Platform;

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
        public static const startLocation = new Location(44.052473, -123.100890);

        private var map:MapExplorer;
        private var data:MapData;
        private var slideshow:Slideshow;
        private var updateTimer:Timer;

        private function getData():MapData
        {
            var json = JSON.parse(File.loadTextFile("assets/mockdata.json"));
            return MapData.parse(json);
        }

        override public function run():void
        {
            TextField.registerBitmapFont( BitmapFont.load( "assets/arialComplete.fnt" ), "SourceSansPro" );
            DeviceCapabilities.dpi = 300;
            new MetalWorksMobileVectorTheme();

            stage.scaleMode = StageScaleMode.NONE;

            // Increase map cache size to preserve cached data.
            TileGrid.MaxTilePixels = 4096*256*256;

            map = new MapExplorer(stage);
            map.onIdle += map_onIdle;
            map.gotoLocation(startLocation, 13);
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
            updateData();
        }

        private function updateTimer_onComplete(timer:Timer)
        {
            updateData();
            updateTimer.reset();
        }

        private function updateData()
        {
            data = getData();

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

            var loc = new Location(Number(item['lat']), Number(item['lon']));
            map.flyTo(loc);
            map.visible = true;
            map.onShown();
        }
    }
}