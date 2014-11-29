BManager
========
二进制加载类 org.rcSpark.binaryManager

实现以下功能

[1].使用优先级进行加载

[2].加载完缓存到本地

[3].有效的版本控制

[4].监听加载超时

[5].实现加载队列与加载线程

加载处理类 org.rcSpark.resManager

目前功能不完善  依靠org.rcSpark.binaryManager实现

[1].实现文件解密

[2].文件加载重定向（与文件解密相关）

[3].已经实例化的图片或其他资源存取（不完善）

数据绑定处理 org.rcSpark.binding

简单的数据banding,依靠Signal 实现

[1].数据需要继承BindingData，

[2].在setter方法里面需要调用 父类的 update("xx",value);


