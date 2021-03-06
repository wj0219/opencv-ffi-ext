
#ifndef __OPENCV_FFI_COLOR_INVARIANCE__
#define __OPENCV_FFI_COLOR_INVARIANCE__

enum {
  COLOR_INVARIANCE_PASSTHROUGH = 0,
  COLOR_INVARIANCE_RGB2GAUSSIAN_OPPONENT = 1,
  COLOR_INVARIANCE_BGR2GAUSSIAN_OPPONENT = 2,
  COLOR_INVARIANCE_Gray2YB = 100,
  COLOR_INVARIANCE_Gray2RG = 101,
  COLOR_INVARIANCE_BGR2HInvariant = 110
};

#endif
