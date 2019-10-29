# CellCounter
九州大学 熱物質移動研究室 OPEN-SOURCE BIOWARE PROJECT 細胞カウントアプリ

## 概要
九州大学 熱物質移動研究室 OPEN-SOURCE BIOWARE PROJECT https://bioware.sakura.ne.jp/index.html の一環として作成された細胞カウント用のiOSアプリです。プレパラート上に配置した細胞の懸濁液を撮影すると撮影範囲に含まれる細胞を自動的に計数します。

## 使い方
### メイン画面
アプリを起動し、懸濁液を撮影すると自動的に細胞の外周がマーキングされ、個数が画面右上に表示されます。
<kbd>
![基本画面 - iPhone 11 Pro Max - 2019-10-28 at 14 36 43](https://user-images.githubusercontent.com/52752/67741565-eb1d1e00-fa5c-11e9-99aa-f8ea5e98a995.png)
</kbd>

画面の中の明るさに基づいて細胞を判別します。画面下のスライダーを操作して判別の基準を調整します。
- th Light: 明るさのしきい値を設定します。この値より明るい領域を細胞として判別します。(初期状態では自動的に設定されます)
- th Area: 面積のしきい値(最大・最小)を設定します。明るさのしきい値で細胞と判別された領域のうち、この値の範囲に収まるものを細胞として判別します。
- Auto: タップするとth Lightの値を自動で設定します。(自動で設定するときには"ON"と表示されます。th Lightのスライダーを動かすと"OFF"になります)
- config: 設定画面を開き、色の設定を行います。細胞の外周の色と、個数をカウントした数字の色を変更できます。

細胞カウント数とスライダー部分は画面をタップすると非表示になります。<br>画面の上の方をタップすると細胞カウント数が、下の方をタップするとスライダー部分が非表示になります。再度タップすると再び表示されます<br>
<kbd>
![数字なし - iPhone 11 Pro Max - 2019-10-28 at 15 36 26](https://user-images.githubusercontent.com/52752/67741566-ebb5b480-fa5c-11e9-8718-35e52f87154c.png)
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
