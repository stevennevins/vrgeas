# VRGEAs

VRGEA.sol
: This is the base contract for a Variable Rate Gradual English Auction (VRGEA). It provides the basic functionality for an auction, including the ability to place and withdraw bids. The auction's rate of sale is determined by a target sale time function, which is abstract in this base contract and must be implemented in derived contracts.

ConstantVRGEA.sol
: This contract extends the base VRGEA contract with a constant target sale time. This means that the auction duration is fixed and does not depend on the amount sold. The duration is set during the contract's initialization.

LinearVRGEA.sol
: This contract is not directly provided in the codebase, but it can be inferred that it would be a contract that extends the base VRGEA contract with a linear target sale time function. This means that the target sale time increases linearly with the amount sold. The exact implementation would depend on the specific requirements of the auction.

LogisticVRGEA.sol
: This contract extends the base VRGEA contract with a logistic target sale time function. This means that the target sale time follows a logistic curve, which starts slow, increases rapidly, and then slows down again as it approaches a limit. The parameters of the logistic function, including the limit and the time scale, are set during the contract's initialization.
