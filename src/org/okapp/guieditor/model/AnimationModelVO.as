package org.okapp.guieditor.model
{
    import flash.filesystem.File;

    public class AnimationModelVO extends DataFile
    {
        public function AnimationModelVO (file:File, create:Boolean = false)
        {
            super(file, Constants.OKAPP_ANIMATION_MODEL_FILE_EXTENSION, Constants.OKAPP_ANIMATION_MODEL_NAMESPACE);
        }
    }
}
