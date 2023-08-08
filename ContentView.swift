import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            LottieView(name: "Eyes_v1", loopMode: .loop)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
