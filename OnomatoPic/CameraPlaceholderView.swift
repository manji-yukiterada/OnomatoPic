import SwiftUI

struct CameraPlaceholderView : View {
    var body : some View {
        ContentUnavailableView("カメラ機能はカード閲覧の後に追加します。",systemImage: "camera", description: Text("まずはサンプルカードの表裏を確認してみましょう。"))
    }
}
