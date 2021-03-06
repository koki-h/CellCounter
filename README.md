# CellCounter
九州大学 熱物質移動研究室 OPEN-SOURCE BIOWARE PROJECT 細胞カウントアプリ

[![Download_on_the_App_Store_Badge_US-UK_blk_092917](https://user-images.githubusercontent.com/52752/72348081-e93e2f00-371c-11ea-84d8-d34b3a9d8d24.png)
](https://apps.apple.com/jp/app/id1482879978)

## 概要
九州大学 熱物質移動研究室 OPEN-SOURCE BIOWARE PROJECT https://bioware.sakura.ne.jp/index.html の一環として作成された細胞カウント用のiOSアプリです。プレパラート上に配置した細胞の懸濁液を撮影すると撮影範囲に含まれる細胞を自動的に計数します。

## 使い方
### メイン画面
アプリを起動し、懸濁液を撮影すると自動的に細胞の外周がマーキングされ、個数が画面右上に表示されます。<br>
<kbd>
![基本画面 - iPhone 11 Pro Max - 2020-01-14 at 21 52 41](https://user-images.githubusercontent.com/52752/72347039-92375a80-371a-11ea-94bb-2c9da9255bf2.png)

</kbd>

画面の中の明るさに基づいて細胞を判別します。画面下のスライダーを操作して判別の基準を調整します。
- Area: 面積のしきい値(最大・最小)を設定します。明るさのしきい値で細胞と判別された領域のうち、この値の範囲に収まるものを細胞として判別します。
- Intensity: 明るさのしきい値を設定します。この値より明るい領域を細胞として判別します。(初期状態では自動的に設定されます)
- Auto: タップするとth Lightの値を自動で設定します。(自動で設定するときには"ON"と表示されます。th Lightのスライダーを動かすと"OFF"になります)
- Config: 設定画面を開き、色の設定を行います。細胞の外周の色と、個数をカウントした数字の色を変更できます。

細胞カウント数とスライダー部分は画面をタップすると非表示になります。<br>画面の上の方をタップすると細胞カウント数が、下の方をタップするとスライダー部分が非表示になります。再度タップすると再び表示されます<br>
<kbd>
![数字なし - iPhone 11 Pro Max - 2020-01-14 at 21 55 43](https://user-images.githubusercontent.com/52752/72347048-95cae180-371a-11ea-86d1-e307dca0cdd9.png)
</kbd>
<kbd>
![スライダーなし - iPhone 11 Pro Max - 2019-10-28 at 15 36 22](https://user-images.githubusercontent.com/52752/67741564-eb1d1e00-fa5c-11e9-932a-1996d96a0c68.png)
</kbd>
<kbd>
![数字＆スライダーなし - iPhone 11 Pro Max - 2019-10-28 at 15 36 24](https://user-images.githubusercontent.com/52752/67741567-ebb5b480-fa5c-11e9-8ad5-a37813b5f1e8.png)
</kbd>

### 色設定画面
configをタップすると細胞の外周の色(Color for edges)と個数をカウントした数字の色(Color for count)を設定する画面が開きます。
色のついた四角形の部分をタップしてカラーピッカーを開き、それぞれの色を設定します。
Doneをタップすると元の画面に戻ります。<br>
<kbd>
![設定画面 - iPhone 11 Pro Max - 2019-10-28 at 15 36 30](https://user-images.githubusercontent.com/52752/67741562-eb1d1e00-fa5c-11e9-8628-9563506c9e46.png)
</kbd>

### カラーピッカー画面
カラーピッカーでは任意の色をタップして設定色を選択します。色相、明るさ、透明度を設定できます。プリセットされた色の選択や、RGBでの色設定も可能です。<br>
<kbd>
![カラーピッカー - iPhone 11 Pro Max - 2019-10-28 at 15 36 34](https://user-images.githubusercontent.com/52752/67741561-eb1d1e00-fa5c-11e9-9f33-1458db24ada2.png)
</kbd>

## ビルド・実行方法
ソースコードからビルドし、実行する方法について、知識のない人がとりあえずソースから動かすために必要な情報、またはCellCounterに特有と思われる情報を以下に示します。
その他の情報（AppStoreへのアップロード方法等）は省略します。各自、一般的な方法で行ってください。
- Xcodeが必要です。まずこちらをインストールしてください。
- iOS用のOpenCVライブラリ（opencv2.framework）をCellCounterディレクトリの中に置いてください。
  - iOS用のOpenCVライブラリは https://opencv.org/releases/ から入手できます。「iOS Pack」と書かれたリンクからダウンロードしてください。ダウンロードされたアーカイブの中に `opencv2.framework` というディレクトリがあるので、それをCellCounterディレクトリの中に移動させてください。
  - CellCounterの最初のバージョン（2020年11月現在App Storeで公開されているバージョン）はOpenCV-4.1.1を使用しています。
  - 2020年11月現在最新であるOpenCV-4.5.0を使用しても動作することを確認しています。
- CellCounter.xcodeprojをXcodeで開き、メニューから `Product`→`Run` を実行するとデバッグ用のビルドが作成されたあと、iOSシミュレータが立ち上がりCellCounterが実行されます。シミュレータではカメラ画像の代わりにあらかじめ細胞懸濁液を撮影した画像が表示され、この画像に対して検出処理が実行されます。
- 実機で実行する場合はプロジェクトプロパティ画面で`TARGETS`→`CellCounter`を選択し、`Sigining & Capability` タブに表示される`Team`や`Bundle Identifier`を適宜変更してください。
