package org.okapp.guieditor.view.controls
{
    import mx.containers.Canvas;
    import mx.controls.Label;
    import mx.controls.Text;
    import mx.controls.TextArea;

    import org.okapp.guieditor.model.DataFile;

    public class RawFileEditor extends Canvas
    {
        //-----------------------------
        // data file
        //-----------------------------

        private var _dataFile:DataFile = null;
        private var _dataFileChanged:Boolean = false;


        public function get dataFile():DataFile
        {
            return _dataFile;
        }

        public function set dataFile(value:DataFile):void
        {
            _dataFile = value;
            _dataFileChanged = true;
            invalidateProperties();
        }


        //-----------------------------
        // Constructor
        //-----------------------------

        public function RawFileEditor()
        {
            super();
        }

        public function update():void
        {
            if (dataFile)
            {
                lblTitle.text = _dataFile.file.nativePath;

                if (_dataFile.isValid)
                {
                    taEditor.text = _dataFile.strBuffer;
                }
                else
                {
                    taEditor.text = _dataFile.log;
                }
            }
            else
            {
                taEditor.text = "";
                lblTitle.text = "no file";
            }
        }



        //-------------------------------------------------------------------
        // Implement API
        //-------------------------------------------------------------------

        override protected function createChildren():void
        {
            super.createChildren();

            if (taEditor == null)
            {
                taEditor = new Text();
                taEditor.top = 20;
                taEditor.left = 0;
                taEditor.right = 0;
                taEditor.bottom = 0;
                taEditor.selectable = true;
                taEditor.setStyle("fontFamily", "_typewriter");
                taEditor.setStyle("fontSize", 12);
                addChild(taEditor);
            }

            if (lblTitle == null)
            {
                lblTitle = new Label();
                lblTitle.top = 0;
                lblTitle.left = 0;
                lblTitle.right = 0;
                lblTitle.height = 20;
                lblTitle.setStyle("fontFamily", "_sans");
                lblTitle.setStyle("fontSize", 12);
                lblTitle.setStyle("fontWeight", "bold");
                addChild(lblTitle);
            }
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_dataFileChanged)
            {
                update();
            }

        }

        private var taEditor:Text;
        private var lblTitle:Label;
    }
}
