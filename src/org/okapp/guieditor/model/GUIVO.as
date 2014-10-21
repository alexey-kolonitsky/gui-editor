package org.okapp.guieditor.model
{
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class GUIVO extends DataFile
    {

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
