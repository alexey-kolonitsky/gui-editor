package
{
    public class Constants
    {
        public static const APPLICATION_NAME:String = "gui-editor";
        public static const APPLICATION_VERSION:String = "0.0.1";

        public static const AUTOSAVE_DELAY:Number = 1000;

        public static const COLOR_INTERFACE_INACTIVE:uint = 0xEFEFEF;
        public static const COLOR_INTERFACE_HOVER:uint = 0x9DC1F5;
        public static const COLOR_INTERFACE_SELECTED:uint = 0x4C8CE6;

        public static const LAYER_NAME_PATTERN:String = "Layer #";
        public static const LAYER_COLOR:Vector.<uint> = new <uint>[0xF0F8FF, 0xFF4500, 0x8B0000, 0xFFD700, 0xA52A2A, 0xEE82EE, 0x00FFFF];

        //-----------------------------
        // Shared Object
        //-----------------------------

        public static const SO_SELECTED_SCREEN:String = "current_screen";
        public static const SO_LAYOUT_PATH:String = "last_layout_url";
        public static const SO_ANIMATION_DIRECTORY:String = "so_animation_directory";
        public static const SO_ANIMATION_PATH:String = "las_animation_url";


        //-----------------------------
        // XML NameSpaces
        //-----------------------------

        public static const DEFAULT_ANIMATION_STATE:String = "default";
        public static const OKAPP_ANIMATION_MODEL_NS:Namespace = new Namespace(OKAPP_ANIMATION_MODEL_NAMESPACE);
        public static const OKAPP_ANIMATION_MODEL_NAMESPACE:String = "http://wwww.okapp.ru/animation/0.1";
        public static const OKAPP_ANIMATION_MODEL_FILE_EXTENSION:String = "xml";

        public static const OKAPP_GUI_NAMESPACE:String = "http://wwww.okapp.ru/gui/0.1";
        public static const OKAPP_GUI_FILE_EXTENSION:String = "xml";

    }
}
