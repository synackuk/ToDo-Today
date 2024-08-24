//
//  ColourExtensions.swift
//  LifeLog
//
//  Created by Douglas Inglis on 04/05/2023.
//

import Foundation
import SwiftUI

extension Color {
    func getContrastingColour() -> Color {
        
        /* Get the colours RGBA Components */
        let colourComponents = UIColor(self).cgColor.components ?? [1, 1, 1]
        
        /* Calculate R, taking account of transparency over a white backdrop */
        let normalisedRed = normaliseChannel(colourChannel: colourComponents[0], alphaChannel: colourComponents[3])
        
        /* Calculate G, taking account of transparency over a white backdrop */
        let normalisedGreen = normaliseChannel(colourChannel: colourComponents[1], alphaChannel: colourComponents[3])
        
        /* Calculate B, taking account of transparency over a white backdrop */
        let normalisedBlue = normaliseChannel(colourChannel: colourComponents[2], alphaChannel: colourComponents[3])
        
        /* Standard luminance calculation - the luminance of each channel multiplied by that channels brightness for a normal colour vision person */
        let luminance = 0.2126 * sRGBtoLin(colourChannel: normalisedRed) + 0.7152 * sRGBtoLin(colourChannel: normalisedGreen) + 0.0722 * sRGBtoLin(colourChannel: normalisedBlue)
        
        /* Follows W3 Guidelines correctly */
        if(luminance > (sqrt(1.05 * 0.05) - 0.05)) {
            return Color.black
        }
        return Color.white
    }
    
}

private func normaliseChannel(colourChannel: CGFloat, alphaChannel: CGFloat) -> CGFloat {
    
    /* Normalise the channel with alpha */
    return (1 - alphaChannel) + (colourChannel * alphaChannel)
}

private func sRGBtoLin(colourChannel: CGFloat) -> CGFloat {
    
    /* Standard calculation for luminance of a given channel */
    if ( colourChannel <= 0.04045 ) {
        return colourChannel / 12.92;
    } else {
        return pow((( colourChannel + 0.055)/1.055),2.4);
    }
}
