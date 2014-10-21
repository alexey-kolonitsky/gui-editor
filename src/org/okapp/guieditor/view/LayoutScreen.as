package org.okapp.guieditor.view
{
    import com.okapp.pirates.ui.controls.Canvas;

    import feathers.system.DeviceCapabilities;

    import flash.events.MouseEvent;

    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    import mx.collections.ArrayCollection;
    import mx.controls.FileSystemTree;
    import mx.events.FlexEvent;
    import mx.events.ListEvent;

    import org.kolonitsky.alexey.StoredFieldManager;
    import org.okapp.guieditor.model.DataFile;

    import org.okapp.guieditor.model.GUIVO;

    import spark.components.Button;

    import spark.components.Group;
    import spark.components.Label;
    import spark.components.TextArea;
    import spark.components.TextInput;
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


        override protected function createChildren():void
        {
            super.createChildren();

            if (lblXMLDirecotry == null)
            {
                lblXMLDirecotry = new Label();
                lblXMLDirecotry.text = "Layout-file Location";
                lblXMLDirecotry.left = 0;
                lblXMLDirecotry.top = 0;
                lblXMLDirecotry.width = COL1_WIDTH;
                lblXMLDirecotry.bottom = 0;
                lblXMLDirecotry.setStyle("backgroundColor", 0xFFFFFF);
                lblXMLDirecotry.setStyle("paddingTop", 5);
                addElement(lblXMLDirecotry);
            }

            if (btnCreate == null)
            {
                btnCreate = new Button();
                btnCreate.top = 0;
                btnCreate.left = 120;
                btnCreate.label = "Create";
                btnCreate.addEventListener(MouseEvent.CLICK, btnCreate_clickHandler);
                addElement(btnCreate);
            }

            if (tiName == null)
            {
                tiName = new TextInput();
                tiName.top = 3;
                tiName.left = COL1_WIDTH + COL_GAP + 160;
                tiName.addEventListener(TextOperationEvent.CHANGE, tiName_changeHandler);
                addElement(tiName);
            }

            if (taEditor == null)
            {
                taEditor = new TextArea();
                taEditor.top = 600;
                taEditor.left = COL1_WIDTH + COL_GAP;
                taEditor.right = 0;
                taEditor.bottom = 0;
                taEditor.setStyle("fontFamily", "_typewriter");
                taEditor.setStyle("fontSize", 12);
                taEditor.addEventListener(TextOperationEvent.CHANGE, editor_changeHandler);
                addElement(taEditor);
            }

            if (fsTreeXML == null)
            {
                fsTreeXML = new FileSystemTree();
                fsTreeXML.left = 0;
                fsTreeXML.top = 30;
                fsTreeXML.width = COL1_WIDTH;
                fsTreeXML.bottom = 0;
                fsTreeXML.addEventListener(ListEvent.CHANGE, fsTreeXML_changeHandler);
                fsTreeXML.selectedPath = StoredFieldManager.instance.getString(Constants.SO_LAYOUT_PATH);
                addElement(fsTreeXML);

                fsTreeXML_changeHandler(null);
            }

            if (lblPreview == null)
            {
                lblPreview = new Label();
                lblPreview.y = 0;
                lblPreview.left = COL1_WIDTH + COL_GAP;
                lblPreview.right = 0;
                lblPreview.text = "Preview";
                lblPreview.setStyle("paddingTop", 5);
                addElement(lblPreview);
            }

            createPreview();
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_selectedFileChanged && selectedFile && selectedFile.file)
            {
                fsTreeXML.openPaths = selectedFile.path;
                _selectedFileChanged = false;
            }
        }

        override protected function createPreview():void
        {
            if (_preview == null)
            {
                _preview = new Canvas();
                _preview.x = COL1_WIDTH + COL_GAP;
                _preview.y = 30;
            }

            if (starling)
            {
                starling.stage.addChild(_preview);
            }
        }

        override protected function removePreview():void
        {
            if (starling && _preview)
            {
                starling.stage.removeChild(_preview);
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
        private var btnCreate:Button;
        private var fsTreeXML:FileSystemTree;
        private var taEditor:TextArea;
        private var tiName:TextInput;


        //-------------------------------------------------------------------
        // Event handlers
        //-------------------------------------------------------------------

        private function fsTreeXML_changeHandler(event:ListEvent):void
        {
            if (_preview)
                _preview.clearAllElements();

            var path:String = fsTreeXML.selectedPath;
            if (! path)
                return;

            var newFile:GUIVO = new GUIVO(new File(path));
            if (newFile.isValid)
            {
                selectedFile = newFile;

                StoredFieldManager.instance.setString(Constants.SO_LAYOUT_PATH, fsTreeXML.selectedPath);

                tiName.text = newFile.file.name;
                taEditor.text = selectedFile.buffer.toXMLString();

                if (_preview && selectedFile)
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
            catch (error:Error)
            {
                taEditor.errorString = error.message;
                return;
            }

            selectedFile.update(xml);

            if (_preview && selectedFile)
            {
                _preview.clearAllElements();
                _preview.createAllElements(selectedFile.buffer);
            }
        }

        private function tiName_changeHandler(event:TextOperationEvent):void
        {
            //TODO: Add rename ability
        }

        private function btnCreate_clickHandler(event:MouseEvent):void
        {
            var file:File = new File(fsTreeXML.selectedPath);
            var parentPath:String;

            if (file.isDirectory)
                parentPath = file.nativePath;
            else
                parentPath = file.parent.nativePath;

            var i:int = 1;
            var newFile:File = new File(parentPath + "\\window_" + i + ".xml");
            while (newFile.exists)
                newFile = new File(parentPath + "\\window_" + (++ i) + ".xml");

            var stream:FileStream = new FileStream();
            stream.open(newFile, FileMode.WRITE);
            var barr:ByteArray = new ByteArray();
            barr.writeUTF('<gui xmlns="http://wwww.okapp.ru/gui/0.1" xmlns:of="com.okapp.pirates.ui.controls">\n<of:Text text="Hello world!" /></gui>');
            stream.writeBytes(barr, 2, barr.length - 2);
            stream.close();

            fsTreeXML.refresh();
            fsTreeXML.selectedPath = newFile.nativePath;
            fsTreeXML_changeHandler(null);
        }
    }
}
