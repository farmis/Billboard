//
//  BillboardView.swift
//
//  Created by Hidde van der Ploeg on 27/06/2022.
//

import SwiftUI
import StoreKit

public struct BillboardView<Content:View>: View {
    let advert : BillboardAd
    let config : BillboardConfiguration
    
    @ViewBuilder var paywall: () -> Content
    
    @State private var showPaywall : Bool = false
    @State private var canDismiss = false
    
    public init(advert: BillboardAd, config: BillboardConfiguration = BillboardConfiguration(), paywall: @escaping () -> Content) {
        self.advert = advert
        self.config = config
        self.paywall = paywall
    }
    
    public var body: some View {
        #if os(visionOS)
        NavigationStack {
            ZStack(alignment: .top) {
                advert.background.ignoresSafeArea()
                
                if advert.fullscreen {
                    FullScreenAdView(advert: advert)
                } else {
                    DefaultAdView(advert: advert)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // TimerView
                    if canDismiss {
                        BillboardDismissButton()
                            .onAppear {
                                #if os(iOS)
                                if config.allowHaptics {
                                    haptics(.light)
                                }
                                #endif
                            }
                    } else {
                        BillboardCountdownView(advert:advert,
                                               totalDuration: config.duration,
                                               canDismiss: $canDismiss)
                    }
                }
                if !config.isPromotion {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showPaywall.toggle()
                        } label: {
                            Text("Remove Ads")
                                .font(.system(.footnote, design: .rounded))
                                .bold()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
        .sheet(isPresented: $showPaywall) { paywall() }
        .onAppear(perform: displayOverlay)
        .onDisappear(perform: dismissOverlay)
        .onChange(of: showPaywall) { newValue in
            if newValue {
                dismissOverlay()
            } else {
                displayOverlay()
            }
        }
        #else
        ZStack(alignment: .top) {
            advert.background.ignoresSafeArea()
            
            if advert.fullscreen {
                FullScreenAdView(advert: advert, config: config)
            } else {
                DefaultAdView(advert: advert, config: config)
            }
            
            HStack {
                if !config.isPromotion {
                    Button {
                        showPaywall.toggle()
                    } label: {
                        Text("Remove Ads")
                            .font(.system(.footnote, design: .rounded))
                            .bold()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                Spacer()
                
                // TimerView
                if canDismiss || config.isPromotion {
                    BillboardDismissButton()
                        .onAppear {
                            #if os(iOS)
                            if config.allowHaptics {
                                haptics(.light)
                            }
                            #endif
                        }
                } else {
                    BillboardCountdownView(advert:advert,
                                           totalDuration: config.duration,
                                           canDismiss: $canDismiss)
                }
            }
            .frame(height: 40)
            .tint(advert.tint)
            .padding()
        }
        .sheet(isPresented: $showPaywall) { paywall() }
        .onAppear(perform: displayOverlay)
        .onDisappear(perform: dismissOverlay)
        .onChange(of: showPaywall) { newValue in
            if newValue {
                dismissOverlay()
            } else {
                displayOverlay()
            }
        }
        .statusBarHidden(true)
        #endif
      
    }
    
    //MARK: - App Store Overlay
    
    private var storeOverlay : SKOverlay {
        let config = SKOverlay.AppConfiguration(appIdentifier: advert.appStoreID, position: .bottom)
        let overlay = SKOverlay(configuration: config)
        return overlay
    }
    
    private let scene = UIApplication.shared.connectedScenes
        .compactMap({ scene -> UIWindow? in
            (scene as? UIWindowScene)?.keyWindow
        })
        .first?
        .windowScene
    
    private func dismissOverlay() {
        guard let scene else { return }
        SKOverlay.dismiss(in: scene)
    }
    
    private func displayOverlay() {
        guard let scene else { return }
        storeOverlay.present(in: scene)
        
        #if os(iOS)
        if config.allowHaptics {
            haptics(.heavy)
        }
        #endif
    }
    
}

