//
//  ApeAniViewDelegate.swift
//  ApesterKit
//
//  Created by Michael Krotorio on 4/17/24.
//

import Foundation
import AdPlayerSDK


class ApeAniViewDelegate: APENativeLibraryDelegate
{
    
}
extension ApeAniViewDelegate: AdPlayerTagEventsObserver {
    func onAdPlayerEvent(_ event: AdPlayerSDK.AdPlayerEvent) {
        switch event.type {
        case .fullScreenRequested:
            print("Full screen requested")
        case .inventory:
            print("Player initialized")
        case .adLoaded:
            print("Ad loaded")
        case .adImpression:
            APELoggerService.shared.info()
            receiveAdSuccess()
        case .adVideoFirstQuartile:
            print("Reached first quartile of the ad video")
        case .adVideoMidpoint:
            print("Reached midpoint of the ad video")
        case .adVideoThirdQuartile:
            print("Reached third quartile of the ad video")
        case .adVideoCompleted:
            print("Ad video completed")
        case .adClickThrough:
            print("Ad clicked on")
        case .adSkipped:
            print("Ad skipped")
        case .adSkippableStateChanged:
            print("Ad skip state changed")
        case .closed:
            print("Ad closed by user")
        case .adPaused:
            print("Ad paused")
        case .adPlaying:
            print("Ad playing or resumed")
        case .contentPaused:
            print("Content video paused")
        case .contentPlaying:
            print("Content video resumed")
        case .contentVideoStart:
            print("Content video started")
        case .contentVideoFirstQuartile:
            print("Content reached first quartile")
        case .contentVideoMidpoint:
            print("Content reached midpoint")
        case .contentVideoThirdQuartile:
            print("Content reached third quartile")
        case .contentVideoComplete:
            print("Content video completed")
        case .adError, .adErrorLimit, .error:
            if let errorEvent = event as? AdPlayerEventError {
                print("Error occurred: \(errorEvent.message)")
            }
        case .adVolumeChange, .contentVolumeChange:
            if let volumeEvent = event as? AdPlayerEventVolume {
                print("Volume changed to \(volumeEvent.volume)")
            }
        default:
            print("Unhandled event: \(event.type)")
        }
    }
    
    
    
}
