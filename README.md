# class-dump-folder[[中文](https://github.com/lengain/class-dump-folder/blob/main/README-Chinese.md)]

Show or dump Mach-O file at current folder

```
Usage: class-dump-folder [options]
where options are:
        -l        Show all Mach-O file at current path
        -le        Show unix exe Mach-O file(MH_EXECUTE,MH_DYLIB) at current path
        -ld        Dump unix exe Mach-O file(MH_EXECUTE,MH_DYLIB) at current path
```

##### Error Handle:

```typescript
Error: Cannot find offset for address 0xc80000000105e53a in stringAtAddress:
```

or

```
sh: -c: option requires an argument**
```

Try to copy [class-dump](https://github.com/AloneMonkey/MonkeyDev/blob/master/bin/class-dump) to this path   `/usr/local/bin/`  for fix up.
