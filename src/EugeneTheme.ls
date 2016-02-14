package
{
    import feathers.controls.Button;
    import feathers.controls.ButtonGroup;
    import feathers.controls.Callout;
    import feathers.controls.Check;
    import feathers.controls.GroupedList;
    import feathers.controls.Header;
    import feathers.controls.ImageLoader;
    import feathers.controls.Label;
    import feathers.controls.List;
    import feathers.controls.NumericStepper;
    import feathers.controls.PageIndicator;
    import feathers.controls.Panel;
    import feathers.controls.PanelScreen;
    import feathers.controls.PickerList;
    import feathers.controls.ProgressBar;
    import feathers.controls.Radio;
    import feathers.controls.Screen;
    import feathers.controls.ScrollContainer;
    import feathers.text.VectorTextRenderer;
    import feathers.text.VectorTextEditor;
    import loom.modestmaps.core.QuadNode;
    import loom2d.display.TextFormat;
    import feathers.controls.SimpleScrollBar;
    import feathers.controls.Slider;
    import feathers.controls.TabBar;
    import feathers.controls.TextInput;
    import feathers.controls.ToggleSwitch;
    import feathers.controls.popups.CalloutPopUpContentManager;
    import feathers.controls.popups.VerticalCenteredPopUpContentManager;
    import feathers.controls.renderers.BaseDefaultItemRenderer;
    import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
    import feathers.controls.renderers.DefaultGroupedListItemRenderer;
    import feathers.controls.renderers.DefaultListItemRenderer;
    import feathers.core.DisplayListWatcher;
    import feathers.core.FeathersControl;
    import feathers.core.PopUpManager;
    import feathers.display.Scale3Image;
    import feathers.display.Scale9Image;
    import feathers.display.TiledImage;
    import feathers.layout.HorizontalLayout;
    import feathers.layout.VerticalLayout;
    import feathers.skins.SmartDisplayObjectStateValueSelector;
    import feathers.skins.StandardIcons;
    import feathers.system.DeviceCapabilities;
    import feathers.textures.Scale3Textures;
    import feathers.textures.Scale9Textures;

    import feathers.text.DummyTextRenderer;
    import feathers.text.DummyTextEditor;
    import feathers.core.ITextEditor;
    import feathers.core.ITextRenderer;

    import loom2d.math.Rectangle;

    import loom2d.Loom2D;;
    import loom2d.display.DisplayObject;
    import loom2d.display.DisplayObjectContainer;
    import loom2d.display.Image;
    import loom2d.display.Quad;
    import loom2d.events.Event;
    import loom2d.events.ResizeEvent;
    import loom2d.textures.Texture;
    import loom2d.textures.TextureAtlas;

    public class EugeneTheme extends DisplayListWatcher
    {
        protected static const PRIMARY_BACKGROUND_COLOR:uint = 0xFFFFFF;
        protected static const TEXT_COLOR:uint = 0x1a1816;
        protected static const SELECTED_TEXT_COLOR:uint = 0x1a1816;
        protected static const DISABLED_TEXT_COLOR:uint = 0x383430;
        protected static const ITEM_COLOR = 0xF0F0F0;
        protected static const SELECTED_ITEM_COLOR = 0xD0D0D0;
        protected static const DISABLED_ITEM_COLOR = 0xA0A0A0;

        protected static const LIST_BACKGROUND_COLOR:uint = 0x383430;
        protected static const TAB_BACKGROUND_COLOR:uint = 0x1a1816;
        protected static const TAB_DISABLED_BACKGROUND_COLOR:uint = 0x292624;
        protected static const MODAL_OVERLAY_COLOR:uint = 0x1a1816;
        protected static const GROUPED_LIST_HEADER_BACKGROUND_COLOR:uint = 0x2e2a26;
        protected static const GROUPED_LIST_FOOTER_BACKGROUND_COLOR:uint = 0x2e2a26;

        protected static const ORIGINAL_DPI_IPHONE_RETINA:int = 326;
        protected static const ORIGINAL_DPI_IPAD_RETINA:int = 264;

        protected static const DEFAULT_SCALE9_GRID:Rectangle = new Rectangle(5, 5, 22, 22);
        protected static const BUTTON_SCALE9_GRID:Rectangle = new Rectangle(5, 5, 50, 50);
        protected static const BUTTON_SELECTED_SCALE9_GRID:Rectangle = new Rectangle(8, 8, 44, 44);
        protected static const BACK_BUTTON_SCALE3_REGION1:Number = 24;
        protected static const BACK_BUTTON_SCALE3_REGION2:Number = 6;
        protected static const FORWARD_BUTTON_SCALE3_REGION1:Number = 6;
        protected static const FORWARD_BUTTON_SCALE3_REGION2:Number = 6;
        protected static const ITEM_RENDERER_SCALE9_GRID:Rectangle = new Rectangle(13, 0, 2, 82);
        protected static const INSET_ITEM_RENDERER_FIRST_SCALE9_GRID:Rectangle = new Rectangle(13, 13, 3, 70);
        protected static const INSET_ITEM_RENDERER_LAST_SCALE9_GRID:Rectangle = new Rectangle(13, 0, 3, 75);
        protected static const INSET_ITEM_RENDERER_SINGLE_SCALE9_GRID:Rectangle = new Rectangle(13, 13, 3, 62);
        protected static const TAB_SCALE9_GRID:Rectangle = new Rectangle(19, 19, 50, 50);
        protected static const SCROLL_BAR_THUMB_REGION1:int = 5;
        protected static const SCROLL_BAR_THUMB_REGION2:int = 14;

        public static const COMPONENT_NAME_PICKER_LIST_ITEM_RENDERER:String = "feathers-mobile-picker-list-item-renderer";

        protected static function textRendererFactory():ITextRenderer
        {
            return new VectorTextRenderer();
        }

        protected static function textEditorFactory():ITextEditor
        {
            return new VectorTextEditor();
        }

        protected static function stepperTextEditorFactory():ITextEditor
        {
            return new VectorTextEditor();
        }

        protected static function popUpOverlayFactory():DisplayObject
        {
            const quad:Quad = new Quad(100, 100, MODAL_OVERLAY_COLOR);
            quad.alpha = 0.75;
            return quad;
        }

        public function EugeneTheme(container:DisplayObjectContainer = null, scaleToDPI:Boolean = true)
        {
            if(!container)
            {
                container = Loom2D.stage;
            }
            super(container);
            this._scaleToDPI = scaleToDPI;
            this.initialize();
        }

        protected var _originalDPI:int;

        public function get originalDPI():int
        {
            return this._originalDPI;
        }

        protected var _scaleToDPI:Boolean;

        public function get scaleToDPI():Boolean
        {
            return this._scaleToDPI;
        }

        public var scale:Number = 1;

        public var headerTextFormat:TextFormat;

        public var smallUITextFormat:TextFormat;
        public var smallUISelectedTextFormat:TextFormat;
        public var smallUIDisabledTextFormat:TextFormat;

        public var largeUITextFormat:TextFormat;
        public var largeUISelectedTextFormat:TextFormat;
        public var largeUIDisabledTextFormat:TextFormat;

        public var largeTextFormat:TextFormat;
        public var largeDisabledTextFormat:TextFormat;

        public var smallTextFormat:TextFormat;
        public var smallDisabledTextFormat:TextFormat;
        public var smallTextFormatCentered:TextFormat;

        override public function dispose():void
        {
            if(this.root)
            {
                this.root.removeEventListener(Event.ADDED_TO_STAGE, root_addedToStageHandler);
            }
            super.dispose();
        }

        protected function initializeRoot():void
        {
            if(this.root != this.root.stage)
            {
                trace("Aborting due to not knowing properly about Stage!");
                return;
            }

            this.root.stage.color = PRIMARY_BACKGROUND_COLOR;
        }

        protected function initialize():void
        {
            const scaledDPI:int = DeviceCapabilities.dpi / Loom2D.contentScaleFactor;
            this._originalDPI = scaledDPI;
            if(this._scaleToDPI)
            {
                if(DeviceCapabilities.isTablet()) //Starling.current.nativeStage))
                {
                    this._originalDPI = ORIGINAL_DPI_IPAD_RETINA;
                }
                else
                {
                    this._originalDPI = ORIGINAL_DPI_IPHONE_RETINA;
                }
            }

            this.scale = scaledDPI / this._originalDPI;

            FeathersControl.defaultTextRendererFactory = textRendererFactory;
            FeathersControl.defaultTextEditorFactory = textEditorFactory;

            const regularFontNames:String = "sans";
            const semiboldFontNames:String = "sans";

            this.headerTextFormat = new TextFormat(semiboldFontNames, Math.round(36 * this.scale), TEXT_COLOR, true);

            this.smallUITextFormat = new TextFormat(semiboldFontNames, 24 * this.scale, TEXT_COLOR, true);
            this.smallUISelectedTextFormat = new TextFormat(semiboldFontNames, 24 * this.scale, SELECTED_TEXT_COLOR, true);
            this.smallUIDisabledTextFormat = new TextFormat(semiboldFontNames, 24 * this.scale, DISABLED_TEXT_COLOR, true);

            this.largeUITextFormat = new TextFormat(semiboldFontNames, 28 * this.scale, TEXT_COLOR, true);
            this.largeUISelectedTextFormat = new TextFormat(semiboldFontNames, 28 * this.scale, SELECTED_TEXT_COLOR, true);
            this.largeUIDisabledTextFormat = new TextFormat(semiboldFontNames, 28 * this.scale, DISABLED_TEXT_COLOR, true);

            this.smallTextFormat = new TextFormat(regularFontNames, 24 * this.scale, TEXT_COLOR);
            this.smallDisabledTextFormat = new TextFormat(regularFontNames, 24 * this.scale, DISABLED_TEXT_COLOR);
            this.smallTextFormatCentered = new TextFormat(regularFontNames, 24 * this.scale, TEXT_COLOR);

            this.largeTextFormat = new TextFormat(regularFontNames, 28 * this.scale, TEXT_COLOR);
            this.largeDisabledTextFormat = new TextFormat(regularFontNames, 28 * this.scale, DISABLED_TEXT_COLOR);

            PopUpManager.overlayFactory = popUpOverlayFactory;
            Callout.stagePaddingTop = Callout.stagePaddingRight = Callout.stagePaddingBottom =
            Callout.stagePaddingLeft = 16 * this.scale;

            // Load the theme atlas.
            var xmld = new XMLDocument();

            if(this.root.stage)
            {
                this.initializeRoot();
            }
            else
            {
                this.root.addEventListener(Event.ADDED_TO_STAGE, root_addedToStageHandler);
            }

            this.setInitializerForClassAndSubclasses(Screen, screenInitializer);
            this.setInitializerForClassAndSubclasses(PanelScreen, panelScreenInitializer);
            this.setInitializerForClass(Panel, panelInitializer);
            this.setInitializerForClass(Label, labelInitializer);
            this.setInitializerForClass(Button, buttonInitializer);
            this.setInitializerForClass(DefaultListItemRenderer, itemRendererInitializer);
            this.setInitializerForClass(ScrollContainer, scrollContainerInitializer);
            this.setInitializerForClass(List, listInitializer);
        }

        protected function imageLoaderFactory():ImageLoader
        {
            const image:ImageLoader = new ImageLoader();
            image.textureScale = this.scale;
            return image;
        }

        protected function horizontalScrollBarFactory():SimpleScrollBar
        {
            const scrollBar:SimpleScrollBar = new SimpleScrollBar();
            scrollBar.direction = SimpleScrollBar.DIRECTION_HORIZONTAL;
            var d:Dictionary.<String, Object> = scrollBar.thumbProperties;            d["defaultSkin"] = new Quad(100, 100, 0xFF0000);
            scrollBar.paddingRight = scrollBar.paddingBottom = scrollBar.paddingLeft = 4 * this.scale;
            return scrollBar;
        }

        protected function verticalScrollBarFactory():SimpleScrollBar
        {
            const scrollBar:SimpleScrollBar = new SimpleScrollBar();
            scrollBar.direction = SimpleScrollBar.DIRECTION_VERTICAL;
            scrollBar.width = 10;
            scrollBar.paddingTop = scrollBar.paddingRight = scrollBar.paddingBottom = 1 * this.scale;
            scrollBar.thumbFactory = function():Button
            {
                trace("thumbInitalizer");
                var thumb = new Button();
                trace("thumbInitalizer");
                const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
                skinSelector.defaultValue = DISABLED_ITEM_COLOR;
                skinSelector.displayObjectProperties =
                {
                    width: 10 * this.scale,
                };
                thumb.width = 10;
                thumb.stateToSkinFunction = skinSelector.updateValue;
                return thumb;
            };
            return scrollBar;
        }

        protected function nothingInitializer(target:DisplayObject):void {}

        protected function screenInitializer(screen:Screen):void
        {
            screen.originalDPI = this._originalDPI;
        }

        protected function panelScreenInitializer(screen:PanelScreen):void
        {
            screen.originalDPI = this._originalDPI;

            screen.verticalScrollBarFactory = this.verticalScrollBarFactory;
            screen.horizontalScrollBarFactory = this.horizontalScrollBarFactory;
        }

        protected function labelInitializer(label:Label):void
        {
            label.textRendererProperties["textFormat"] = this.smallTextFormat;
            //label.textRendererProperties["embedFonts"] = true;
        }

        protected function baseButtonInitializer(button:Button):void
        {
            button.defaultLabelProperties["textFormat"] = this.smallUITextFormat;
            button.disabledLabelProperties["textFormat"] = this.smallUIDisabledTextFormat;
            button.selectedDisabledLabelProperties["textFormat"] = this.smallUIDisabledTextFormat;

            button.paddingTop = button.paddingBottom = 8 * this.scale;
            button.paddingLeft = button.paddingRight = 16 * this.scale;
            button.gap = 12 * this.scale;
            button.minWidth = button.minHeight = 60 * this.scale;
            button.minTouchWidth = button.minTouchHeight = 88 * this.scale;

            trace("baseButtonInitalizer");
        }

        protected function buttonInitializer(button:Button):void
        {
            if (button.stateToSkinFunction == null)
            {
                const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
                skinSelector.defaultValue = ITEM_COLOR;
                skinSelector.defaultSelectedValue = SELECTED_ITEM_COLOR;
                skinSelector.setValueForState(SELECTED_ITEM_COLOR, Button.STATE_DOWN, false);
                skinSelector.setValueForState(DISABLED_ITEM_COLOR, Button.STATE_DISABLED, false);
                skinSelector.setValueForState(DISABLED_ITEM_COLOR, Button.STATE_DISABLED, true);
                skinSelector.displayObjectProperties =
                {
                    width: 60 * this.scale,
                    height: 60 * this.scale
                };
                button.stateToSkinFunction = skinSelector.updateValue;
            }
            this.baseButtonInitializer(button);

        }

        protected function itemRendererInitializer(renderer:BaseDefaultItemRenderer):void
        {
            const skinSelector:SmartDisplayObjectStateValueSelector = new SmartDisplayObjectStateValueSelector();
            skinSelector.defaultValue = PRIMARY_BACKGROUND_COLOR;
            skinSelector.displayObjectProperties =
            {
                width: 88 * this.scale,
                height: 88 * this.scale
            };
            renderer.stateToSkinFunction = skinSelector.updateValue;

            renderer.defaultLabelProperties["textFormat"] = this.largeTextFormat;
            renderer.downLabelProperties["textFormat"] = this.largeTextFormat;
            renderer.defaultSelectedLabelProperties["textFormat"] = this.largeTextFormat;

            renderer.horizontalAlign = Button.HORIZONTAL_ALIGN_LEFT;
            renderer.paddingTop = renderer.paddingBottom = 8 * this.scale;
            renderer.paddingLeft = 32 * this.scale;
            renderer.paddingRight = 24 * this.scale;
            renderer.gap = 20 * this.scale;
            renderer.iconPosition = Button.ICON_POSITION_LEFT;
            renderer.accessoryGap = Number.POSITIVE_INFINITY;
            renderer.accessoryPosition = BaseDefaultItemRenderer.ACCESSORY_POSITION_RIGHT;
            renderer.minWidth = renderer.minHeight = 88 * this.scale;
            renderer.minTouchWidth = renderer.minTouchHeight = 88 * this.scale;

            renderer.accessoryLoaderFactory = this.imageLoaderFactory;
            renderer.iconLoaderFactory = this.imageLoaderFactory;
        }

        protected function panelInitializer(panel:Panel):void
        {
            panel.paddingTop = 0;
            panel.paddingRight = 8 * this.scale;
            panel.paddingBottom = 8 * this.scale;
            panel.paddingLeft = 8 * this.scale;

            panel.verticalScrollBarFactory = this.verticalScrollBarFactory;
            panel.horizontalScrollBarFactory = this.horizontalScrollBarFactory;
        }

        protected function listInitializer(list:List):void
        {
            const backgroundSkin:Quad = new Quad(100, 100, PRIMARY_BACKGROUND_COLOR);
            list.backgroundSkin = backgroundSkin;

            list.verticalScrollBarFactory = this.verticalScrollBarFactory;
            list.horizontalScrollBarFactory = this.horizontalScrollBarFactory;
        }

        protected function scrollContainerInitializer(container:ScrollContainer):void
        {
            container.verticalScrollBarFactory = this.verticalScrollBarFactory;
            container.horizontalScrollBarFactory = this.horizontalScrollBarFactory;
        }

        protected function root_addedToStageHandler(event:Event):void
        {
            this.initializeRoot();
        }

    }
}
