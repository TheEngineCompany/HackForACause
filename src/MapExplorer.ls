package
{
    import feathers.controls.Button;
    import feathers.controls.ImageLoader;
    import feathers.controls.List;
    import feathers.controls.Panel;
    import feathers.controls.Scroller;
    import feathers.data.ListCollection;
    import feathers.data.VectorListCollectionDataDescriptor;
    import feathers.layout.AnchorLayoutData;
    import loom.modestmaps.geo.Location;
    import loom.modestmaps.overlays.ImageMarker;
    import loom.modestmaps.overlays.MarkerClip;
    import loom.modestmaps.core.MapExtent;
    import loom.modestmaps.Map;
    import loom2d.display.AsyncImage;
    import loom2d.display.Image;
    import loom.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider;
    import loom.modestmaps.overlays.ImageMarker;
    import loom.platform.LoomKey;
    import loom.platform.Timer;
    import loom2d.events.ScrollWheelEvent;
    import loom2d.math.Rectangle;
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
        private var _detailsView:Panel;
        private var _detailsTitle:Shape;
        private var _detailsDesc:Shape;
        private var _detailsBack:Button;
        private var _detailsHeader:ImageLoader;
        private var _data:MapData;
        private var _timer:Timer;
        private var _kiosk:KioskMarker;
        private var _QRImage:AsyncImage;

        private var curSelectedMarker:MapMarker;

        public var onIdle:IdleDelegate;

        public function resetViews():void
        {
            _listCategories.visible = false;
            _listCategories.selectedIndex = -1;
            _listAttractions.visible = false;
            _listAttractions.selectedIndex = -1;
            _detailsView.visible = false;
        }

        public function gotoCategories():void
        {
            resetViews();
            _listCategories.visible = true;
            
            _map.x = _listCategories.width;
            _map.setSize(_theStage.stageWidth - _listCategories.width, _theStage.stageHeight);

            deselectMarker();
        }

        public function gotoAttractions(categoryId:Number):void
        {
            resetViews();

            var attractions = new Vector.<Dictionary.<String, Object>>();
            for each(var item:Dictionary.<String, Object> in _data.locations)
            {
                var catId = item["catid"] as Number;
                if (catId == categoryId || categoryId == -1)
                {
                    attractions.pushSingle(item);
                }
            }

            var back = new Dictionary.<String, Object>();
            back["name"] = " < Back";

            attractions.pushSingle(back);

            _listAttractions.dataProvider = new ListCollection(attractions);
            _listAttractions.visible = true;

            _flyer.flyTo(Main.startLocation, true);

            _map.x = _listAttractions.width;
            _map.setSize(_theStage.stageWidth - _listAttractions.width, _theStage.stageHeight);

            deselectMarker();
        }

        public function gotoDetails(dict:Dictionary.<String, Object>):void
        {
            resetViews();
            _detailsView.visible = true;

            //_detailsView.setData(dict);

            _detailsTitle.graphics.clear();
            _detailsDesc.graphics.clear();

            var tfTitle = new TextFormat(null, 30, 0x0, true);
            _detailsTitle.graphics.textFormat(tfTitle);
            _detailsTitle.graphics.drawTextBox(0, 0, 300, dict["name"] as String);

            _detailsDesc.y = _detailsTitle.y + _detailsTitle.height + 20;
            var tfDetails = new TextFormat(null, 25, 0x0, true);
            _detailsDesc.graphics.textFormat(tfDetails);
            _detailsDesc.graphics.drawTextBox(0, 0, 300, dict["details"] as String);

            _detailsView.removeChild(_QRImage);
            //_QRImage.dispose(); // Disabled as it crashes when you do it fast.
            _QRImage = QRMaker.generateFromLocation(dict["lat"] as String, dict["lon"] as String,256);
            _QRImage.x = 320/2 - _detailsView.paddingLeft;
            _QRImage.y = _detailsDesc.y + _detailsDesc.height + 20 + _QRImage.height/2;
            _detailsView.addChild(_QRImage);

            updateHeader(dict);

            _map.x = 320;
            _map.setSize(_theStage.stageWidth - 320, _theStage.stageHeight);
        }
        
        public var _theStage:Stage = null;

        public function MapExplorer(stage:Stage)
        {
            _theStage = stage;
            _map = new Map(stage.stageWidth,
                           stage.stageHeight,
                           true,
                           new MicrosoftRoadMapProvider(true),
                           stage,
                           null);
            addChild(_map);

            _flyer = new MapFlyer(_map);

            _listAttractions = new List();
            _listAttractions.width = 400;
            _listAttractions.isSelectable = true;
            _listAttractions.allowMultipleSelection = false;
            _listAttractions.height = height;
            _listAttractions.itemRendererProperties["labelField"] = "name";
            _listAttractions.addEventListener(Event.CHANGE, list_changeHandler);
            _listAttractions.layoutData = new AnchorLayoutData(0, 0, 0, 0);
            addChild(_listAttractions);

            _listCategories = new List();
            _listCategories.width = 400;
            _listCategories.visible = false;
            _listCategories.isSelectable = true;
            _listCategories.allowMultipleSelection = false;
            _listCategories.height = height;
            _listCategories.itemRendererProperties["labelField"] = "name";
            _listCategories.addEventListener(Event.CHANGE, listCategory_changeHandler);
            _listCategories.layoutData = new AnchorLayoutData(0, 0, 0, 0);
            addChild(_listCategories);

            _detailsView = new Panel();
            _detailsView.width = 320;
            _detailsView.height = height;
            _detailsView.headerFactory = function():ImageLoader {
                _detailsHeader = new ImageLoader();
                return _detailsHeader;
            };
            _detailsView.footerFactory = function():Button {
                _detailsBack.label = "< Back";
                return _detailsBack;
            };
            _detailsView.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
            addChild(_detailsView);

            _detailsTitle = new Shape();
            _detailsDesc = new Shape();
            _detailsTitle.y = 10;
            _detailsView.addChild(_detailsTitle);
            _detailsView.addChild(_detailsDesc);
            _detailsBack = new Button();

            _QRImage = new AsyncImage(null, null, 0, 0);

            _timer = new Timer(3 * 60 * 1000); // 3 minute timeout
            _timer.onComplete += function()
            {
                if (this.visible)
                    onIdle();
            };
            _timer.start();

            _map.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            _map.addEventListener(TouchEvent.TOUCH, touchHandler);
            _map.addEventListener(ScrollWheelEvent.SCROLLWHEEL, wheelHandler);
            _listAttractions.addEventListener(TouchEvent.TOUCH, touchHandler);
            _listCategories.addEventListener(TouchEvent.TOUCH, touchHandler);
            _detailsView.addEventListener(TouchEvent.TOUCH, touchHandler);

            // Start in categories.
            gotoCategories();
        }

        public function setData(data:MapData)
        {
            _data = data;
            _listAttractions.dataProvider = new ListCollection(_data.locations);
            _listCategories.dataProvider = new ListCollection(_data.categories);
            updateMarkers();
        }

        private function updateHeader(dict:Dictionary.<String, Object>)
        {
            var tex:Texture = Texture.fromAsset("assets/no-image.jpg");

            if (dict && (dict["img"] as String).length > 0)
            {
                trace("Image");
                tex = Texture.fromAsset(dict["img"] as String);
            }

            var ratio = 3 / 4;

            var w0 = tex.width;
            var h0 = tex.height;
            if (w0 * ratio > h0)
                w0 = h0 / ratio;
            else
                h0 = w0 * ratio;

            tex = Texture.fromTexture(tex, new Rectangle((tex.width - w0) / 2, (tex.height - h0) / 2, w0, h0));

            _detailsHeader.source = tex;

            _detailsHeader.scaleX = 320 / tex.width;
            _detailsHeader.scaleY = _detailsHeader.scaleX;
        }

        public function gotoLocation(location:Location, zoom:Number)
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
            if (keycode == LoomKey.V) trace(_map.getZoom());

            // precise zooming
            if (keycode == LoomKey.EQUALS)
                _map.zoomByAbout(0.05, zoomPoint);
            if (keycode == LoomKey.HYPHEN)
                _map.zoomByAbout( -0.05, zoomPoint);

            _timer.reset();
            _flyer.stop();
        }

        private function touchHandler(e:TouchEvent):void
        {
            var t:Touch = e.getTouch(stage, TouchPhase.HOVER);
            if (t)
                return;

            t = e.getTouch(stage, TouchPhase.ENDED);
            if (t)
            {
                if (e.target.getType() == MapMarker)
                {
                    var marker:MapMarker = MapMarker(e.target);
                    var dict:Dictionary.<String, Object> = _data.locations[marker.id] as Dictionary.<String, Object>;
                    if (dict)
                        selectLocation(dict);
                }
                else if (e.target == _detailsBack)
                {
                    gotoCategories();
                }
            }
            else
            {
                //Disabled because it messes up the case that the flyer is flying
                //back to the kiosk and you select nother target location.
                if (_flyer.isFlying && false)
                {
                    _flyer.stop();
                    gotoCategories();
                }
            }

            _timer.reset();
        }
        
        private function wheelHandler(e:ScrollWheelEvent):void
        {
            if (e.delta != 0 && _flyer.isFlying) {
                _flyer.stop();
                gotoCategories();
            }
        }

        private function list_changeHandler(event:Event):void
        {
            var dict:Dictionary.<String, Object> = _listAttractions.selectedItem as Dictionary.<String, Object>;
            if(!dict)
                return;

            if (dict["lon"] == null)
            {
                gotoCategories();
            }
            else
            {
                selectLocation(dict);
            }
        }

        private function listCategory_changeHandler(event:Event):void
        {
            var category:Dictionary.<String, Object> = _listCategories.selectedItem as Dictionary.<String, Object>;
            if(!category)
                return;
            var categoryId = Number(category["id"]);
            gotoAttractions(categoryId);
            _timer.reset();
        }

        private function deselectMarker():void
        {
            // Deselect old marker.
            if(curSelectedMarker)
            {
                curSelectedMarker.deselect();
                curSelectedMarker = null;
            }
        }

        private function selectLocation(dict:Dictionary.<String, Object>)
        {
            deselectMarker();

            // Select the marker.
            var m = dict["marker"] as MapMarker;
            if(m)
            {
                m.select();
                curSelectedMarker = m;
            }

            trace("Attraction selected: " + dict['name']);
            var targetLat = Number.fromString(dict['lat'] as String);
            var targetLon = Number.fromString(dict['lon'] as String);
            trace("   o Lat = " + targetLat);
            trace("   o Lon = " + targetLon);
            flyTo(new Location(targetLat, targetLon));
            gotoDetails(dict);
            _timer.reset();
        }

        private function updateMarkers():void
        {
            _map.removeAllMarkers();
            _kiosk = new KioskMarker();
            _kiosk.scale = .75;
            _map.putMarker(Main.startLocation, _kiosk);

            for (var i:uint = 0; i < _data.locations.length; i++)
            {
                var _currentItem:Dictionary.<String, Object> = _data.locations[i] as Dictionary.<String, Object>;
                var loc:Location = new Location(Number(_currentItem['lat']), Number(_currentItem['lon']));
                var marker:MapMarker = new MapMarker(i);
                marker.scale = .50;
                _currentItem["marker"] = marker;
                _map.putMarker(loc, marker);
            }
        }
    }
}