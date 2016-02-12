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
        private const startLocation = new Location(44.052473, -123.100890);

        private var map:MapExplorer;
        private var slideshow:Slideshow;

        private const pointsOfInterest:Vector.<Dictionary.<String, Object>> = [
            { 'name': 'The Cooler Restaurant and Bar', 'lat': 44.060184, 'lon': -123.0803059, 'img': "assets/locations/cooler.jpg" },
            { 'name': 'Sixth Street Grill', 'lat': 44.053405, 'lon': -123.0937108, 'img': "assets/locations/sixthstreetgrill.jpg" },
            { 'name': 'The Beer Stein', 'lat': 44.0423998, 'lon': -123.0925295, 'img': "assets/locations/beerstein.png" },
            { 'name': 'Old Nick\'s Pub', 'lat': 44.0574557, 'lon': -123.1001944, 'img': "assets/locations/oldnickspub.jpg" },
            { 'name': 'The O Bar and Grill', 'lat': 44.0602655, 'lon': -123.056066, 'img': "assets/locations/obar.jpg" },
        ];

        override public function run():void
        {
            TextField.registerBitmapFont( BitmapFont.load( "assets/arialComplete.fnt" ), "SourceSansPro" );
            new MetalWorksMobileVectorTheme();

            stage.scaleMode = StageScaleMode.LETTERBOX;

            map = new MapExplorer(stage);
            map.onIdle += map_onIdle;
            map.setData(pointsOfInterest);
            map.goTo(startLocation, 13);
            map.visible = false;
            stage.addChild(map);

            slideshow = new Slideshow();
            slideshow.onLocate += slideshow_onLocate;
            slideshow.onStop += slideshow_onStop;
            slideshow.setData(pointsOfInterest);
            slideshow.start();
            stage.addChild(slideshow);
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