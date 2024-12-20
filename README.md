# resonite-headless-arm64

Resonite Headlessが持っているネイティブライブラリ依存をどうにかしてarm64で動くようにする参考実装。  
[自分用のカスタムヘッドレス](https://github.com/hantabaru1014/baru-reso-headless-container) で採っている仕組みをarm64対応(x64/arm64のマルチアーキ対応)部分だけ切り出したものです。なので、このリポジトリは積極的にメンテしたりはしない予定です。

## 動かしてみる
必要環境: dockerが動くx64/arm64のlinux OS

ビルドしたDocker imageはResoniteを含んでいるので再配布できないです。なので、各自でビルドしてください。  
イメージを用意できたら `docker compose up` で立ち上がります。

Github Actionでビルドしてghcr.ioにprivate設定で置いておく場合:
1. このリポジトリをFork
2. `<リポジトリのURL>/settings/secrets/actions` のページでSecretsに次の変数を設定: `STEAM_USERNAME`, `STEAM_PASSWORD`, `HEADLESS_PASSWORD`
3. ActionsからBuild and Push Docker Imageを Run workflow !
4. Packagesにコンテナイメージが生えているはずなので、後は実行環境でpullする

## 主なポイントの説明
- EnginePrePatcher : dllを静的にパッチするCUIプログラム。RML(が依存しているMonoMod)はarm64に対応していなかった... (今はWIPながらコードがあるので頑張ればたぶん動く ref: https://github.com/MonoMod/MonoMod/issues/174)
  - RemoveUnusedConnectors.cs : SteamとDiscordのインテグレーションにはネイティブライブラリが使われているが、ヘッドレスではそもそも要らないやつらなのでなかったことにする
- Dockerfile / copy-native-libs.sh : ヘッドレスの実行に必要なネイティブライブラリのarm64版を自前でビルドするのは面倒なのでaptから調達してコピーする
- .github/workflows/build-and-push-image.yml : Docker imageのビルドをGithub Actionsにやらせる。アプデを検知して自動でワークフローをトリガーすれば便利。

## このリポジトリで対応できていない
- brotliのロード
  - brotliは圧縮ライブラリです。なくてもResoniteは動くのでmustではないです。
  - [自分用のカスタムヘッドレス](https://github.com/hantabaru1014/baru-reso-headless-container) では正常にロードできています。ヘッドレスのエントリポイントを自作/Moddingせずに対応するのが面倒なだけです。
  - 原因と修正方針
    - Brotli.Core.dllのLinuxLoaderが `[DllImport("__Internal")]` しているせい
    - [こんな感じ](https://github.com/hantabaru1014/baru-reso-headless-container/blob/7b6ad08ebf67729edde6a2d0590723f8b1c8b067/Headless/ResoniteAssemblyResolver.cs#L59) でインポート元を探すのを手伝ってあげれば良いです
