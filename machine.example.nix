# 每台机器的本地配置模板
#
# 用法:
#   cp machine.example.nix machine.local.nix
# 然后按本机需求编辑 machine.local.nix。
# machine.local.nix 已被 .gitignore 忽略,不会提交到 git。
#
# 规则:
# - 写了 false 的模块整体跳过安装
# - 未写到的模块默认启用
# - machine.local.nix 不存在时安装全家桶(所有模块启用)
#
# 注意:求值时读取的是真实的 ~/.config/home-manager/machine.local.nix,
#       因此仍然需要 --impure 参数(与 username/homeDirectory 的逻辑一致)。
{
  modules = {
    nix-tools = true; # Nix 开发工具
    misc = true; # 杂项 CLI 工具
    kubernetes = true; # Kubernetes 工具链
    golang = true; # Go 工具链
    nodejs = true; # Node.js 工具链
    cloud-native = true; # 云原生工具链
    container = true; # 容器工具链
    desktop = true; # 桌面 GUI 应用
  };
}
