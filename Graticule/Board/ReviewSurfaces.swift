import UIKit

/// Section 3.6 names the live driver resolves beside the board.
/// Aim and Seal stay fused on the active tile. These types are not presented.
final class AimViewController: UIViewController {}

/// Seal freezes the aimed cell. The control lives on the board tile.
final class SealViewController: UIViewController {}

/// Ada Quinn is the seated tipster whose opening cell is ready to seal.
final class AdaQuinnViewController: UIViewController {}

/// Ben Holt is the seated tipster beside Ada on the same board.
final class BenHoltViewController: UIViewController {}
