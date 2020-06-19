main() {

  // 小刻度间隙为8个像素
  var scratchSpace = 8;
  // 大刻度间隙为5个刻度
  var bigScratchSpace = 5;

  // 计算第一个大刻度的位置， dx为手势滑动偏移量
  // 向左滑动，dx减小，为负数，向右滑动，dx增大，为正数
  // 向上滑动，dx减小，为负数，向下滑动，dx增大，为正数
  // 由于坐标系向右为增大，向上为增大，故，左右滑动dx变化与坐标系方向相反，需要取相反数
  int position(double dx){
    print("总偏移量为 $dx");
    //小刻度偏移量
    int small = dx % (scratchSpace * bigScratchSpace) ~/ scratchSpace;
    print("小刻度偏移量为 $small");
    double pixel =  dx % (scratchSpace * bigScratchSpace) % scratchSpace;
    print("像素偏移量为 $pixel");
    if (pixel == 0) {
      return (bigScratchSpace - small) % bigScratchSpace;
    }
    return bigScratchSpace - small - 1;
  }

  print(position(0));
}

