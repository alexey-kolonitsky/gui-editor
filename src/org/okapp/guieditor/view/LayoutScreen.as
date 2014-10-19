package org.okapp.guieditor.view
{
    import com.okapp.pirates.ui.controls.Canvas;

    import feathers.system.DeviceCapabilities;

    import flash.filesystem.File;

    import mx.collections.ArrayCollection;
    import mx.controls.FileSystemTree;
    import mx.events.FlexEvent;
    import mx.events.ListEvent;

    import org.kolonitsky.alexey.StoredFieldManager;

    import org.okapp.guieditor.model.GUIVO;

    import spark.components.Group;
    import spark.components.Label;
    import spark.components.TextArea;
    import spark.events.TextOperationEvent;

    import starling.core.Starling;

    public class LayoutScreen extends BaseScreen
    {
        public var COL1_WIDTH:Number = 300;
        public var COL2_WIDTH:Number = 600;
        public var COL_GAP:Number = 4;


        //-----------------------------
        // selected file
        //-----------------------------

        private var _selectedFile:GUIVO = null;
        private var _selectedFileChanged:Boolean = false;

        [Bindable]
        public function get selectedFile():GUIVO
        {
            return _selectedFile;
        }

        public function set selectedFile(value:GUIVO):void
        {
            _selectedFile = value;
            _selectedFileChanged = true;
            invalidateProperties();
        }


        //-----------------------------
        // constructor
        //-----------------------------

        public function LayoutScreen()
        {
            super();

            StoredFieldManager.instance.initialize(Constants.APPLICATION_NAME + "v" + Constants.APPLICATION_VERSION);
        }



        //-------------------------------------------------------------------
        // UIComponenet API implementation
        //-------------------------------------------------------------------

        override protected function childrenCreated ():void
        {
            fsTreeXML_changeHandler(null);
            fsTreeXML.selectedPath = StoredFieldManager.instance.getString(Constants.SO_XML_PATH);
        }

        override protected function createChildren():void
        {
            super.createChildren();

            if(lblXMLDirecotry == null)
            {
                lblXMLDirecotry = new Label();
                lblXMLDirecotry.text = "Layout-file Location";
                lblXMLDirecotry.left = 0;
                lblXMLDirecotry.top = 0;
                lblXMLDirecotry.width = COL1_WIDTH;
                lblXMLDirecotry.bottom = 0;
                lblXMLDirecotry.setStyle("backgroundColor", 0xFFFFFF);
                addElement(lblXMLDirecotry);
            }

            if(fsTreeXML==null)
            {
                fsTreeXML = new FileSystemTree();
                fsTreeXML.left = 0;
                fsTreeXML.top = 30;
                fsTreeXML.width = COL1_WIDTH;
                fsTreeXML.bottom = 0;
                fsTreeXML.addEventListener(ListEvent.CHANGE,fsTreeXML_changeHandler);
                fsTreeXML.selectedPath = StoredFieldManager.instance.getString(Constants.SO_XML_PATH);
                addElement(fsTreeXML);

            }

            if(lblPreview==null)
            {
                lblPreview=new Label();
                lblPreview.y=0;
                lblPreview.left=COL1_WIDTH+COL_GAP;
                lblPreview.right=0;
                lblPreview.text="Preview";
                addElement(lblPreview);
            }

            if(taEditor==null)
            {
                taEditor=new TextArea();
                taEditor.top=600;
                taEditor.left=COL1_WIDTH+COL_GAP;
                taEditor.right=0;
                taEditor.bottom=0;
                taEditor.setStyle("fontFamily","_typewriter");
                taEditor.setStyle("fontSize",12);
                taEditor.addEventListener(TextOperationEvent.CHANGE,editor_changeHandler);
                addElement(taEditor);
            }

            createPreview();
        }


        override protected function commitProperties ():void
        {
            super.commitProperties();

            if(_selectedFileChanged && selectedFile && selectedFile.file)
            {
                var p:File = selectedFile.file.parent;
                var paths:Array = [];
                while(p != null)
                {
                    paths.unshift(p.nativePath);
                    p = p.parent;
                }

                fsTreeXML.openPaths = paths;
                _selectedFileChanged = false;
            }
        }

        override protected function createPreview ():void
        {
            if (starling && _preview == null)
            {
                _preview = new Canvas();
                _preview.x = 300;
                _preview.y = 30;
                starling.stage.addChild(_preview);
            }
        }



        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------

        private var _preview:Canvas;
        private var lblPreview:Label;
        private var lblXMLDirecotry:Label;
        private var fsTreeXML:FileSystemTree;
        private var taEditor:TextArea;



        //-------------------------------------------------------------------
        // Event handlers
        //-------------------------------------------------------------------

        private function fsTreeXML_changeHandler(event:ListEvent):void
        {
            if (_preview)
                _preview.clearAllElements();

            var path:String = fsTreeXML.selectedPath;
            if(!path)
                return;

            var newFile:GUIVO = new GUIVO(new File(path));
            if(newFile.isGUIFile)
            {
                selectedFile = newFile;

                StoredFieldManager.instance.setString(Constants.SO_XML_PATH, fsTreeXML.selectedPath);

                taEditor.text = selectedFile.buffer.toXMLString();

                if(_preview && selectedFile)
                    _preview.createAllElements(selectedFile.buffer);
            }
            else
            {
                taEditor.text = newFile.log;
            }

        }

        private function editor_changeHandler(event:TextOperationEvent):void
        {
            try
            {
                var xml:XML = new XML(taEditor.text);
                taEditor.errorString = "";
            }
            catch(error:Error)
            {
                taEditor.errorString = error.message;
                return;
            }

            selectedFile.update(xml);

            if(_preview && selectedFile)
            {
                _preview.clearAllElements();
                _preview.createAllElements(selectedFile.buffer);
            }
        }
    }
}
