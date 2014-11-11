package org.okapp.guieditor.view
{
    import flash.events.Event;

    import org.okapp.guieditor.model.DataFile;

    import spark.components.Group;

    import starling.core.Starling;

    /**
     * Base class for all admin pages.
     */
    public class BaseScreen extends Group
    {
        //-----------------------------
        // starling
        //-----------------------------

        private var _starling:Starling;
        private var _starlingChanged:Boolean = false;

        [Bindable]
        public function get starling():Starling
        {
            return _starling;
        }

        public function set starling(value:Starling):void
        {
            _starling = value;
            _starlingChanged = true;
            invalidateProperties();
        }

        //-----------------------------
        // DataFile
        //-----------------------------

        protected var _dataFile:DataFile;

        //-----------------------------
        // Constructor
        //-----------------------------

        public function BaseScreen ()
        {
            super();
            addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }


        //-------------------------------------------------------------------
        // Base Screen API
        //-------------------------------------------------------------------

        /**
         * This method invoked after starling instance set in _starling
         * property and after adding screen on display list.
         */
        protected function createPreview():void
        {
            trace("Screen createPreview method should be overrid by sub class")
        }

        /**
         * This method invoked after removing screen from display list.
         */
        protected function removePreview():void
        {
            trace("Screen removePreview method should be overrid by sub class")
        }


        //-------------------------------------------------------------------
        // UIComponent implementation
        //-------------------------------------------------------------------

        override protected function commitProperties ():void
        {
            super.commitProperties();

            if (_starlingChanged)
            {
                createPreview();
                _starlingChanged = false;
            }
        }


        //-------------------------------------------------------------------
        // Event handlers
        //-------------------------------------------------------------------

        private function removedFromStageHandler(event:Event):void
        {
            removePreview();
        }

        private function addedToStageHandler (event:Event):void
        {
            createPreview();
        }
    }
}
