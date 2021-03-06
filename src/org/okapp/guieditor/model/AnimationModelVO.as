package org.okapp.guieditor.model
{
    import flash.filesystem.File;

    public class AnimationModelVO extends DataFile
    {
        public static const FILE_NAME_PATTERN:String = "animation_#.xml";
        public static const EMPTY_FILE:XML =
            <model xmlns={Constants.OKAPP_ANIMATION_MODEL_NAMESPACE}>
                <state name={Constants.DEFAULT_ANIMATION_STATE} />
            </model>;

        public function AnimationModelVO (file:File)
        {
            super(file, Constants.OKAPP_ANIMATION_MODEL_FILE_EXTENSION, Constants.OKAPP_ANIMATION_MODEL_NAMESPACE);
        }
    }
}
