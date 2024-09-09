//
//  FullScreenAdView.swift
//
//
//  Created by Hidde van der Ploeg on 30/06/2023.
//

import SwiftUI

struct FullScreenAdView : View {
    let advert : BillboardAd
    let config : BillboardConfiguration

    init(advert: BillboardAd, config: BillboardConfiguration) {
        self.advert = advert
        self.config = config
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                BillboardTextView(advert: advert, config: config)
                    .padding(.bottom, 24)
                Spacer()
            }
            Color.clear.frame(height: 48)
        }
        .background(
            ZStack {
                CachedImage(url: advert.mediaURL().absoluteString, content: { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            advert.background
                            ProgressView()
                                .tint(advert.tint)
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea(.all)
                    default:
                        ZStack {
                            advert.background
                            Image(systemName: "bolt.slash.fill")
                                .foregroundColor(advert.tint)
                        }
                    }
                })
                LinearGradient(colors: [advert.background, advert.background.opacity(0.1)], startPoint: .bottom, endPoint: .top).ignoresSafeArea(.all)
            }
            
        )
    }
}

struct FullScreenAdView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenAdView(advert: BillboardSamples.sampleFullScreenAd, config: BillboardConfiguration())
    }
}
