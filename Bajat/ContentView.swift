import SwiftUI


struct ContentView: View {
    var body: some View {
        Text("\(readFfiString(greet)!) \(shipping_rust_addition(30, 1))")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
