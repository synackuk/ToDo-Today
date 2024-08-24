import SwiftUI
import FlexColorPicker

/* Colour picker works differently on mac */
#if targetEnvironment(macCatalyst)


extension View {
    public func colourPickerSheet(isPresented: Binding<Bool>, selection: Binding<Color>, supportsAlpha: Bool = true, title: String? = nil) -> some View {
        
        /* Passthrough to create a sheet */
        self.sheet(isPresented: isPresented) {
            ColourPickerSheet(selection: selection)
        }
    }
}

struct ColourPickerSheet: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @Binding var selection: Color
    
    var body: some View {
        VStack {
            
            /* Exit button */
            ExitButtonView(dismiss: dismiss.callAsFunction)
            
            /* Colour Picker */
            ColourPickerView(selection: $selection)
        }
    }
    
}

struct ColourPickerView: UIViewControllerRepresentable {
    @Binding var selection: Color
    
    func makeCoordinator() -> Coordinator {
        
        /* Create the coordinator, passing through the Colour */
        Coordinator(selection: $selection)
    }
    
    class Coordinator: NSObject, ColorPickerDelegate {
        @Binding var selection: Color
        
        init(selection: Binding<Color>) {
            
            /* Initialise the selection */
            self._selection = selection
        }
        
        /* When a new colour is selected */
        func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
            
            /* Set that colour and pass it through */
            selection = Color(selectedColor)
        }


    }
    
    func makeUIViewController(context: Context) -> DefaultColorPickerViewController {
        
        /* Setup the VC */
        let vc = DefaultColorPickerViewController()
        vc.selectedColor = UIColor(selection)
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ controller: DefaultColorPickerViewController, context: Context) {
        /* No need for updates! */
    }
}

#else

extension View {
    public func colourPickerSheet(isPresented: Binding<Bool>, selection: Binding<Color>) -> some View {
        
        /* Add the sheet to the background */
        self.background(ColourPickerSheet(isPresented: isPresented, selection: selection))
    }
}


private struct ColourPickerSheet: UIViewRepresentable {
    @Binding var isPresented: Bool
    @Binding var selection: Color
    
    func makeCoordinator() -> Coordinator {

        /* Create the coordinator, passing through the Colour and whether we're presented */
        Coordinator(selection: $selection, isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
        @Binding var selection: Color
        @Binding var isPresented: Bool
        var didPresent = false
        
        init(selection: Binding<Color>, isPresented: Binding<Bool>) {
            
            /* Initialise the selection and whether we're currently presenting */
            self._selection = selection
            self._isPresented = isPresented
        }
        
        /* When a new colour is selected */
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            
            /* Set the colour and pass it through */
            selection = Color(viewController.selectedColor)
        }
        
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            
            /* When we're finished, reset */
            isPresented = false
            didPresent = false
        }
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            
            /* When we're dismissed, reset */
            isPresented = false
            didPresent = false
        }
    }

    func getRootViewController(from view: UIView) -> UIViewController? {
        /* Loop through to the top VC */
        return view.window?.rootViewController ?? nil
    }
    
    func makeUIView(context: Context) -> UIView {
        /* Create an initial UIView */
        let view = UIView()
        view.isHidden = true
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        /* If we're presenting, and we haven't finished presenting */
        if isPresented && !context.coordinator.didPresent {
            
            /* Create the UIColourPickerVC */
            let modal = UIColorPickerViewController()
            
            /* Setup appropriate settings */
            modal.selectedColor = UIColor(selection)
            modal.supportsAlpha = false
            modal.delegate = context.coordinator
            
            modal.presentationController?.delegate = context.coordinator
            
            /* Present to the top View Controller */
            let top = getRootViewController(from: uiView)
            top?.present(modal, animated: true)
            context.coordinator.didPresent = true
        }
    }
}


#endif
