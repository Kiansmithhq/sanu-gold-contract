pragma solidity ^0.6.2;

// SPDX-License-Identifier: UNLICENSED

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
    address public owner;
    mapping(address => bool) internal frozen;

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

    // ASSET PROTECTION EVENTS
    event AddressFrozen(address indexed addr);
    event AddressUnfrozen(address indexed addr);
    event FrozenAddressWiped(address indexed addr);
    event AssetProtectionRoleSet (
        address indexed oldAssetProtectionRole,
        address indexed newAssetProtectionRole
    );

    // After calling the initialize function, this function should be called next
    function init() public {
      feeRate = 0;
      feeController = msg.sender;
      feeRecipient = msg.sender;
      owner = msg.sender;
    }

    modifier onlyFeeController() {
      require(msg.sender == feeController, "only FeeController");
      _;
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "only FeeController");
      _;
    }

    /**
     * @dev Freezes an address balance from being transferred.
     * @param _addr The new address to freeze.
     */
    function freeze(address _addr) public onlyOwner {
        require(!frozen[_addr], "address already frozen");
        frozen[_addr] = true;
        emit AddressFrozen(_addr);
    }

    /**
     * @dev Unfreezes an address balance allowing transfer.
     * @param _addr The new address to unfreeze.
     */
    function unfreeze(address _addr) public onlyOwner {
        require(frozen[_addr], "address already unfrozen");
        frozen[_addr] = false;
        emit AddressUnfrozen(_addr);
    }

    /**
     * @dev Wipes the balance of a frozen address, burning the tokens
     * and setting the approval to zero.
     * @param _addr The new frozen address to wipe.
     */
    function wipeFrozenAddress(address _addr) public onlyOwner {
        require(frozen[_addr], "address is not frozen");
        uint256 _balance = super.balanceOf(_addr);
        super.burnFrom(_addr, _balance);
        emit FrozenAddressWiped(_addr);
    }

    /**
    * @dev Gets whether the address is currently frozen.
    * @param _addr The address to check if frozen.
    * @return A bool representing whether the given address is frozen.
    */
    function isFrozen(address _addr) public view returns (bool) {
        return frozen[_addr];
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
     * @dev Sets a new fee recipient address.
     * @param _newFeeRecipient The address allowed to collect transfer fees for transfers.
     */
    function setFeeRecipient(address _newFeeRecipient) public onlyFeeController {
        require(_newFeeRecipient != address(0), "cannot set fee recipient to address zero");
        address _oldFeeRecipient = feeRecipient;
        feeRecipient = _newFeeRecipient;
        emit FeeRecipientSet(_oldFeeRecipient, feeRecipient);
    }

     /**
     * @dev Sets a new fee controller address.
     * @param _newFeeController The address allowed to set the fee rate and the fee recipient.
     */
    function setFeeController(address _newFeeController) public {
        require(msg.sender == feeController || msg.sender == owner, "only FeeController or Owner");
        require(_newFeeController != address(0), "cannot set fee controller to address zero");
        address _oldFeeController = feeController;
        feeController = _newFeeController;
        emit FeeControllerSet(_oldFeeController, feeController);
    }

    /**
    * @dev Gets a fee for a given value
    * ex: given feeRate = 200 and feeParts = 1,000,000 then getFeeFor(10000) = 2
    * @param _value The amount to get the fee for.
    */
    function getFeeFor(uint256 _value) public view returns (uint256) {
        if (feeRate == 0) {
            return 0;
        }

        return _value.mul(feeRate).div(feeParts);
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