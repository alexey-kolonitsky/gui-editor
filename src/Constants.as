package
{
    public class Constants
    {
        public static const APPLICATION_NAME:String = "gui-editor";
        public static const APPLICATION_VERSION:String = "0.0.1";

        public static const AUTOSAVE_DELAY:Number = 1000;


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

        public static const OKAPP_ANIMATION_MODEL_NS:Namespace = new Namespace(OKAPP_ANIMATION_MODEL_NAMESPACE);
        public static const OKAPP_ANIMATION_MODEL_NAMESPACE:String = "http://wwww.okapp.ru/animation/0.1";
        public static const OKAPP_ANIMATION_MODEL_FILE_EXTENSION:String = "xml";

        public static const OKAPP_GUI_NAMESPACE:String = "http://wwww.okapp.ru/gui/0.1";
        public static const OKAPP_GUI_FILE_EXTENSION:String = "xml";
    }
}
