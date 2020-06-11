pragma solidity ^0.6.2;

import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/Initializable.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/presets/ERC20PresetMinterPauser.sol";

contract SanuGold is Initializable, ERC20PresetMinterPauserUpgradeSafe {

    // FEE CONTROLLER DATA
    // fee decimals is only set for informational purposes.
    // 1 feeRate = .000001 oz of gold
    uint8 public constant feeDecimals = 6;

    // feeRate is measured in 100th of a basis point (parts per 1,000,000)
    // ex: a fee rate of 200 = 0.02% of an oz of gold
    uint256 public constant feeParts = 1000000;
    uint256 public feeRate;
    address public feeController;
    address public feeRecipient;

    // FEE CONTROLLER EVENTS
    event FeeCollected(address indexed from, address indexed to, uint256 value);

    event FeeRateSet(
        uint256 indexed oldFeeRate,
        uint256 indexed newFeeRate
    );

    event FeeControllerSet(
        address indexed oldFeeController,
        address indexed newFeeController
    );

    event FeeRecipientSet(
        address indexed oldFeeRecipient,
        address indexed newFeeRecipient
    );

    // After calling the initialize function, this function should be called next
    function init() public {
      feeRate = 0;
      feeController = msg.sender;
      feeRecipient = msg.sender;
    }

    modifier onlyFeeController() {
      require(msg.sender == feeController, "only FeeController");
      _;
    }

     /**
     * @dev Sets a new fee rate.
     * @param _newFeeRate The new fee rate to collect as transfer fees for transfers.
     */
    function setFeeRate(uint256 _newFeeRate) public onlyFeeController {
        require(_newFeeRate <= feeParts, "cannot set fee rate above 100%");
        uint256 _oldFeeRate = feeRate;
        feeRate = _newFeeRate;
        emit FeeRateSet(_oldFeeRate, feeRate);
    }

    /**
    * @dev Transfer token to a specified address from msg.sender
    * Transfer additionally sends the fee to the fee controller
    * Note: the use of Safemath ensures that _value is nonnegative.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    // function transfer(address _to, uint256 _value) public o returns (bool) {
    //     require(_to != address(0), "cannot transfer to address zero");
    //     super.transfer(msg.sender, _to, _value);
    //     return true;
    // }
}