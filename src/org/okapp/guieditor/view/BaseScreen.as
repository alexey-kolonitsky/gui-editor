package org.okapp.guieditor.view
{
    import spark.components.Group;

    import starling.core.Starling;

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
        // Constructor
        //-----------------------------

        public function BaseScreen ()
        {
            super();
        }

        /**
         * This method invoked after starling instance setted in _starling
         */
        protected function createPreview():void
        {
            trace("Screen createPreview method should be overrid by sub class")
        }

        override protected function commitProperties ():void
        {
            super.commitProperties();

            if (_starlingChanged)
            {
                createPreview();
                _starlingChanged = false;
            }
        }
    }
}
