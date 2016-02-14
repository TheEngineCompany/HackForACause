package
{
    import loom.modestmaps.extras.Distance;
    import loom.modestmaps.geo.Location;
    import loom.modestmaps.Map;
    import loom.modestmaps.mapproviders.IMapProvider;
    import loom.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider;
    import loom2d.display.DisplayObject;
    import loom.modestmaps.core.Coordinate;
    import loom2d.display.Graphics;
    import loom2d.display.Shape;
    import loom2d.display.TextAlign;
    import loom2d.display.TextFormat;
    import loom2d.events.TouchEvent;
    import loom2d.events.TouchPhase;
    import loom2d.events.Touch;
    import loom2d.math.Point;
    import system.platform.File;
    import system.platform.Platform;
    import loom.gameframework.TimeManager;
    import loom.gameframework.LoomGroup;
    import loom.gameframework.ITicked;

    public class MapFlyer implements ITicked
    {
        private var sHelperPoint:Point;

        private var lastTime:Number;

        private var map:Map;

        private var flyTarget:Location;
        private var flyPoint:Point;
        private var flySpeed:Number;
        private var nextLocation = new Location(0, 0);
        private var stopped:Boolean = true;
        private var goingHome:Boolean = false;

        public function MapFlyer(map:Map)
        {
            this.map = map;
            map.addEventListener(TouchEvent.TOUCH, function(e:TouchEvent)
            {
                var touch = e.getTouch(e.target as DisplayObject, TouchPhase.BEGAN);
                if (touch) {
                    stopped = true;
                }
                touch = e.getTouch(e.target as DisplayObject, TouchPhase.ENDED);
                if (touch) {
                    checkBounds();
                }
            });

            var timeManager:TimeManager = LoomGroup.rootGroup.getManager(TimeManager) as TimeManager;
            timeManager.addTickedObject(this);
        }

        public var forceZoom:Number = NaN;

        public function flyTo(location:Location, home:Boolean = false) {
            goingHome = home;

            var locations:Vector.<Location> = [location, Main.startLocation];
            var coordinate:Coordinate = map.locationsCoordinate(locations);
            forceZoom = coordinate.zoom * 0.995;
            flyTarget = map.getMapProvider().coordinateLocation(coordinate);
            stopped = false;
            flySpeed = 0;
        }

        public function get isFlying():Boolean
        {
            return !stopped;
        }

        public function stop()
        {
            stopped = true;
        }

        public function checkBounds():void
        {
            var currentLocation:Location = map.getCenter();
            var currentZoom:Number = map.getZoomFractional();

            var dirty:Boolean = false;

            if (currentLocation.lat > 44.05320)
            {
                dirty = true;
                currentLocation.lat = 44.05320;
            }

            if (currentLocation.lat < 44.04771)
            {
                dirty = true;
                currentLocation.lat = 44.04771;
            }

            if (currentLocation.lon > -123.08974)
            {
                dirty = true;
                currentLocation.lon = -123.08974;
            }

            if (currentLocation.lon < -123.09733)
            {
                dirty = true;
                currentLocation.lon = -123.09733;
            }

            if (currentZoom < 17)
            {
                dirty = true;
                currentZoom = 17;
            }

            // Don't set map unless we have to.
            if(dirty)
                map.setCenterZoom(currentLocation, currentZoom);
        }

        public function onTick()
        {
            if (stopped)
            {
                return;
            }

            var curTime = Platform.getTime();
            var dt = Number(curTime - lastTime) / Number(1000);

            // Sanity for delta time.
            if(dt > 0.25) dt = 0.1;
            if(dt < 0.01) return;

            lastTime = curTime;

            var currentLocation:Location = map.getCenter();
            var currentZoom:Number = map.getZoomFractional();
            var dist = Distance.haversineDistance(currentLocation, flyTarget);

            var minZoom = map.getMapProvider().outerLimits()[0].zoom;
            var maxZoom = map.getMapProvider().outerLimits()[1].zoom;
            var zoomRange = maxZoom-minZoom;
            var zoomDist = 1e4;

            var moveSpeedMax = 10e6;

            var targetZoom = minZoom+(maxZoom-minZoom)*(1-Math.sqrt(Math.min2(1, dist/zoomDist)));
            if(!isNaN(forceZoom))
                targetZoom = forceZoom;
            if(goingHome)
                targetZoom = 17;

            var zoomDiff = targetZoom - currentZoom;

            sHelperPoint.x = map.getWidth() / 2;
            sHelperPoint.y = map.getHeight() / 2;

            var zoomSpeed = zoomDiff*0.3;
            var zoomDampen = Math.pow(1-Math.abs(zoomDiff/zoomRange), 4);

            var moveAccel = Math.min2((dist-flySpeed*0.9)*20, 50e6)*zoomDampen-flySpeed;

            flySpeed += moveAccel*dt;
            flySpeed *= 0.98;

            flySpeed = Math.min2(moveSpeedMax, flySpeed);

            flyPoint.x = flyTarget.lon-currentLocation.lon;
            flyPoint.y = flyTarget.lat-currentLocation.lat;
            flyPoint.normalize(1);

            // Speed in m/s to degrees/s
            flyPoint.x *= flySpeed/(111111*Math.cos(currentLocation.lat/180*Math.PI));
            flyPoint.y *= flySpeed/111111;

            var away = Math.abs(zoomDiff)*5*0.5+dist/100*0.5;

            nextLocation.lat = currentLocation.lat+flyPoint.y*dt;
            nextLocation.lon = currentLocation.lon+flyPoint.x*dt;

            map.panAndZoomBy(1+zoomSpeed*dt, nextLocation, sHelperPoint);

            if (away < 0.1) {
                stopped = true;
            }
        }
    }

}