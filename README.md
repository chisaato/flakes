# flakes

个人自用 Nix Flakes 整合。

## 按机器调整安装类型

只需要

```bash
cp machine.example.nix machine.local.nix
```

然后根据需要修改 `machine.local.nix` 文件。就可以按喜好来安装所需要的组。

不存在该 local 则视为全家桶安装。
