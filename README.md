# Strata + SideStore 简体中文汉化版

基于 [Strata 2.0.0](https://github.com/huzaifahshahid71-ops/Strata/releases/tag/v2.0.0)（LiveContainer 3.8.11 内核）制作的简体中文化源码与构建工程，内含 SideStore 0.7.0 简体中文界面资源。

## 简介

- **Strata 主界面**：首页控制卡片、壁纸、JIT 设置、应用列表排序、设置说明等改为简体中文。
- **内置 SideStore**：底栏、设置、源、应用、证书与账户操作完成简体中文界面；图片资源名称保持原样，避免图标缺失。
- **LiveContainer 3.8.11**：语言与本地化覆盖表同步写入 `zh-Hans.lproj`。
- 保留 JIT 相关技术名称（StikDebug、SideStore、LiveContainer、LocalDevVPN 等）及文件名（如 `TweakLoader.dylib`）。

## 仓库内容

| 路径 | 说明 |
|---|---|
| `LiveContainerSwiftUI/` | 主界面源码，含首页与 JIT 中文补丁 |
| `Resources/Localizable.xcstrings` | 简体中文词条（含截图补齐的 21 项） |
| `SideStore-zh-Hans/` | 对应 SideStore `ee3cc16a` 的中文界面源码参考 |
| `SideStore-zh-Hans/Chinese/` | SideStore 中文覆盖表与资源说明 |
| `.github/workflows/build.yml` | macOS + Xcode 26.2 未签名归档构建 |

## 构建流程

1. GitHub Actions → **Build** → Run workflow（或推送代码触发）。
2. 使用 `macos-15` 与 Xcode **26.2 (17C52)**，执行：

   ```sh
   python3 Scripts/fetch-bundled-dependencies.py
   xcodebuild archive \
     -project LiveContainer.xcodeproj \
     -scheme LiveContainer \
     -configuration Release \
     -sdk iphoneos \
     -destination 'generic/platform=iOS' \
     -archivePath "$RUNNER_TEMP/Strata-zh-Hans.xcarchive" \
     CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
   ```

3. 在 Actions 页面下载 `Strata-v2.0.0-zh-Hans-unsigned-xcarchive` 构建产物。
4. 产出的归档**未签名**，需使用 SideStore、AltStore 或其他方式重新签名后安装。

## 安装

- 本仓库提供源码与构建流程，不提供已签名 IPA。
- 安装前建议备份 LiveContainer 数据；覆盖安装时请使用同一签名证书。

## 说明与限制

- 中文由源码补丁与本地化词条实现，**并非官方发行版**。
- 应用名称、版本号、Bundle ID、源中应用的远程简介属于外部数据，保持原文。
- 部分新增 SwiftUI 文案可能仍为英文，欢迎提 Issue 补充。
- 本项目遵循原项目许可证（见 `LICENSE`）。

## 相关项目

- [Strata - LiveContainer 发行版](https://github.com/huzaifahshahid71-ops/Strata)
- [LiveContainer](https://github.com/LiveContainer/LiveContainer)
- [SideStore](https://github.com/SideStore/SideStore)
