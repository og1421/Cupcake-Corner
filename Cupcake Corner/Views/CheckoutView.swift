//
//  CheckoutView.swift
//  Cupcake Corner
//
//  Created by Orlando Moraes Martins on 20/12/22.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var order: Order
    
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    @State private var titleAlert = "Thank You"
    var body: some View {
        ScrollView{
            VStack{
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                        .resizable ( )
                        .scaledToFit()
                        .accessibilityLabel("Cupcake Image")
                        .accessibilityHidden(false)
                        .accessibilityAddTraits(.isImage)
                } placeholder: {
                    ProgressView()
                        .accessibilityHidden(true)
                }
                .frame(height: 233)
                
                Text("Your total cost is \(order.cost, format: .currency(code: "USD"))")
                    .font(.title)
                
                Button("Place order", action: {
                    Task{
                        await placeOrder()
                    }
                })
                    .padding()
            }
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
        .alert(titleAlert, isPresented: $showingConfirmation){
            Button("Ok") { }
        } message: {
            Text(confirmationMessage)
        }
    }
    
    func placeOrder() async {
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }

        if let url = URL(string: "https://reqres.in/api/cupcakes")! as? URL {
        
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            do {
                let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
                
                let decodeOrder = try JSONDecoder().decode(Order.self, from: data)
                confirmationMessage = "Your order for \(decodeOrder.quantity)x \(Order.types[decodeOrder.type].lowercased()) cupcakes is on its way"
                
                showingConfirmation = true
            } catch {
                titleAlert = "Alert"
                confirmationMessage = "Checkout failed."
                showingConfirmation = true
            }
        } else {
            print("Invalid URL")
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}
