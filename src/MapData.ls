package
{

    public class MapData
    {
        public var locations:Vector.<Dictionary.<String, Object>>;
        public var categories:Vector.<Dictionary.<String, Object>>;

        private function MapData()
        {
            locations = new Vector.<Dictionary.<String, Object>>();
            categories = new Vector.<Dictionary.<String, Object>>();
        }

        public static function parse(json:JSON):MapData
        {
            var result = new MapData();

            var jsonLocations = json.getArray("locations");
            for (var i = 0; i < jsonLocations.length; i++)
            {
                result.locations.pushSingle(jsonLocations.getArrayObject(i).getDictionary());
            }

            var jsonCategories = json.getArray("categories");
            for (i = 0; i < jsonCategories.length; i++)
            {
                result.categories.pushSingle(jsonCategories.getArrayObject(i).getDictionary());
            }

            var allCategory = new Dictionary.<String, Object>();
            allCategory["name"] = "All";
            allCategory["id"] = -1;
            allCategory["pin"] = "assets/pin.png";
            allCategory["color"] = "#FFFFFFFF";
            result.categories.pushSingle(allCategory);

            return result;
        }
    }

}