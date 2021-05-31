# class-dump-folder [[English](https://github.com/lengain/class-dump-folder/blob/main/README.md)]

在当前文件夹下显示Mach-O文件或导出 改文件夹下所有（MH_EXECUTE,MH_DYLIB类型）Mach-O 文件的头文件

```
Usage: class-dump-folder [options]
where options are:
        -l        显示当前文件夹下所有Mach-O文件
        -le        显示当前文件夹下所有MH_EXECUTE,MH_DYLIB类型的Mach-O文件
        -ld        导出该文件夹下所有MH_EXECUTE,MH_DYLIB类型的Mach-O文件的头文件
```

##### 错误处理:

当遇到

```typescript
Error: Cannot find offset for address 0xc80000000105e53a in stringAtAddress:
```

或者

```
sh: -c: option requires an argument**
```

请尝试复制 [class-dump](https://github.com/AloneMonkey/MonkeyDev/blob/master/bin/class-dump) 到mac 下这个路径 `/usr/local/bin/`  


