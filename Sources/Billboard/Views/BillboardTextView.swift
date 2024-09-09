//
//  BillboardTextView.swift
//  
//
//  Created by Hidde van der Ploeg on 01/07/2023.
//

import SwiftUI

struct BillboardTextView : View {
    let advert: BillboardAd
    let config : BillboardConfiguration

    init(advert: BillboardAd, config: BillboardConfiguration) {
        self.advert = advert
        self.config = config
    }
    
    var body: some View {
        VStack(spacing: 10) {
            BillboardAdInfoLabel(advert: advert)
                .opacity(config.isPromotion ? 0 : 1)

            VStack(spacing: 6) {
                Text(advert.getTitle())
                    .font(.compatibleSystem(.title2, design: .rounded, weight: .heavy))
                Text(advert.getDescription())
                    .font(.system(.body, design: .rounded))
            }
        }
        .multilineTextAlignment(.center)
        .foregroundColor(advert.text)
        .frame(maxWidth: 640)
        .padding(.horizontal, 24)
        .padding(.bottom, 64)
    }
}

struct BillboardTextView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultAdView(advert: BillboardSamples.sampleDefaultAd, config: BillboardConfiguration())
    }
}


