/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Class providing custom thresholds for the object detection model.
*/

import CoreML

/// - Tag: ThresholdProvider
/// Class providing customized thresholds for object detection model
public class ThresholdProvider: MLFeatureProvider {
    /// The actual values to provide as input
    ///
    /// Create ML Defaults are 0.45 for IOU and 0.25 for confidence.
    /// Here the IOU threshold is relaxed a little bit because there are
    /// sometimes multiple overlapping boxes per die.
    /// Technically, relaxing the IOU threshold means
    /// non-maximum-suppression (NMS) becomes stricter (fewer boxes are shown).
    /// The confidence threshold can also be relaxed slightly because
    /// objects look very consistent and are easily detected on a homogeneous
    /// background.
    open var values = [
        "iou_threshold": MLFeatureValue(double: 0.3),
        "score_threshold": MLFeatureValue(double: 0.25)
    ]
    
    public init(){
    }

    /// The feature names the provider has, per the MLFeatureProvider protocol
    public var featureNames: Set<String> {
        return Set(values.keys)
    }

    /// The actual values for the features the provider can provide
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        return values[featureName]
    }
}
