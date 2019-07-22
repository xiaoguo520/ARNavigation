#  AR导航(停车场版本)
- 以编辑器(@国洪)导出的数据为基础（仅需提供地图图片、比例尺、正北方向与地图+y轴夹角）
- 以松日鼎盛B3层停车场为测试场地
- 导航路径的指示图标为箭头(贴地平铺)
- 终点展示为旋转的终点图标(竖直展示)
- 除地图文件首次加载需连接网络外，所有数据暂时均硬编码在项目中(可离线使用)
- 起始位置和目标位置均通过手动选择确定
- 20190110完成功能实现

#  AR导航(停车场版本) 纠偏
- 纠偏措施1： ```ARWorldTrackingConfiguration.worldAlignment``` 设置为 ```ARWorldAlignmentGravity```。
  - 原因：```ARWorldAlignmentGravityAndHeading``` 模式下ARKit会根据设备偏航角的朝向与地磁真北方向的夹角不断调整，以确保ARKit坐标系中负Z轴的方向与我们真实世界的正北方向吻合。而手机设备的指南针读数可能波动很大，容易导致漂移现象的出现。
  - 效果：可以减少漂移、方向错误的现象。
  - 存在的问题：路径图标的角度计算方法需要重新设计。
- 纠偏措施2：假定导航路径的前面10米用户是按照真实世界中的正确路径行走的，在10米处进行纠偏。
  - 具体做法：开始导航后对行走距离进行记录，到达10米时进行纠偏。获取10米处的ARKit坐标P1，再寻找规划路径中10米处的点(不一定非常精确)并将其转化为ARKit坐标P2，将规划路径中的起点转换为ARKit坐标P0，计算(P0,P1)向量到(P0,P2)向量的顺时针夹角a(即偏移的角度)，再将a更新到转换矩阵中(Tango数据到ARKit坐标的转换矩阵)并刷新路径坐标即可。
  - 效果：可以有效纠偏，但前提是用户需要按照正确路径行走。

- 其他可继续尝试的纠偏措施
  - 用户手动拖拽路径图标进行纠偏
    - 效果：未知。
    - 具体做法：拖拽ARKit中的图标以实现所展示路径的角度纠偏、位移纠偏。
  - 拐点处纠偏
    - 效果：未知。
    - 纠偏步骤：用户到达拐点附近时(根据其距离上一个拐点的距离估算)，由用户确认是否已经到达拐点，到达拐点后还需要将手机指向指定方向(下一段路径的方向)，再点击确认。    
  - 拐点+实时纠偏
    - 效果：未知。
    - 纠偏步骤：基于拐点处纠偏，直线行走时计算距离上一拐点的距离确定当前位置，再对角度、位移偏差进行纠正。
    - 计算步骤：计算实时位置在ARKit坐标系中的坐标及方向，计算原数据(根据采集数据计算的ARKit展示路径数据)中相应点与实时位置的角度差，对原数据进行角度纠正并更新到ARKit中
    - 注意事项：
      - 需要记录上一个拐点的信息
      - 根据最原始的数据进行计算
      - 一次纠偏的角度区间为[-30, 30]
      - 纠偏的频率为2s一次

# AR导航(停车场版本)优化
- 剩余距离(距离下一个拐点的距离、距离终点的距离)计算
  - 之前：是每0.1s计算一次当前位置与下一个贴图位置(currentIndex+1)的距离是否小于0.5m，以刷新贴图位置(currentIndex)。
    - 距离是指当前位置到(currentIndex,currentIndex+1)线段的投影点p到下一个贴图位置(currentIndex+1)的距离。 
    - 问题是拐弯处存在计算错误的可能性，从而currentIndex错误，导致剩余距离不刷新。
  - 现在：在之前的基础上，先找到currentIndex的正确值(通过遍历找到距离当前位置最近的贴图)，再进行相应计算。
    - 同时现在的刷新时间变为0.5s，距离半径变为1m

# AR导航(停车场版本)SDK&App
- 与之前版本的不同：
  - SDK通过后台接口联网获取数据（之前是硬编码）
  - SDK增加对反向寻车功能的支持
  - Demo App功能的升级
- 删除无用的文件与资源
- 新版本UI
- 对接后台接口（登录、项目列表、项目详情、反向寻车）
- 已适配数据：松日鼎盛B3层停车场，达实智能大厦B2层停车场

- 20190402 创建分支 iOS-ARNavigation/app
- 20190425 初步实现基本功能（达实智能大厦B2层实地测试）
- 20190510 实现SDK功能部分完善（整理代码，输出SDK、文档、Demo(在另一项目iOS-InWalkARDemo中)，给大众点评）

- 20190522 this is a version for gz
- 添加阴影(各输入界面)
- 添加小地图缩小时的顶部隔离层
- 偏移路径方向时的提示标识(左/右)，带动画
- 添加切换楼层的功能

- 集成广州G、P两层的数据
20190605.1500 - 可以播放视频
20190605.1600 - 稀疏点位、立标GIF
20190605.1820 - 平面图标、5米纠偏
20190606.1705 - 集成 卓越城B2层停车场的数据




# AR导航(停车场版本)SDK&App(IBeacon设备纠偏版本)
20190722  gd
- 1新增ibeacon设备，集成ibeacon广播，接受相关代码。
- 2.新增位移过程中角度纠偏,位移纠偏暂未完成
- 3.已完成益友车城停车场测试


# ARNavigation
