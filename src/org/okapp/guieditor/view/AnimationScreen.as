package org.okapp.guieditor.view
{
    import mx.controls.FileSystemEnumerationMode;
    import mx.controls.FileSystemTree;
    import mx.events.ListEvent;

    import org.kolonitsky.alexey.StoredFieldManager;

    import spark.components.Group;
    import spark.components.Label;
    import spark.components.List;

    import starling.core.Starling;

    public class AnimationScreen extends BaseScreen
    {
        public static const COL1_LEFT:Number = 0;
        public static const COL1_WIDTH:Number = 300;
        public static const COL2_LEFT:Number = COL1_LEFT + COL1_WIDTH + COL_GAP;
        public static const COL2_WIDTH:Number = 300;
        public static const COL3_LEFT:Number = COL2_LEFT + COL2_WIDTH + COL_GAP;
        public static const COL3_WIDTH:Number = 300;

        public static const COL_GAP:Number = 4;


        public function AnimationScreen()
        {
            super();
        }


        override protected function createChildren():void
        {
            super.createChildren();

            // Col1
            if (lblXMLDirecotry == null)
            {
                lblXMLDirecotry = new Label();
                lblXMLDirecotry.text = "Animation render directory";
                lblXMLDirecotry.left = 0;
                lblXMLDirecotry.top = 0;
                lblXMLDirecotry.width = COL1_WIDTH;
                lblXMLDirecotry.bottom = 0;
                lblXMLDirecotry.setStyle("backgroundColor", 0xFFFFFF);
                addElement(lblXMLDirecotry);
            }

            if (fsTexturesDirectory == null)
            {
                fsTexturesDirectory = new FileSystemTree();
                fsTexturesDirectory.left = 0;
                fsTexturesDirectory.top = 30;
                fsTexturesDirectory.width = COL1_WIDTH;
                fsTexturesDirectory.bottom = 0;
                fsTexturesDirectory.enumerationMode = FileSystemEnumerationMode.DIRECTORIES_ONLY;
                fsTexturesDirectory.addEventListener(ListEvent.CHANGE, fsTexturesDirecotry_changeHandler);
                fsTexturesDirectory.selectedPath = StoredFieldManager.instance.getString(Constants.SO_XML_PATH);
                addElement(fsTexturesDirectory);
            }

            // Col2
            if(lblPreview == null)
            {
                lblPreview = new Label();
                lblPreview.top = 0;
                lblPreview.left = COL2_LEFT;
                lblPreview.width = COL2_WIDTH;
                lblPreview.text = "Textures";
                addElement(lblPreview);
            }

            if (listTextures == null)
            {
                listTextures = new List();
                listTextures.top = 0;
                listTextures.left = COL1_WIDTH + COL_GAP;
                listTextures.width = COL2_WIDTH;
                addElement(listTextures);
            }
        }

        //-------------------------------------------------------------------
        //
        //  Private
        //
        //-------------------------------------------------------------------

        private var lblPreview:Label;
        private var lblXMLDirecotry:Label;
        private var fsTexturesDirectory:FileSystemTree;
        private var listTextures:List;

        private function fsTexturesDirecotry_changeHandler(event:ListEvent):void
        {
            trace("Textrues");
        }
    }
}
