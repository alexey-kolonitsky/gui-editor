package org.okapp.guieditor.model
{
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class GUIVO extends DataFile
    {
        public static const GUI_FILE_NAME_TEMPLATE:String = "window_#.xml";
        public static const GUI_EMPTY_FILE_CONTENT:String = '<gui xmlns="http://wwww.okapp.ru/gui/0.1" xmlns:of="com.okapp.pirates.ui.controls">\n<of:Text text="Hello world!" /></gui>';

        //-----------------------------
        // Constructor
        //-----------------------------

        public function GUIVO(file:File):void
        {
            super(file, Constants.OKAPP_GUI_FILE_EXTENSION, Constants.OKAPP_GUI_NAMESPACE);
        }




        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------


    }
}
